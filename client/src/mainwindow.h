#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "image_service.h"
#include "inference_client.h"
#include "inference_types.h"
#include "preset_storage.h"
#include "settings_mapper.h"
#include "aspectratiopixmaplabel.h"

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
    AspectRatioPixmapLabel *m_previewLabel = nullptr;
    QLabel *m_statusLabel = nullptr;
    QFutureWatcher<InferResult> *m_watcher = nullptr;
    QByteArray m_lastGeneratedImageBytes;
    QString m_lastGeneratedFormat;
    qint64 m_lastEffectiveSeed = 0;

    InferenceClient m_inferenceClient;
    PresetStorage m_presetStorage;
    ImageService m_imageService;
    SettingsMapper m_settingsMapper;
};
#endif // MAINWINDOW_H
