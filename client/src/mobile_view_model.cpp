#include "mobile_view_model.h"

#include "globalsetting.h"
#include "ios_photo_library.h"
#include "mainwindow_utils.h"

#include <QDir>
#include <QFileInfo>
#include <QFuture>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QRandomGenerator>
#include <QStringList>
#include <QStandardPaths>
#include <QtConcurrent>

#include <limits>

namespace {

constexpr int kMaxInputImages = 4;

bool setStringIfChanged(QString &field, const QString &value)
{
    if (field == value) {
        return false;
    }
    field = value;
    return true;
}

QUrl locationStringToUrl(const QString &value)
{
    const QString trimmed = value.trimmed();
    if (trimmed.isEmpty()) {
        return QUrl();
    }

    const QUrl asUrl(trimmed);
    if (asUrl.isValid() && !asUrl.scheme().isEmpty()) {
        return asUrl;
    }

    return QUrl::fromLocalFile(trimmed);
}

} // namespace

MobileViewModel::MobileViewModel(QObject *parent)
    : QObject(parent)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    m_outputDir = defaultPicturesDirPath();
#else
    m_outputDir = inferDefaultOutputDir();
#endif
    m_seedText = QString::number(QRandomGenerator::global()->generate());

    connect(&m_watcher, &QFutureWatcher<InferResult>::finished, this, [this]() {
        const InferResult result = m_watcher.result();
        setRunningState(false);

        if (!result.ok) {
            m_statusText = "Failed";
            emit statusTextChanged();

            if (setStringIfChanged(m_lastError, result.error)) {
                emit lastErrorChanged();
            }
            return;
        }

        m_lastGeneratedImageBytes = result.generatedImageBytes;
        m_lastGeneratedFormat = result.outputFormat;
        m_lastEffectiveSeed = result.seed;

        QString previewError;
        if (updatePreviewImageUrl(result.generatedImageBytes, previewError)) {
            if (setStringIfChanged(m_lastError, QString())) {
                emit lastErrorChanged();
            }
            m_statusText = "Done (Preview)";
            emit statusTextChanged();
        } else {
            if (setStringIfChanged(m_lastError, previewError)) {
                emit lastErrorChanged();
            }
            m_statusText = "Done (No Preview)";
            emit statusTextChanged();
        }

        QJsonObject summary;
        summary["ok"] = true;
        summary["output_dir"] = m_outputDir;
        summary["preview_ready"] = !m_previewImageUrl.isEmpty();
        summary["output_format"] = result.outputFormat;
        summary["seed"] = QString::number(result.seed);
        summary["width"] = result.width;
        summary["height"] = result.height;
        summary["ckpt_path"] = result.ckptPath;

        m_resultText = QString::fromUtf8(QJsonDocument(summary).toJson(QJsonDocument::Indented));
        emit resultTextChanged();
        emit canSaveImageChanged();
    });

    autoLoadStartupPreset();
}

QStringList MobileViewModel::inputImages() const
{
    return m_inputImages;
}

bool MobileViewModel::hasInputImages() const
{
    return !m_inputImages.isEmpty();
}

int MobileViewModel::targetWidth() const
{
    return m_targetWidth;
}

int MobileViewModel::targetHeight() const
{
    return m_targetHeight;
}

QString MobileViewModel::prompt() const
{
    return m_prompt;
}

QString MobileViewModel::negPrompt() const
{
    return m_negPrompt;
}

QString MobileViewModel::outputDir() const
{
    return m_outputDir;
}

QUrl MobileViewModel::outputDirUrl() const
{
    if (m_outputDir.isEmpty()) {
        return QUrl();
    }
    return QUrl::fromLocalFile(m_outputDir);
}

bool MobileViewModel::mobilePlatform() const
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return true;
#else
    return false;
#endif
}

QUrl MobileViewModel::picturesDirUrl() const
{
    QString dirPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    if (dirPath.trimmed().isEmpty()) {
        dirPath = inferDefaultOutputDir();
    }
    if (dirPath.isEmpty()) {
        return QUrl();
    }
    return QUrl::fromLocalFile(dirPath);
}

