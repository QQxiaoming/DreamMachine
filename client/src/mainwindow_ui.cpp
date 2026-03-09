#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "mainwindow_utils.h"
#include "aspectratiopixmaplabel.h"

#include <QComboBox>
#include <QDoubleSpinBox>
#include <QFuture>
#include <QFutureWatcher>
#include <QGridLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPushButton>
#include <QRandomGenerator>
#include <QSpinBox>
#include <QTextEdit>
#include <QVBoxLayout>

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

    m_previewLabel = new AspectRatioPixmapLabel(rightPanel);
    m_previewLabel->setMinimumHeight(220);
    m_previewLabel->setAlignment(Qt::AlignCenter);
    rightLayout->addWidget(m_previewLabel, 1);

    m_resultEdit = new QTextEdit(leftPanel);
    m_resultEdit->setReadOnly(true);
    m_resultEdit->setPlaceholderText("Result JSON will appear here...");
    leftLayout->addWidget(m_resultEdit, 1);

    rootLayout->addWidget(leftPanel, 3);
    rootLayout->addWidget(rightPanel, 2);

    SettingsMapper::Controls controls;
    controls.inputImageList = m_inputImageList;
    controls.widthSpin = m_widthSpin;
    controls.heightSpin = m_heightSpin;
    controls.promptEdit = m_promptEdit;
    controls.negPromptEdit = m_negPromptEdit;
    controls.outputDirEdit = m_outputDirEdit;
    controls.seedEdit = m_seedEdit;
    controls.stepsSpin = m_stepsSpin;
    controls.cfgSpin = m_cfgSpin;
    controls.samplerEdit = m_samplerEdit;
    controls.schedulerEdit = m_schedulerEdit;
    controls.denoiseSpin = m_denoiseSpin;
    controls.outputFormatCombo = m_outputFormatCombo;
    controls.hostEdit = m_hostEdit;
    controls.portSpin = m_portSpin;
    m_settingsMapper.bindControls(controls);

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
        obj["output_dir"] = m_settingsMapper.outputDirPath();
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
