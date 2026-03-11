#ifndef MOBILE_VIEW_MODEL_H
#define MOBILE_VIEW_MODEL_H

#include "image_service.h"
#include "inference_client.h"
#include "preset_storage.h"

#include <QByteArray>
#include <QFutureWatcher>
#include <QObject>
#include <QUrl>

class MobileViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList inputImages READ inputImages NOTIFY inputImagesChanged)
    Q_PROPERTY(bool hasInputImages READ hasInputImages NOTIFY inputImagesChanged)

    Q_PROPERTY(int targetWidth READ targetWidth WRITE setTargetWidth NOTIFY targetSizeChanged)
    Q_PROPERTY(int targetHeight READ targetHeight WRITE setTargetHeight NOTIFY targetSizeChanged)

    Q_PROPERTY(QString prompt READ prompt WRITE setPrompt NOTIFY promptChanged)
    Q_PROPERTY(QString negPrompt READ negPrompt WRITE setNegPrompt NOTIFY negPromptChanged)

    Q_PROPERTY(QString outputDir READ outputDir WRITE setOutputDir NOTIFY outputDirChanged)
    Q_PROPERTY(QUrl outputDirUrl READ outputDirUrl NOTIFY outputDirChanged)
    Q_PROPERTY(bool mobilePlatform READ mobilePlatform CONSTANT)
    Q_PROPERTY(QUrl picturesDirUrl READ picturesDirUrl CONSTANT)
    Q_PROPERTY(QUrl photoPickerDirUrl READ photoPickerDirUrl CONSTANT)

    Q_PROPERTY(QString seedText READ seedText WRITE setSeedText NOTIFY seedTextChanged)
    Q_PROPERTY(int steps READ steps WRITE setSteps NOTIFY stepsChanged)
    Q_PROPERTY(double cfg READ cfg WRITE setCfg NOTIFY cfgChanged)
    Q_PROPERTY(QString samplerName READ samplerName WRITE setSamplerName NOTIFY samplerNameChanged)
    Q_PROPERTY(QString scheduler READ scheduler WRITE setScheduler NOTIFY schedulerChanged)
    Q_PROPERTY(double denoise READ denoise WRITE setDenoise NOTIFY denoiseChanged)

    Q_PROPERTY(QString outputFormat READ outputFormat WRITE setOutputFormat NOTIFY outputFormatChanged)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool canSaveImage READ canSaveImage NOTIFY canSaveImageChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(QString resultText READ resultText NOTIFY resultTextChanged)
    Q_PROPERTY(QString previewImageUrl READ previewImageUrl NOTIFY previewImageUrlChanged)

public:
    explicit MobileViewModel(QObject *parent = nullptr);

    QStringList inputImages() const;
    bool hasInputImages() const;

    int targetWidth() const;
    int targetHeight() const;

    QString prompt() const;
    QString negPrompt() const;

    QString outputDir() const;
    QUrl outputDirUrl() const;
    bool mobilePlatform() const;
    QUrl picturesDirUrl() const;
    QUrl photoPickerDirUrl() const;

    QString seedText() const;
    int steps() const;
    double cfg() const;
    QString samplerName() const;
    QString scheduler() const;
    double denoise() const;

    QString outputFormat() const;
    QString host() const;
    int port() const;

    bool running() const;
    bool canSaveImage() const;
    QString statusText() const;
    QString lastError() const;
    QString resultText() const;
    QString previewImageUrl() const;

    void setTargetWidth(int value);
    void setTargetHeight(int value);
    void setPrompt(const QString &value);
    void setNegPrompt(const QString &value);
    void setOutputDir(const QString &value);
    void setSeedText(const QString &value);
    void setSteps(int value);
    void setCfg(double value);
    void setSamplerName(const QString &value);
    void setScheduler(const QString &value);
    void setDenoise(double value);
    void setOutputFormat(const QString &value);
    void setHost(const QString &value);
    void setPort(int value);

    Q_INVOKABLE bool addInputImageUrl(const QUrl &url);
    Q_INVOKABLE bool addInputImagePath(const QString &path);
    Q_INVOKABLE void removeInputImage(int index);
    Q_INVOKABLE void clearInputImages();

    Q_INVOKABLE void setOutputDirFromUrl(const QUrl &url);

    Q_INVOKABLE void runInference();
    Q_INVOKABLE void runSimpleInference();
    Q_INVOKABLE void saveGeneratedImage();
    Q_INVOKABLE void saveGeneratedImageToAlbum();
    Q_INVOKABLE void saveComparisonImage(const QUrl &originalImageUrl);
    Q_INVOKABLE void saveComparisonImageToAlbum(const QUrl &originalImageUrl);

    Q_INVOKABLE void savePresetToUrl(const QUrl &url);
    Q_INVOKABLE void loadPresetFromUrl(const QUrl &url);

signals:
    void inputImagesChanged();
    void targetSizeChanged();

    void promptChanged();
    void negPromptChanged();

    void outputDirChanged();
    void seedTextChanged();
    void stepsChanged();
    void cfgChanged();
    void samplerNameChanged();
    void schedulerChanged();
    void denoiseChanged();

    void outputFormatChanged();
    void hostChanged();
    void portChanged();

    void runningChanged();
    void canSaveImageChanged();
    void statusTextChanged();
    void lastErrorChanged();
    void resultTextChanged();
    void previewImageUrlChanged();

private:
    void refreshTargetSizeFromFirstImage();
    void setRunningState(bool value);
    bool updatePreviewImageUrl(const QByteArray &imageBytes, QString &error);
    bool buildComparisonImageBytes(const QString &originalImagePath,
                                   QByteArray &comparisonImageBytes,
                                   QString &error) const;
    QString defaultPicturesDirPath() const;

    static QString pathFromUrl(const QUrl &url);

    bool tryParseSeed(qint64 &seed, QString &error) const;
    InferRequestParams buildInferParams(qint64 effectiveSeed) const;

    QJsonObject collectPresetObject() const;
    bool applyPresetObject(const QJsonObject &preset, QString &error);

    QString defaultPresetFilePath() const;
    void autoLoadStartupPreset();

    QStringList m_inputImages;

    int m_targetWidth = 1024;
    int m_targetHeight = 1024;

    QString m_prompt;
    QString m_negPrompt;

    QString m_outputDir;

    QString m_seedText;
    int m_steps = 4;
    double m_cfg = 1.0;
    QString m_samplerName = "sa_solver";
    QString m_scheduler = "beta";
    double m_denoise = 1.0;

    QString m_outputFormat = "PNG";
    QString m_host = "127.0.0.1";
    int m_port = 17890;

    bool m_running = false;
    QString m_statusText = "Idle";
    QString m_lastError;
    QString m_resultText;
    QString m_previewImageUrl;

    QByteArray m_lastGeneratedImageBytes;
    QString m_lastGeneratedFormat;
    qint64 m_lastEffectiveSeed = 0;

    QFutureWatcher<InferResult> m_watcher;

    InferenceClient m_inferenceClient;
    PresetStorage m_presetStorage;
    ImageService m_imageService;
};

#endif // MOBILE_VIEW_MODEL_H
