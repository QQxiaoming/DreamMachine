#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QComboBox>
#include <QDateTime>
#include <QDir>
#include <QDoubleSpinBox>
#include <QFile>
#include <QFileDialog>
#include <QFileInfo>
#include <QFormLayout>
#include <QFuture>
#include <QFutureWatcher>
#include <QGridLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QImageReader>
#include <QImage>
#include <QImageWriter>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPushButton>
#include <QPixmap>
#include <QRandomGenerator>
#include <QBuffer>
#include <QSpinBox>
#include <QTcpSocket>
#include <QTextEdit>
#include <QVBoxLayout>
#include <QtConcurrent>

#include <limits>

namespace {

constexpr int kMaxResolution = 1280;

QSize clampResolutionKeepAspect(int width, int height)
{
    if (width <= 0 || height <= 0) {
        return QSize(width, height);
    }

    if (width <= kMaxResolution && height <= kMaxResolution) {
        return QSize(width, height);
    }

    const double scale = qMin(static_cast<double>(kMaxResolution) / static_cast<double>(width),
                              static_cast<double>(kMaxResolution) / static_cast<double>(height));
    const int scaledW = qMax(1, qRound(static_cast<double>(width) * scale));
    const int scaledH = qMax(1, qRound(static_cast<double>(height) * scale));
    return QSize(scaledW, scaledH);
}

bool sendPacket(QTcpSocket &socket, const QJsonObject &payload, QString &error)
{
    const QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (body.size() > std::numeric_limits<quint32>::max()) {
        error = "Payload is too large";
        return false;
    }

    QByteArray header(4, '\0');
    const quint32 bodyLen = static_cast<quint32>(body.size());
    header[0] = static_cast<char>((bodyLen >> 24) & 0xFF);
    header[1] = static_cast<char>((bodyLen >> 16) & 0xFF);
    header[2] = static_cast<char>((bodyLen >> 8) & 0xFF);
    header[3] = static_cast<char>(bodyLen & 0xFF);

    if (socket.write(header) != header.size() || !socket.waitForBytesWritten(5000)) {
        error = "Failed to send packet header";
        return false;
    }
    if (socket.write(body) != body.size() || !socket.waitForBytesWritten(5000)) {
        error = "Failed to send packet body";
        return false;
    }
    return true;
}

bool recvExact(QTcpSocket &socket, QByteArray &out, qsizetype count, int timeoutMs, QString &error)
{
    out.clear();
    out.reserve(count);

    while (out.size() < count) {
        if (socket.bytesAvailable() <= 0 && !socket.waitForReadyRead(timeoutMs)) {
            error = "Timed out while receiving server response";
            return false;
        }

        const QByteArray chunk = socket.read(count - out.size());
        if (chunk.isEmpty()) {
            if (socket.state() != QAbstractSocket::ConnectedState) {
                error = "Connection closed while receiving data";
                return false;
            }
            continue;
        }
        out.append(chunk);
    }

    return true;
}

bool recvPacket(QTcpSocket &socket, QJsonObject &obj, QString &error)
{
    QByteArray header;
    if (!recvExact(socket, header, 4, 120000, error)) {
        return false;
    }

    const quint32 bodyLen = (static_cast<quint32>(static_cast<unsigned char>(header[0])) << 24)
                            | (static_cast<quint32>(static_cast<unsigned char>(header[1])) << 16)
                            | (static_cast<quint32>(static_cast<unsigned char>(header[2])) << 8)
                            | static_cast<quint32>(static_cast<unsigned char>(header[3]));

    QByteArray body;
    if (!recvExact(socket, body, bodyLen, 120000, error)) {
        return false;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        error = QString("Invalid JSON response: %1").arg(parseError.errorString());
        return false;
    }

    obj = doc.object();
    return true;
}

QString inferDefaultOutputDir()
{
    return QDir::current().absolutePath();
}

QString extensionForFormat(const QString &format)
{
    const QString fmt = format.trimmed().toUpper();
    if (fmt == "JPEG" || fmt == "JPG") {
        return "jpg";
    }
    if (fmt == "WEBP") {
        return "webp";
    }
    return "png";
}

} // namespace

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    buildUi();
    connectSignals();
    autoLoadStartupPreset();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::buildUi()
{
    setWindowTitle("DreamMachine");

    auto *rootLayout = new QHBoxLayout(ui->centralwidget);

    auto *leftPanel = new QWidget(ui->centralwidget);
    auto *leftLayout = new QVBoxLayout(leftPanel);

    auto *rightPanel = new QWidget(ui->centralwidget);
    auto *rightLayout = new QVBoxLayout(rightPanel);
    auto *previewTitle = new QLabel("Preview", rightPanel);
    previewTitle->setAlignment(Qt::AlignCenter);
    rightLayout->addWidget(previewTitle);

    auto *inputGroup = new QGroupBox("Input Images (max 4)", leftPanel);
    auto *inputLayout = new QVBoxLayout(inputGroup);
    m_inputImageList = new QListWidget(inputGroup);
    inputLayout->addWidget(m_inputImageList);

    auto *inputButtonLayout = new QHBoxLayout();
    m_addInputButton = new QPushButton("Add Images", inputGroup);
    m_removeInputButton = new QPushButton("Remove Selected", inputGroup);
    inputButtonLayout->addWidget(m_addInputButton);
    inputButtonLayout->addWidget(m_removeInputButton);
    inputLayout->addLayout(inputButtonLayout);

    leftLayout->addWidget(inputGroup);

    auto *formGroup = new QGroupBox("Generation Settings", leftPanel);
    auto *formLayout = new QGridLayout(formGroup);

    m_widthSpin = new QSpinBox(formGroup);
    m_widthSpin->setRange(0, 16384);
    m_widthSpin->setValue(1024);
    m_heightSpin = new QSpinBox(formGroup);
    m_heightSpin->setRange(0, 16384);
    m_heightSpin->setValue(1024);

    m_promptEdit = new QTextEdit(formGroup);
    m_promptEdit->setPlaceholderText("Enter positive prompt...");
    m_negPromptEdit = new QTextEdit(formGroup);
    m_negPromptEdit->setPlaceholderText("Enter negative prompt (optional)...");

    m_outputDirEdit = new QLineEdit(formGroup);
    m_outputDirEdit->setText(inferDefaultOutputDir());
    m_chooseOutputDirButton = new QPushButton("Browse", formGroup);

    m_seedEdit = new QLineEdit(formGroup);
    m_seedEdit->setText(QString::number(QRandomGenerator::global()->generate()));
    m_seedEdit->setToolTip("Set -1 to generate a random seed at run time.");
    m_stepsSpin = new QSpinBox(formGroup);
    m_stepsSpin->setRange(1, 500);
    m_stepsSpin->setValue(4);

    m_cfgSpin = new QDoubleSpinBox(formGroup);
    m_cfgSpin->setRange(0.0, 100.0);
    m_cfgSpin->setDecimals(2);
    m_cfgSpin->setValue(1.0);

    m_samplerEdit = new QLineEdit("sa_solver", formGroup);
    m_schedulerEdit = new QLineEdit("beta", formGroup);

    m_denoiseSpin = new QDoubleSpinBox(formGroup);
    m_denoiseSpin->setRange(0.0, 1.0);
    m_denoiseSpin->setSingleStep(0.05);
    m_denoiseSpin->setDecimals(2);
    m_denoiseSpin->setValue(1.0);

    m_outputFormatCombo = new QComboBox(formGroup);
    m_outputFormatCombo->addItems({"PNG"});

    m_hostEdit = new QLineEdit("127.0.0.1", formGroup);
    m_portSpin = new QSpinBox(formGroup);
    m_portSpin->setRange(1, 65535);
    m_portSpin->setValue(17890);

    int row = 0;
    formLayout->addWidget(new QLabel("Target Width"), row, 0);
    formLayout->addWidget(m_widthSpin, row, 1);
    formLayout->addWidget(new QLabel("Target Height"), row, 2);
    formLayout->addWidget(m_heightSpin, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("Prompt"), row, 0);
    formLayout->addWidget(m_promptEdit, row, 1, 1, 3);
    ++row;

    formLayout->addWidget(new QLabel("Neg Prompt"), row, 0);
    formLayout->addWidget(m_negPromptEdit, row, 1, 1, 3);
    ++row;

    formLayout->addWidget(new QLabel("Output Directory"), row, 0);
    formLayout->addWidget(m_outputDirEdit, row, 1, 1, 2);
    formLayout->addWidget(m_chooseOutputDirButton, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("Seed"), row, 0);
    formLayout->addWidget(m_seedEdit, row, 1);
    formLayout->addWidget(new QLabel("Steps"), row, 2);
    formLayout->addWidget(m_stepsSpin, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("CFG"), row, 0);
    formLayout->addWidget(m_cfgSpin, row, 1);
    formLayout->addWidget(new QLabel("Denoise"), row, 2);
    formLayout->addWidget(m_denoiseSpin, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("Sampler"), row, 0);
    formLayout->addWidget(m_samplerEdit, row, 1);
    formLayout->addWidget(new QLabel("Scheduler"), row, 2);
    formLayout->addWidget(m_schedulerEdit, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("Output Format"), row, 0);
    formLayout->addWidget(m_outputFormatCombo, row, 1);
    formLayout->addWidget(new QLabel("Host"), row, 2);
    formLayout->addWidget(m_hostEdit, row, 3);
    ++row;

    formLayout->addWidget(new QLabel("Port"), row, 0);
    formLayout->addWidget(m_portSpin, row, 1);

    leftLayout->addWidget(formGroup);

    auto *actionLayout = new QHBoxLayout();
    m_loadPresetButton = new QPushButton("Load Preset", leftPanel);
    m_savePresetButton = new QPushButton("Save Preset", leftPanel);
    m_runButton = new QPushButton("Run", leftPanel);
    m_saveImageButton = new QPushButton("Save Result", leftPanel);
    m_saveImageButton->setEnabled(false);
    m_statusLabel = new QLabel("Idle", leftPanel);
    actionLayout->addWidget(m_loadPresetButton);
    actionLayout->addWidget(m_savePresetButton);
    actionLayout->addWidget(m_runButton);
    actionLayout->addWidget(m_saveImageButton);
    actionLayout->addWidget(m_statusLabel, 1);
    leftLayout->addLayout(actionLayout);

    m_previewLabel = new QLabel(rightPanel);
    m_previewLabel->setMinimumHeight(220);
    m_previewLabel->setAlignment(Qt::AlignCenter);
    m_previewLabel->setStyleSheet("QLabel { border: 1px solid #666; }");
    m_previewLabel->setText("Preview will appear here after generation.");
    rightLayout->addWidget(m_previewLabel, 1);

    m_resultEdit = new QTextEdit(leftPanel);
    m_resultEdit->setReadOnly(true);
    m_resultEdit->setPlaceholderText("Result JSON will appear here...");
    leftLayout->addWidget(m_resultEdit, 1);

    rootLayout->addWidget(leftPanel, 3);
    rootLayout->addWidget(rightPanel, 2);

    m_watcher = new QFutureWatcher<InferResult>(this);
    refreshTargetSizeEditability();
}

