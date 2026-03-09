#ifndef SETTINGS_MAPPER_H
#define SETTINGS_MAPPER_H

#include "inference_types.h"

#include <QJsonObject>
#include <QString>

class QComboBox;
class QDoubleSpinBox;
class QLineEdit;
class QListWidget;
class QSpinBox;
class QTextEdit;

class SettingsMapper
{
public:
    struct Controls {
        QListWidget *inputImageList = nullptr;
        QSpinBox *widthSpin = nullptr;
        QSpinBox *heightSpin = nullptr;
        QTextEdit *promptEdit = nullptr;
        QTextEdit *negPromptEdit = nullptr;
        QLineEdit *outputDirEdit = nullptr;
        QLineEdit *seedEdit = nullptr;
        QSpinBox *stepsSpin = nullptr;
        QDoubleSpinBox *cfgSpin = nullptr;
        QLineEdit *samplerEdit = nullptr;
        QLineEdit *schedulerEdit = nullptr;
        QDoubleSpinBox *denoiseSpin = nullptr;
        QComboBox *outputFormatCombo = nullptr;
        QLineEdit *hostEdit = nullptr;
        QSpinBox *portSpin = nullptr;
    };

    SettingsMapper() = default;
    explicit SettingsMapper(const Controls &controls);

    void bindControls(const Controls &controls);

    QString promptText() const;
    QString outputDirPath() const;
    int inputImageCount() const;
    int targetWidth() const;
    int targetHeight() const;

    bool tryParseSeed(qint64 &seed, QString &error) const;
    InferRequestParams toInferRequestParams(qint64 effectiveSeed) const;

    QJsonObject toPresetObject() const;
    bool applyPresetObject(const QJsonObject &preset, QString &error) const;

private:
    Controls m_controls;
};

#endif // SETTINGS_MAPPER_H
