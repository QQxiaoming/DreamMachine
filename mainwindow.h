#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QByteArray>
#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <QtGlobal>

class QComboBox;
class QLineEdit;
class QListWidget;
class QPushButton;
class QSpinBox;
class QDoubleSpinBox;
class QTextEdit;
template <typename T>
class QFutureWatcher;
class QLabel;

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

struct InferResult {
    bool ok = false;
    QString error;
    QByteArray generatedImageBytes;
    QString outputFormat;
    qint64 seed = 0;
    int width = 0;
    int height = 0;
    QString ckptPath;
};

struct InferRequestParams {
    QStringList inputImages;
    int targetWidth = 0;
    int targetHeight = 0;
    bool noInputImages = false;
    QString prompt;
    QString outputDir;
    qint64 seed = 0;
    int steps = 4;
    double cfg = 1.0;
    QString samplerName;
    QString scheduler;
    double denoise = 1.0;
    QString negPrompt;
    QString outputFormat;
    QString host;
    int port = 17890;
};

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    void buildUi();
    void connectSignals();
    void setRunningState(bool running);
    void refreshTargetSizeEditability();
    bool readImageSize(const QString &imagePath, int &width, int &height) const;
    void addInputImages();
    void removeSelectedImage();
    void chooseOutputDirectory();
    void saveGeneratedImage();
    void updatePreviewDisplay(const QByteArray &imageBytes);
    void savePreset();
    void loadPreset();
    void autoLoadStartupPreset();
    bool loadPresetFromFile(const QString &filePath, bool showErrors);
    QJsonObject collectPresetObject() const;
    bool applyPresetObject(const QJsonObject &preset, QString &error);
    void startInference();
    InferResult runInferenceRequest(const InferRequestParams &params) const;

    Ui::MainWindow *ui;

    QListWidget *m_inputImageList = nullptr;
    QPushButton *m_addInputButton = nullptr;
    QPushButton *m_removeInputButton = nullptr;
    QSpinBox *m_widthSpin = nullptr;
    QSpinBox *m_heightSpin = nullptr;
    QTextEdit *m_promptEdit = nullptr;
    QTextEdit *m_negPromptEdit = nullptr;
    QLineEdit *m_outputDirEdit = nullptr;
    QPushButton *m_chooseOutputDirButton = nullptr;
    QLineEdit *m_seedEdit = nullptr;
    QSpinBox *m_stepsSpin = nullptr;
    QDoubleSpinBox *m_cfgSpin = nullptr;
    QLineEdit *m_samplerEdit = nullptr;
    QLineEdit *m_schedulerEdit = nullptr;
    QDoubleSpinBox *m_denoiseSpin = nullptr;
    QComboBox *m_outputFormatCombo = nullptr;
    QLineEdit *m_hostEdit = nullptr;
    QSpinBox *m_portSpin = nullptr;
    QPushButton *m_runButton = nullptr;
    QPushButton *m_saveImageButton = nullptr;
    QPushButton *m_savePresetButton = nullptr;
    QPushButton *m_loadPresetButton = nullptr;
    QTextEdit *m_resultEdit = nullptr;
    QLabel *m_previewLabel = nullptr;
    QLabel *m_statusLabel = nullptr;
    QFutureWatcher<InferResult> *m_watcher = nullptr;
    QByteArray m_lastGeneratedImageBytes;
    QString m_lastGeneratedFormat;
    qint64 m_lastEffectiveSeed = 0;
};
#endif // MAINWINDOW_H