void MainWindow::connectSignals()
{
    connect(m_addInputButton, &QPushButton::clicked, this, &MainWindow::addInputImages);
    connect(m_removeInputButton, &QPushButton::clicked, this, &MainWindow::removeSelectedImage);
    connect(m_chooseOutputDirButton, &QPushButton::clicked, this, &MainWindow::chooseOutputDirectory);
    connect(m_savePresetButton, &QPushButton::clicked, this, &MainWindow::savePreset);
    connect(m_loadPresetButton, &QPushButton::clicked, this, &MainWindow::loadPreset);
    connect(m_runButton, &QPushButton::clicked, this, &MainWindow::startInference);
    connect(m_saveImageButton, &QPushButton::clicked, this, &MainWindow::saveGeneratedImage);

    connect(m_watcher, &QFutureWatcher<InferResult>::finished, this, [this]() {
        const InferResult r = m_watcher->result();
        setRunningState(false);

        if (!r.ok) {
            m_statusLabel->setText("Failed");
            QMessageBox::critical(this, "Inference Failed", r.error);
            return;
        }

        m_statusLabel->setText("Done (Preview)");

        m_lastGeneratedImageBytes = r.generatedImageBytes;
        m_lastGeneratedFormat = r.outputFormat;
        m_lastEffectiveSeed = r.seed;
        updatePreviewDisplay(m_lastGeneratedImageBytes);
        m_saveImageButton->setEnabled(!m_lastGeneratedImageBytes.isEmpty());

        QJsonObject obj;
        obj["ok"] = true;
        obj["output_dir"] = m_outputDirEdit->text().trimmed();
        obj["preview_ready"] = !m_lastGeneratedImageBytes.isEmpty();
        obj["output_format"] = r.outputFormat;
        obj["seed"] = QString::number(r.seed);
        obj["width"] = r.width;
        obj["height"] = r.height;
        obj["ckpt_path"] = r.ckptPath;
        m_resultEdit->setPlainText(QString::fromUtf8(QJsonDocument(obj).toJson(QJsonDocument::Indented)));
    });
}