QUrl MobileViewModel::photoPickerDirUrl() const
{
#if defined(Q_OS_IOS)
    const QStringList locations = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    for (auto it = locations.crbegin(); it != locations.crend(); ++it) {
        const QUrl candidate = locationStringToUrl(*it);
        if (candidate.isValid() && !candidate.isEmpty()) {
            return candidate;
        }
    }
#endif
    return picturesDirUrl();
}

QString MobileViewModel::seedText() const
{
    return m_seedText;
}

int MobileViewModel::steps() const
{
    return m_steps;
}

double MobileViewModel::cfg() const
{
    return m_cfg;
}

QString MobileViewModel::samplerName() const
{
    return m_samplerName;
}

QString MobileViewModel::scheduler() const
{
    return m_scheduler;
}

double MobileViewModel::denoise() const
{
    return m_denoise;
}

QString MobileViewModel::outputFormat() const
{
    return m_outputFormat;
}

QString MobileViewModel::host() const
{
    return m_host;
}

int MobileViewModel::port() const
{
    return m_port;
}

bool MobileViewModel::running() const
{
    return m_running;
}

bool MobileViewModel::canSaveImage() const
{
    return !m_running && !m_lastGeneratedImageBytes.isEmpty();
}

QString MobileViewModel::statusText() const
{
    return m_statusText;
}

QString MobileViewModel::lastError() const
{
    return m_lastError;
}

QString MobileViewModel::resultText() const
{
    return m_resultText;
}

QString MobileViewModel::previewImageUrl() const
{
    return m_previewImageUrl;
}

void MobileViewModel::setTargetWidth(int value)
{
    if (hasInputImages()) {
        return;
    }

    const int bounded = qBound(0, value, 16384);
    if (bounded == m_targetWidth) {
        return;
    }

    m_targetWidth = bounded;
    emit targetSizeChanged();
}

void MobileViewModel::setTargetHeight(int value)
{
    if (hasInputImages()) {
        return;
    }

    const int bounded = qBound(0, value, 16384);
    if (bounded == m_targetHeight) {
        return;
    }

    m_targetHeight = bounded;
    emit targetSizeChanged();
}

void MobileViewModel::setPrompt(const QString &value)
{
    if (!setStringIfChanged(m_prompt, value)) {
        return;
    }
    emit promptChanged();
}

void MobileViewModel::setNegPrompt(const QString &value)
{
    if (!setStringIfChanged(m_negPrompt, value)) {
        return;
    }
    emit negPromptChanged();
}

void MobileViewModel::setOutputDir(const QString &value)
{
    const QString trimmed = value.trimmed();
    if (!setStringIfChanged(m_outputDir, trimmed)) {
        return;
    }
    emit outputDirChanged();
}

void MobileViewModel::setSeedText(const QString &value)
{
    if (!setStringIfChanged(m_seedText, value.trimmed())) {
        return;
    }
    emit seedTextChanged();
}

void MobileViewModel::setSteps(int value)
{
    const int bounded = qBound(1, value, 500);
    if (bounded == m_steps) {
        return;
    }

    m_steps = bounded;
    emit stepsChanged();
}

void MobileViewModel::setCfg(double value)
{
    const double bounded = qBound(0.0, value, 100.0);
    if (qFuzzyCompare(1.0 + bounded, 1.0 + m_cfg)) {
        return;
    }

    m_cfg = bounded;
    emit cfgChanged();
}

void MobileViewModel::setSamplerName(const QString &value)
{
    if (!setStringIfChanged(m_samplerName, value.trimmed())) {
        return;
    }
    emit samplerNameChanged();
}

void MobileViewModel::setScheduler(const QString &value)
{
    if (!setStringIfChanged(m_scheduler, value.trimmed())) {
        return;
    }
    emit schedulerChanged();
}

void MobileViewModel::setDenoise(double value)
{
    const double bounded = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(1.0 + bounded, 1.0 + m_denoise)) {
        return;
    }

    m_denoise = bounded;
    emit denoiseChanged();
}

void MobileViewModel::setOutputFormat(const QString &value)
{
    const QString upper = value.trimmed().toUpper();
    if (!setStringIfChanged(m_outputFormat, upper.isEmpty() ? QString("PNG") : upper)) {
        return;
    }
    emit outputFormatChanged();
}

void MobileViewModel::setHost(const QString &value)
{
    if (!setStringIfChanged(m_host, value.trimmed())) {
        return;
    }
    emit hostChanged();
}