void MainWindow::setRunningState(bool running)
{
    m_runButton->setEnabled(!running);
    m_addInputButton->setEnabled(!running);
    m_removeInputButton->setEnabled(!running);
    m_chooseOutputDirButton->setEnabled(!running);
    m_savePresetButton->setEnabled(!running);
    m_loadPresetButton->setEnabled(!running);
    m_saveImageButton->setEnabled(!running && !m_lastGeneratedImageBytes.isEmpty());
    m_statusLabel->setText(running ? "Running..." : m_statusLabel->text());
}

bool MainWindow::readImageSize(const QString &imagePath, int &width, int &height) const
{
    QImageReader reader(imagePath);
    const QSize size = reader.size();
    if (!size.isValid() || size.width() <= 0 || size.height() <= 0) {
        return false;
    }

    width = size.width();
    height = size.height();
    return true;
}

void MainWindow::refreshTargetSizeEditability()
{
    const bool hasInputImages = m_inputImageList->count() > 0;

    m_widthSpin->setEnabled(!hasInputImages);
    m_heightSpin->setEnabled(!hasInputImages);

    if (!hasInputImages) {
        m_widthSpin->setToolTip("No input image: you can edit target width.");
        m_heightSpin->setToolTip("No input image: you can edit target height.");
        return;
    }

    const QString firstImagePath = m_inputImageList->item(0)->text();
    int width = 0;
    int height = 0;
    if (readImageSize(firstImagePath, width, height)) {
        const QSize clamped = clampResolutionKeepAspect(width, height);
        m_widthSpin->setValue(clamped.width());
        m_heightSpin->setValue(clamped.height());
        if (clamped.width() != width || clamped.height() != height) {
            m_widthSpin->setToolTip("Locked to first input image width (auto scaled to <=1280).");
            m_heightSpin->setToolTip("Locked to first input image height (auto scaled to <=1280).");
        } else {
            m_widthSpin->setToolTip("Locked to first input image width.");
            m_heightSpin->setToolTip("Locked to first input image height.");
        }
    } else {
        m_widthSpin->setToolTip("Cannot read first input image size.");
        m_heightSpin->setToolTip("Cannot read first input image size.");
    }
}

void MainWindow::addInputImages()
{
    const QStringList files = QFileDialog::getOpenFileNames(
        this,
        "Select Input Images",
        QDir::current().absolutePath(),
        "Images (*.png *.jpg *.jpeg *.webp *.bmp);;All files (*.*)");

    for (const QString &file : files) {
        if (m_inputImageList->count() >= 4) {
            QMessageBox::warning(this, "Input Limit", "最多支持 4 张输入图。");
            break;
        }
        m_inputImageList->addItem(file);
    }

    refreshTargetSizeEditability();
}

void MainWindow::removeSelectedImage()
{
    const auto selected = m_inputImageList->selectedItems();
    for (QListWidgetItem *item : selected) {
        delete m_inputImageList->takeItem(m_inputImageList->row(item));
    }

    refreshTargetSizeEditability();
}

void MainWindow::chooseOutputDirectory()
{
    QString initialPath = m_outputDirEdit->text().trimmed();
    if (initialPath.isEmpty()) {
        initialPath = inferDefaultOutputDir();
    }
    const QString dir = QFileDialog::getExistingDirectory(
        this,
        "Choose Output Directory",
        initialPath,
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
    if (!dir.isEmpty()) {
        m_outputDirEdit->setText(dir);
    }
}

void MainWindow::updatePreviewDisplay(const QByteArray &imageBytes)
{
    QImage image;
    if (!image.loadFromData(imageBytes)) {
        m_previewLabel->setText("Preview unavailable: cannot decode generated image.");
        m_previewLabel->setPixmap(QPixmap());
        return;
    }

    const QPixmap pixmap = QPixmap::fromImage(image);
    if (pixmap.isNull()) {
        m_previewLabel->setText("Preview unavailable.");
        m_previewLabel->setPixmap(QPixmap());
        return;
    }

    const QSize targetSize = m_previewLabel->size().boundedTo(QSize(960, 540));
    m_previewLabel->setPixmap(pixmap.scaled(targetSize, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}

void MainWindow::saveGeneratedImage()
{
    if (m_lastGeneratedImageBytes.isEmpty()) {
        QMessageBox::warning(this, "No Image", "No generated image to save. Please run inference first.");
        return;
    }

    const QString outputDirPath = m_outputDirEdit->text().trimmed();
    if (outputDirPath.isEmpty()) {
        QMessageBox::warning(this, "Missing Output Directory", "Please set output directory first.");
        return;
    }

    QDir outputDir(outputDirPath);
    if (!outputDir.exists() && !outputDir.mkpath(".")) {
        QMessageBox::critical(this, "Save Failed", QString("Cannot create output directory: %1").arg(outputDirPath));
        return;
    }

    const QString ext = extensionForFormat(m_lastGeneratedFormat);
    const QString ts = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
    QString fileName = QString("dreammachine_%1.%2").arg(ts, ext);
    QString filePath = outputDir.filePath(fileName);
    int counter = 1;
    while (QFileInfo::exists(filePath)) {
        fileName = QString("dreammachine_%1_%2.%3").arg(ts).arg(counter++).arg(ext);
        filePath = outputDir.filePath(fileName);
    }

    if (ext == "png") {
        QImage image;
        if (!image.loadFromData(m_lastGeneratedImageBytes)) {
            QMessageBox::critical(this, "Save Failed", "Cannot decode generated PNG for metadata embedding.");
            return;
        }

        QJsonObject root;
        root["version"] = 1;
        QJsonObject preset = collectPresetObject();
        preset["seed"] = QString::number(m_lastEffectiveSeed);
        root["preset"] = preset;
        image.setText("dreammachine_preset_json", QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact)));

        if (!image.save(filePath, "PNG")) {
            QMessageBox::critical(this, "Save Failed", QString("Failed to save PNG with metadata: %1").arg(filePath));
            return;
        }
    } else {
        QFile outFile(filePath);
        if (!outFile.open(QIODevice::WriteOnly)) {
            QMessageBox::critical(this, "Save Failed", QString("Cannot write file: %1").arg(filePath));
            return;
        }

        if (outFile.write(m_lastGeneratedImageBytes) != m_lastGeneratedImageBytes.size()) {
            QMessageBox::critical(this, "Save Failed", QString("Failed to write image data: %1").arg(filePath));
            return;
        }
    }

    m_statusLabel->setText("Saved");
    m_resultEdit->append(QString("Saved image: %1").arg(filePath));
}

QJsonObject MainWindow::collectPresetObject() const
{
    QJsonObject preset;

    QJsonArray inputImages;
    for (int i = 0; i < m_inputImageList->count(); ++i) {
        inputImages.append(m_inputImageList->item(i)->text());
    }

    preset["input_images"] = inputImages;
    preset["target_width"] = m_widthSpin->value();
    preset["target_height"] = m_heightSpin->value();
    preset["prompt"] = m_promptEdit->toPlainText();
    preset["neg_prompt"] = m_negPromptEdit->toPlainText();
    preset["output_dir"] = m_outputDirEdit->text().trimmed();
    preset["seed"] = m_seedEdit->text().trimmed();
    preset["steps"] = m_stepsSpin->value();
    preset["cfg"] = m_cfgSpin->value();
    preset["sampler_name"] = m_samplerEdit->text().trimmed();
    preset["scheduler"] = m_schedulerEdit->text().trimmed();
    preset["denoise"] = m_denoiseSpin->value();
    preset["output_format"] = m_outputFormatCombo->currentText();
    preset["host"] = m_hostEdit->text().trimmed();
    preset["port"] = m_portSpin->value();

    return preset;
}

bool MainWindow::applyPresetObject(const QJsonObject &preset, QString &error)
{
    const QJsonArray inputImages = preset.value("input_images").toArray();
    if (inputImages.size() > 4) {
        error = "Preset contains more than 4 input images";
        return false;
    }

    m_inputImageList->clear();
    for (const QJsonValue &value : inputImages) {
        const QString path = value.toString().trimmed();
        if (!path.isEmpty()) {
            m_inputImageList->addItem(path);
        }
    }

    if (preset.contains("target_width")) {
        m_widthSpin->setValue(qMax(0, preset.value("target_width").toInt(m_widthSpin->value())));
    }
    if (preset.contains("target_height")) {
        m_heightSpin->setValue(qMax(0, preset.value("target_height").toInt(m_heightSpin->value())));
    }

    if (preset.contains("prompt")) {
        m_promptEdit->setPlainText(preset.value("prompt").toString());
    }
    if (preset.contains("neg_prompt")) {
        m_negPromptEdit->setPlainText(preset.value("neg_prompt").toString());
    }
    if (preset.contains("output_dir")) {
        m_outputDirEdit->setText(preset.value("output_dir").toString().trimmed());
    } else if (preset.contains("output_image")) {
        // Backward compatibility for older preset files.
        const QString legacyPath = preset.value("output_image").toString().trimmed();
        if (!legacyPath.isEmpty()) {
            m_outputDirEdit->setText(QFileInfo(legacyPath).absolutePath());
        }
    }
    if (preset.contains("seed")) {
        const QString seedStr = preset.value("seed").toVariant().toString().trimmed();
        if (!seedStr.isEmpty()) {
            m_seedEdit->setText(seedStr);
        }
    }
    if (preset.contains("steps")) {
        m_stepsSpin->setValue(qBound(m_stepsSpin->minimum(), preset.value("steps").toInt(m_stepsSpin->value()), m_stepsSpin->maximum()));
    }
    if (preset.contains("cfg")) {
        m_cfgSpin->setValue(qBound(m_cfgSpin->minimum(), preset.value("cfg").toDouble(m_cfgSpin->value()), m_cfgSpin->maximum()));
    }
    if (preset.contains("sampler_name")) {
        m_samplerEdit->setText(preset.value("sampler_name").toString().trimmed());
    }
    if (preset.contains("scheduler")) {
        m_schedulerEdit->setText(preset.value("scheduler").toString().trimmed());
    }
    if (preset.contains("denoise")) {
        m_denoiseSpin->setValue(qBound(m_denoiseSpin->minimum(), preset.value("denoise").toDouble(m_denoiseSpin->value()), m_denoiseSpin->maximum()));
    }

    if (preset.contains("output_format")) {
        const QString outputFormat = preset.value("output_format").toString().trimmed().toUpper();
        const int index = m_outputFormatCombo->findText(outputFormat);
        if (index >= 0) {
            m_outputFormatCombo->setCurrentIndex(index);
        } else if (!outputFormat.isEmpty()) {
            error = QString("Preset has unsupported output_format: %1").arg(outputFormat);
            return false;
        }
    }

    if (preset.contains("host")) {
        m_hostEdit->setText(preset.value("host").toString().trimmed());
    }
    if (preset.contains("port")) {
        m_portSpin->setValue(qBound(m_portSpin->minimum(), preset.value("port").toInt(m_portSpin->value()), m_portSpin->maximum()));
    }

    refreshTargetSizeEditability();

    return true;
}

void MainWindow::savePreset()
{
    const QString filePath = QFileDialog::getSaveFileName(
        this,
        "Save Preset",
        QDir::current().absoluteFilePath("dreammachine_preset.json"),
        "JSON (*.json);;All files (*.*)");
    if (filePath.isEmpty()) {
        return;
    }

    QJsonObject root;
    root["version"] = 1;
    root["preset"] = collectPresetObject();

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QMessageBox::critical(this, "Save Preset Failed", QString("Cannot open file for writing: %1").arg(filePath));
        return;
    }

    const QByteArray data = QJsonDocument(root).toJson(QJsonDocument::Indented);
    if (file.write(data) != data.size()) {
        QMessageBox::critical(this, "Save Preset Failed", QString("Failed to write preset file: %1").arg(filePath));
        return;
    }

    m_statusLabel->setText("Preset Saved");
}