void MobileViewModel::setPort(int value)
{
    const int bounded = qBound(1, value, 65535);
    if (bounded == m_port) {
        return;
    }

    m_port = bounded;
    emit portChanged();
}

bool MobileViewModel::addInputImageUrl(const QUrl &url)
{
    return addInputImagePath(pathFromUrl(url));
}

bool MobileViewModel::addInputImagePath(const QString &path)
{
    const QString normalizedPath = path.trimmed();
    if (normalizedPath.isEmpty()) {
        if (setStringIfChanged(m_lastError, "Input image path is empty.")) {
            emit lastErrorChanged();
        }
        return false;
    }

    if (m_inputImages.size() >= kMaxInputImages) {
        if (setStringIfChanged(m_lastError, "At most 4 input images are supported.")) {
            emit lastErrorChanged();
        }
        m_statusText = "Input Limit";
        emit statusTextChanged();
        return false;
    }

    m_inputImages.append(normalizedPath);
    emit inputImagesChanged();

    GlobalSetting settings;
    settings.setValue("Global/addInputImagesPath", QFileInfo(normalizedPath).absolutePath());

    refreshTargetSizeFromFirstImage();

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    return true;
}

void MobileViewModel::removeInputImage(int index)
{
    if (index < 0 || index >= m_inputImages.size()) {
        return;
    }

    m_inputImages.removeAt(index);
    emit inputImagesChanged();

    if (!hasInputImages()) {
        emit targetSizeChanged();
    } else {
        refreshTargetSizeFromFirstImage();
    }
}

void MobileViewModel::clearInputImages()
{
    if (m_inputImages.isEmpty()) {
        return;
    }

    m_inputImages.clear();
    emit inputImagesChanged();
    emit targetSizeChanged();
}

void MobileViewModel::setOutputDirFromUrl(const QUrl &url)
{
    setOutputDir(pathFromUrl(url));
}

void MobileViewModel::runInference()
{
    if (m_running) {
        return;
    }

    if (mobilePlatform() && m_outputDir.trimmed().isEmpty()) {
        m_outputDir = defaultPicturesDirPath();
        emit outputDirChanged();
    }

    if (m_prompt.trimmed().isEmpty()) {
        if (setStringIfChanged(m_lastError, "Prompt cannot be empty.")) {
            emit lastErrorChanged();
        }
        m_statusText = "Missing Prompt";
        emit statusTextChanged();
        return;
    }

    if (m_outputDir.trimmed().isEmpty()) {
        if (setStringIfChanged(m_lastError, "Please set an output directory.")) {
            emit lastErrorChanged();
        }
        m_statusText = "Missing Output";
        emit statusTextChanged();
        return;
    }

    if (m_inputImages.isEmpty() && (m_targetWidth <= 0 || m_targetHeight <= 0)) {
        if (setStringIfChanged(m_lastError, "Target width/height are required when no input image is selected.")) {
            emit lastErrorChanged();
        }
        m_statusText = "Missing Size";
        emit statusTextChanged();
        return;
    }

    qint64 seedInput = 0;
    QString seedError;
    if (!tryParseSeed(seedInput, seedError)) {
        if (setStringIfChanged(m_lastError, seedError)) {
            emit lastErrorChanged();
        }
        m_statusText = "Invalid Seed";
        emit statusTextChanged();
        return;
    }

    qint64 effectiveSeed = seedInput;
    if (seedInput == -1) {
        effectiveSeed = static_cast<qint64>(QRandomGenerator::global()->generate64()
                                            & static_cast<quint64>(std::numeric_limits<qint64>::max()));
    }

    InferRequestParams params = buildInferParams(effectiveSeed);
    const QSize clamped = clampResolutionKeepAspect(params.targetWidth, params.targetHeight);
    params.targetWidth = clamped.width();
    params.targetHeight = clamped.height();

    m_resultText.clear();
    emit resultTextChanged();

    setRunningState(true);

    const QFuture<InferResult> future = QtConcurrent::run([this, params]() {
        return m_inferenceClient.run(params);
    });
    m_watcher.setFuture(future);
}