void MainWindow::loadPreset()
{
    const QString filePath = QFileDialog::getOpenFileName(
        this,
        "Load Preset",
        QDir::current().absoluteFilePath("dreammachine_preset.json"),
        "Preset files (*.json *.png);;JSON (*.json);;PNG Images (*.png);;All files (*.*)");
    if (filePath.isEmpty()) {
        return;
    }

    loadPresetFromFile(filePath, true);
}

bool MainWindow::loadPresetFromFile(const QString &filePath, bool showErrors)
{
    QJsonObject root;
    const QString suffix = QFileInfo(filePath).suffix().toLower();

    if (suffix == "png") {
        QImageReader reader(filePath);
        const QImage image = reader.read();
        if (image.isNull()) {
            if (showErrors) {
                QMessageBox::critical(this, "Load Preset Failed", QString("Cannot read PNG file: %1").arg(filePath));
            }
            return false;
        }

        const QString presetJson = image.text("dreammachine_preset_json").trimmed();
        if (presetJson.isEmpty()) {
            if (showErrors) {
                QMessageBox::critical(this, "Load Preset Failed", "PNG does not contain embedded preset JSON.");
            }
            return false;
        }

        QJsonParseError parseError;
        const QJsonDocument doc = QJsonDocument::fromJson(presetJson.toUtf8(), &parseError);
        if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
            if (showErrors) {
                QMessageBox::critical(this, "Load Preset Failed", QString("Embedded preset JSON is invalid: %1").arg(parseError.errorString()));
            }
            return false;
        }
        root = doc.object();
    } else {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly)) {
            if (showErrors) {
                QMessageBox::critical(this, "Load Preset Failed", QString("Cannot open file: %1").arg(filePath));
            }
            return false;
        }

        QJsonParseError parseError;
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
        if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
            if (showErrors) {
                QMessageBox::critical(this, "Load Preset Failed", QString("Invalid preset JSON: %1").arg(parseError.errorString()));
            }
            return false;
        }
        root = doc.object();
    }

    const QJsonObject preset = root.value("preset").isObject() ? root.value("preset").toObject() : root;

    QString error;
    if (!applyPresetObject(preset, error)) {
        if (showErrors) {
            QMessageBox::critical(this, "Load Preset Failed", error);
        }
        return false;
    }

    m_statusLabel->setText("Preset Loaded");
    return true;
}

void MainWindow::autoLoadStartupPreset()
{
    const QString presetPath = QDir::current().absoluteFilePath("dreammachine_preset.json");
    if (!QFileInfo::exists(presetPath)) {
        return;
    }

    if (loadPresetFromFile(presetPath, false)) {
        m_statusLabel->setText("Preset Auto Loaded");
    }
}

void MainWindow::startInference()
{
    if (m_promptEdit->toPlainText().trimmed().isEmpty()) {
        QMessageBox::warning(this, "Missing Prompt", "Prompt 不能为空。");
        return;
    }
    if (m_outputDirEdit->text().trimmed().isEmpty()) {
        QMessageBox::warning(this, "Missing Output", "请指定输出目录。");
        return;
    }
    if (m_inputImageList->count() == 0 && (m_widthSpin->value() <= 0 || m_heightSpin->value() <= 0)) {
        QMessageBox::warning(this, "Missing Size", "无输入图时必须指定 target width/height。");
        return;
    }

    bool ok = false;
    const qint64 seedInput = m_seedEdit->text().trimmed().toLongLong(&ok);
    if (!ok) {
        QMessageBox::warning(this, "Invalid Seed", "Seed 必须是整数。");
        return;
    }

    qint64 effectiveSeed = seedInput;
    if (seedInput == -1) {
        effectiveSeed = static_cast<qint64>(QRandomGenerator::global()->generate64()
                                            & static_cast<quint64>(std::numeric_limits<qint64>::max()));
    }
    m_lastEffectiveSeed = effectiveSeed;

    InferRequestParams params;
    for (int i = 0; i < m_inputImageList->count(); ++i) {
        params.inputImages.append(m_inputImageList->item(i)->text());
    }
    params.noInputImages = params.inputImages.isEmpty();
    {
        const QSize clampedTarget = clampResolutionKeepAspect(m_widthSpin->value(), m_heightSpin->value());
        params.targetWidth = clampedTarget.width();
        params.targetHeight = clampedTarget.height();
    }
    params.prompt = m_promptEdit->toPlainText();
    params.outputDir = m_outputDirEdit->text().trimmed();
    params.seed = effectiveSeed;
    params.steps = m_stepsSpin->value();
    params.cfg = m_cfgSpin->value();
    params.samplerName = m_samplerEdit->text().trimmed();
    params.scheduler = m_schedulerEdit->text().trimmed();
    params.denoise = m_denoiseSpin->value();
    params.negPrompt = m_negPromptEdit->toPlainText();
    params.outputFormat = m_outputFormatCombo->currentText();
    params.host = m_hostEdit->text().trimmed();
    params.port = m_portSpin->value();

    setRunningState(true);
    m_resultEdit->clear();

    const QFuture<InferResult> future = QtConcurrent::run([this, params]() {
        return runInferenceRequest(params);
    });
    m_watcher->setFuture(future);
}