void MobileViewModel::saveGeneratedImage()
{
    ImageService::SaveRequest request;
    request.imageBytes = m_lastGeneratedImageBytes;
    request.outputFormat = m_lastGeneratedFormat.isEmpty() ? m_outputFormat : m_lastGeneratedFormat;
    request.outputDirPath = m_outputDir;
    request.effectiveSeed = m_lastEffectiveSeed;
    request.preset = collectPresetObject();

    const ImageService::SaveResult saveResult = m_imageService.saveGeneratedImage(request);
    if (!saveResult.ok) {
        if (setStringIfChanged(m_lastError, saveResult.error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Save Failed";
        emit statusTextChanged();
        return;
    }

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    m_statusText = "Saved";
    emit statusTextChanged();

    if (!m_resultText.isEmpty()) {
        m_resultText.append('\n');
    }
    m_resultText.append(QString("Saved image: %1").arg(saveResult.filePath));
    emit resultTextChanged();
}

void MobileViewModel::saveGeneratedImageToAlbum()
{
#if defined(Q_OS_IOS)
    const IosPhotoLibrarySaveResult iosSaveResult = saveImageBytesToPhotoLibrary(m_lastGeneratedImageBytes);
    if (!iosSaveResult.ok) {
        if (setStringIfChanged(m_lastError, iosSaveResult.error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Save Failed";
        emit statusTextChanged();
        return;
    }

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    m_statusText = "Saved To Album";
    emit statusTextChanged();

    if (!m_resultText.isEmpty()) {
        m_resultText.append('\n');
    }

    if (iosSaveResult.assetLocalIdentifier.isEmpty()) {
        m_resultText.append("Saved image to iOS Photos.");
    } else {
        m_resultText.append(QString("Saved image to iOS Photos: %1").arg(iosSaveResult.assetLocalIdentifier));
    }
    emit resultTextChanged();
#else

    const QString albumDirPath = defaultPicturesDirPath();
    if (albumDirPath.isEmpty()) {
        if (setStringIfChanged(m_lastError, "Cannot resolve pictures directory for album save.")) {
            emit lastErrorChanged();
        }
        m_statusText = "Save Failed";
        emit statusTextChanged();
        return;
    }

    ImageService::SaveRequest request;
    request.imageBytes = m_lastGeneratedImageBytes;
    request.outputFormat = m_lastGeneratedFormat.isEmpty() ? m_outputFormat : m_lastGeneratedFormat;
    request.outputDirPath = albumDirPath;
    request.effectiveSeed = m_lastEffectiveSeed;
    request.preset = collectPresetObject();

    const ImageService::SaveResult saveResult = m_imageService.saveGeneratedImage(request);
    if (!saveResult.ok) {
        if (setStringIfChanged(m_lastError, saveResult.error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Save Failed";
        emit statusTextChanged();
        return;
    }

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    m_statusText = "Saved To Album";
    emit statusTextChanged();

    if (!m_resultText.isEmpty()) {
        m_resultText.append('\n');
    }
    m_resultText.append(QString("Saved image: %1").arg(saveResult.filePath));
    emit resultTextChanged();
#endif
}

void MobileViewModel::savePresetToUrl(const QUrl &url)
{
    QString filePath = pathFromUrl(url);
    if (filePath.isEmpty()) {
        if (setStringIfChanged(m_lastError, "Preset path is empty.")) {
            emit lastErrorChanged();
        }
        return;
    }

    if (QFileInfo(filePath).suffix().isEmpty()) {
        filePath += ".json";
    }

    QString error;
    if (!m_presetStorage.saveToFile(filePath, collectPresetObject(), error)) {
        if (setStringIfChanged(m_lastError, error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Save Preset Failed";
        emit statusTextChanged();
        return;
    }

    GlobalSetting settings;
    settings.setValue("Global/presetPath", QFileInfo(filePath).absolutePath());

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    m_statusText = "Preset Saved";
    emit statusTextChanged();
}

void MobileViewModel::loadPresetFromUrl(const QUrl &url)
{
    const QString filePath = pathFromUrl(url);
    if (filePath.isEmpty()) {
        if (setStringIfChanged(m_lastError, "Preset path is empty.")) {
            emit lastErrorChanged();
        }
        return;
    }

    QJsonObject preset;
    QString error;
    if (!m_presetStorage.loadFromFile(filePath, preset, error)) {
        if (setStringIfChanged(m_lastError, error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Load Preset Failed";
        emit statusTextChanged();
        return;
    }

    if (!applyPresetObject(preset, error)) {
        if (setStringIfChanged(m_lastError, error)) {
            emit lastErrorChanged();
        }
        m_statusText = "Load Preset Failed";
        emit statusTextChanged();
        return;
    }

    GlobalSetting settings;
    settings.setValue("Global/presetPath", QFileInfo(filePath).absolutePath());

    if (setStringIfChanged(m_lastError, QString())) {
        emit lastErrorChanged();
    }

    m_statusText = "Preset Loaded";
    emit statusTextChanged();
}

void MobileViewModel::refreshTargetSizeFromFirstImage()
{
    if (m_inputImages.isEmpty()) {
        return;
    }

    int width = 0;
    int height = 0;
    if (!m_imageService.readImageSize(m_inputImages.first(), width, height)) {
        return;
    }

    const QSize clamped = clampResolutionKeepAspect(width, height);
    if (clamped.width() == m_targetWidth && clamped.height() == m_targetHeight) {
        return;
    }

    m_targetWidth = clamped.width();
    m_targetHeight = clamped.height();
    emit targetSizeChanged();
}

void MobileViewModel::setRunningState(bool value)
{
    if (m_running == value) {
        return;
    }

    m_running = value;
    emit runningChanged();
    emit canSaveImageChanged();

    m_statusText = m_running ? "Running..." : m_statusText;
    emit statusTextChanged();
}

QString MobileViewModel::pathFromUrl(const QUrl &url)
{
    if (!url.isValid()) {
        return QString();
    }

    if (url.isLocalFile()) {
        return url.toLocalFile();
    }

    const QString raw = url.toString().trimmed();
    if (raw.startsWith("file://")) {
        return QUrl(raw).toLocalFile();
    }

    return raw;
}

bool MobileViewModel::updatePreviewImageUrl(const QByteArray &imageBytes, QString &error)
{
    if (imageBytes.isEmpty()) {
        error = "Preview unavailable: generated image bytes are empty.";
        return false;
    }

    QImage image;
    if (!image.loadFromData(imageBytes)) {
        error = "Preview unavailable: cannot decode generated image.";
        return false;
    }

    const QString tempRoot = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    if (tempRoot.isEmpty()) {
        error = "Preview unavailable: temporary directory is not accessible.";
        return false;
    }

    QDir rootDir(tempRoot);
    const QString previewDirName = "dreammachine_preview";
    if (!rootDir.exists(previewDirName) && !rootDir.mkpath(previewDirName)) {
        error = QString("Preview unavailable: cannot create temp preview directory: %1")
                    .arg(rootDir.filePath(previewDirName));
        return false;
    }

    const QString previewFilePath = QDir(rootDir.filePath(previewDirName)).filePath("latest_preview.png");
    if (!image.save(previewFilePath, "PNG")) {
        error = QString("Preview unavailable: cannot write temp preview file: %1")
                    .arg(previewFilePath);
        return false;
    }

    const QString previewUrl = QUrl::fromLocalFile(previewFilePath).toString();
    if (m_previewImageUrl == previewUrl) {
        m_previewImageUrl.clear();
        emit previewImageUrlChanged();
    }
    m_previewImageUrl = previewUrl;
    emit previewImageUrlChanged();

    return true;
}

QString MobileViewModel::defaultPicturesDirPath() const
{
    QString picturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    if (picturesPath.trimmed().isEmpty()) {
        picturesPath = inferDefaultOutputDir();
    }

    return QDir(picturesPath).filePath("DreamMachine");
}

bool MobileViewModel::tryParseSeed(qint64 &seed, QString &error) const
{
    bool ok = false;
    const qint64 parsed = m_seedText.trimmed().toLongLong(&ok);
    if (!ok) {
        error = "Seed must be an integer.";
        return false;
    }

    seed = parsed;
    return true;
}

InferRequestParams MobileViewModel::buildInferParams(qint64 effectiveSeed) const
{
    InferRequestParams params;
    params.inputImages = m_inputImages;
    params.noInputImages = m_inputImages.isEmpty();
    params.targetWidth = m_targetWidth;
    params.targetHeight = m_targetHeight;
    params.prompt = m_prompt;
    params.negPrompt = m_negPrompt;
    params.outputDir = m_outputDir;
    params.seed = effectiveSeed;
    params.steps = m_steps;
    params.cfg = m_cfg;
    params.samplerName = m_samplerName;
    params.scheduler = m_scheduler;
    params.denoise = m_denoise;
    params.outputFormat = m_outputFormat;
    params.host = m_host;
    params.port = m_port;
    return params;
}

QJsonObject MobileViewModel::collectPresetObject() const
{
    QJsonObject preset;

    QJsonArray images;
    for (const QString &path : m_inputImages) {
        images.append(path);
    }

    preset["input_images"] = images;
    preset["target_width"] = m_targetWidth;
    preset["target_height"] = m_targetHeight;
    preset["prompt"] = m_prompt;
    preset["neg_prompt"] = m_negPrompt;
    preset["output_dir"] = m_outputDir;
    preset["seed"] = m_seedText;
    preset["steps"] = m_steps;
    preset["cfg"] = m_cfg;
    preset["sampler_name"] = m_samplerName;
    preset["scheduler"] = m_scheduler;
    preset["denoise"] = m_denoise;
    preset["output_format"] = m_outputFormat;
    preset["host"] = m_host;
    preset["port"] = m_port;

    return preset;
}

bool MobileViewModel::applyPresetObject(const QJsonObject &preset, QString &error)
{
    const QJsonArray inputImages = preset.value("input_images").toArray();
    if (inputImages.size() > kMaxInputImages) {
        error = "Preset contains more than 4 input images.";
        return false;
    }

    QStringList images;
    for (const QJsonValue &value : inputImages) {
        const QString path = value.toString().trimmed();
        if (!path.isEmpty()) {
            images.append(path);
        }
    }

    const int nextWidth = qMax(0, preset.value("target_width").toInt(m_targetWidth));
    const int nextHeight = qMax(0, preset.value("target_height").toInt(m_targetHeight));

    m_inputImages = images;
    emit inputImagesChanged();

    m_targetWidth = nextWidth;
    m_targetHeight = nextHeight;
    emit targetSizeChanged();

    setPrompt(preset.value("prompt").toString(m_prompt));
    setNegPrompt(preset.value("neg_prompt").toString(m_negPrompt));

    if (preset.contains("output_dir")) {
        setOutputDir(preset.value("output_dir").toString());
    }

    if (preset.contains("seed")) {
        setSeedText(preset.value("seed").toVariant().toString());
    }

    if (preset.contains("steps")) {
        setSteps(preset.value("steps").toInt(m_steps));
    }

    if (preset.contains("cfg")) {
        setCfg(preset.value("cfg").toDouble(m_cfg));
    }

    if (preset.contains("sampler_name")) {
        setSamplerName(preset.value("sampler_name").toString(m_samplerName));
    }

    if (preset.contains("scheduler")) {
        setScheduler(preset.value("scheduler").toString(m_scheduler));
    }

    if (preset.contains("denoise")) {
        setDenoise(preset.value("denoise").toDouble(m_denoise));
    }

    if (preset.contains("output_format")) {
        setOutputFormat(preset.value("output_format").toString(m_outputFormat));
    }

    if (preset.contains("host")) {
        setHost(preset.value("host").toString(m_host));
    }

    if (preset.contains("port")) {
        setPort(preset.value("port").toInt(m_port));
    }

    refreshTargetSizeFromFirstImage();
    return true;
}

QString MobileViewModel::defaultPresetFilePath() const
{
    GlobalSetting settings;
    const QString lastPath = settings.value("Global/presetPath", QDir::current().absolutePath()).toString();
    return QDir(lastPath).absoluteFilePath("dreammachine_preset.json");
}

void MobileViewModel::autoLoadStartupPreset()
{
    const QString presetPath = defaultPresetFilePath();
    if (!QFileInfo::exists(presetPath)) {
        return;
    }

    QJsonObject preset;
    QString error;
    if (!m_presetStorage.loadFromFile(presetPath, preset, error)) {
        return;
    }

    if (!applyPresetObject(preset, error)) {
        return;
    }

    m_statusText = "Preset Auto Loaded";
    emit statusTextChanged();
}