InferResult MainWindow::runInferenceRequest(const InferRequestParams &params) const
{
    InferResult result;

    QJsonArray inputImages;
    for (const QString &path : params.inputImages) {
        QImage image(path);
        if (image.isNull()) {
            result.error = QString("Failed to decode input image: %1").arg(path);
            return result;
        }

        const QSize clamped = clampResolutionKeepAspect(image.width(), image.height());
        if (clamped.width() != image.width() || clamped.height() != image.height()) {
            image = image.scaled(clamped, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }

        QByteArray encoded;
        QBuffer buffer(&encoded);
        if (!buffer.open(QIODevice::WriteOnly) || !image.save(&buffer, "PNG")) {
            result.error = QString("Failed to encode input image: %1").arg(path);
            return result;
        }
        inputImages.append(QString::fromLatin1(encoded.toBase64()));
    }

    QJsonObject req;
    req["input_images_b64"] = inputImages;
    req["target_width"] = params.noInputImages ? params.targetWidth : QJsonValue::Null;
    req["target_height"] = params.noInputImages ? params.targetHeight : QJsonValue::Null;
    req["prompt"] = params.prompt;
    req["output_format"] = params.outputFormat;
    req["seed"] = params.seed;
    req["steps"] = params.steps;
    req["cfg"] = params.cfg;
    req["sampler_name"] = params.samplerName;
    req["scheduler"] = params.scheduler;
    req["denoise"] = params.denoise;
    req["neg_prompt"] = params.negPrompt;

    QTcpSocket socket;
    socket.connectToHost(params.host, static_cast<quint16>(params.port));
    if (!socket.waitForConnected(10000)) {
        result.error = QString("Connect failed: %1").arg(socket.errorString());
        return result;
    }

    QString ioError;
    if (!sendPacket(socket, req, ioError)) {
        result.error = ioError;
        return result;
    }

    QJsonObject resp;
    if (!recvPacket(socket, resp, ioError)) {
        result.error = ioError;
        return result;
    }

    if (!resp.value("ok").toBool()) {
        result.error = QString("Server inference failed:\nerror: %1\ntraceback: %2")
                           .arg(resp.value("error").toString(), resp.value("traceback").toString("<none>"));
        return result;
    }

    const QString outputB64 = resp.value("output_image_b64").toString();
    if (outputB64.isEmpty()) {
        result.error = "Server response missing output_image_b64";
        return result;
    }

    const QByteArray imageBytes = QByteArray::fromBase64(outputB64.toLatin1());
    if (imageBytes.isEmpty()) {
        result.error = "Generated image bytes are empty";
        return result;
    }

    result.ok = true;
    result.generatedImageBytes = imageBytes;
    result.outputFormat = resp.value("output_format").toString(params.outputFormat);
    if (resp.contains("seed") && !resp.value("seed").isNull()) {
        result.seed = resp.value("seed").toVariant().toLongLong();
    } else {
        result.seed = params.seed;
    }
    result.width = resp.value("width").toInt();
    result.height = resp.value("height").toInt();
    result.ckptPath = resp.value("ckpt_path").toString();

    return result;
}
