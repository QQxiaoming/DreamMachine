#include "settings_mapper.h"

#include <QComboBox>
#include <QDoubleSpinBox>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonValue>
#include <QLineEdit>
#include <QListWidget>
#include <QSpinBox>
#include <QTextEdit>
#include <QVariant>
#include <QtGlobal>

namespace {

QString trimmedLineEditText(QLineEdit *edit)
{
    return edit ? edit->text().trimmed() : QString();
}

} // namespace

SettingsMapper::SettingsMapper(const Controls &controls)
    : m_controls(controls)
{
}

void SettingsMapper::bindControls(const Controls &controls)
{
    m_controls = controls;
}

QString SettingsMapper::promptText() const
{
    return m_controls.promptEdit ? m_controls.promptEdit->toPlainText() : QString();
}

QString SettingsMapper::outputDirPath() const
{
    return trimmedLineEditText(m_controls.outputDirEdit);
}

int SettingsMapper::inputImageCount() const
{
    return m_controls.inputImageList ? m_controls.inputImageList->count() : 0;
}

int SettingsMapper::targetWidth() const
{
    return m_controls.widthSpin ? m_controls.widthSpin->value() : 0;
}

int SettingsMapper::targetHeight() const
{
    return m_controls.heightSpin ? m_controls.heightSpin->value() : 0;
}

bool SettingsMapper::tryParseSeed(qint64 &seed, QString &error) const
{
    if (!m_controls.seedEdit) {
        error = "Seed control is not available";
        return false;
    }

    bool ok = false;
    const QString seedStr = m_controls.seedEdit->text().trimmed();
    const qint64 parsedSeed = seedStr.toLongLong(&ok);
    if (!ok) {
        error = "Seed must be an integer";
        return false;
    }

    seed = parsedSeed;
    return true;
}

InferRequestParams SettingsMapper::toInferRequestParams(qint64 effectiveSeed) const
{
    InferRequestParams params;
    if (m_controls.inputImageList) {
        for (int i = 0; i < m_controls.inputImageList->count(); ++i) {
            params.inputImages.append(m_controls.inputImageList->item(i)->text());
        }
    }

    params.noInputImages = params.inputImages.isEmpty();
    params.targetWidth = targetWidth();
    params.targetHeight = targetHeight();
    params.prompt = promptText();
    params.outputDir = outputDirPath();
    params.seed = effectiveSeed;
    params.steps = m_controls.stepsSpin ? m_controls.stepsSpin->value() : params.steps;
    params.cfg = m_controls.cfgSpin ? m_controls.cfgSpin->value() : params.cfg;
    params.samplerName = trimmedLineEditText(m_controls.samplerEdit);
    params.scheduler = trimmedLineEditText(m_controls.schedulerEdit);
    params.denoise = m_controls.denoiseSpin ? m_controls.denoiseSpin->value() : params.denoise;
    params.negPrompt = m_controls.negPromptEdit ? m_controls.negPromptEdit->toPlainText() : QString();
    params.outputFormat = m_controls.outputFormatCombo ? m_controls.outputFormatCombo->currentText() : QString();
    params.host = trimmedLineEditText(m_controls.hostEdit);
    params.port = m_controls.portSpin ? m_controls.portSpin->value() : params.port;

    return params;
}

QJsonObject SettingsMapper::toPresetObject() const
{
    QJsonObject preset;

    QJsonArray inputImages;
    if (m_controls.inputImageList) {
        for (int i = 0; i < m_controls.inputImageList->count(); ++i) {
            inputImages.append(m_controls.inputImageList->item(i)->text());
        }
    }

    preset["input_images"] = inputImages;
    preset["target_width"] = targetWidth();
    preset["target_height"] = targetHeight();
    preset["prompt"] = promptText();
    preset["neg_prompt"] = m_controls.negPromptEdit ? m_controls.negPromptEdit->toPlainText() : QString();
    preset["output_dir"] = outputDirPath();
    preset["seed"] = trimmedLineEditText(m_controls.seedEdit);
    preset["steps"] = m_controls.stepsSpin ? m_controls.stepsSpin->value() : 4;
    preset["cfg"] = m_controls.cfgSpin ? m_controls.cfgSpin->value() : 1.0;
    preset["sampler_name"] = trimmedLineEditText(m_controls.samplerEdit);
    preset["scheduler"] = trimmedLineEditText(m_controls.schedulerEdit);
    preset["denoise"] = m_controls.denoiseSpin ? m_controls.denoiseSpin->value() : 1.0;
    preset["output_format"] = m_controls.outputFormatCombo ? m_controls.outputFormatCombo->currentText() : QString();
    preset["host"] = trimmedLineEditText(m_controls.hostEdit);
    preset["port"] = m_controls.portSpin ? m_controls.portSpin->value() : 17890;

    return preset;
}

bool SettingsMapper::applyPresetObject(const QJsonObject &preset, QString &error) const
{
    const QJsonArray inputImages = preset.value("input_images").toArray();
    if (inputImages.size() > 4) {
        error = "Preset contains more than 4 input images";
        return false;
    }

    if (m_controls.inputImageList) {
        m_controls.inputImageList->clear();
        for (const QJsonValue &value : inputImages) {
            const QString path = value.toString().trimmed();
            if (!path.isEmpty()) {
                m_controls.inputImageList->addItem(path);
            }
        }
    }

    if (m_controls.widthSpin && preset.contains("target_width")) {
        m_controls.widthSpin->setValue(qMax(0, preset.value("target_width").toInt(m_controls.widthSpin->value())));
    }
    if (m_controls.heightSpin && preset.contains("target_height")) {
        m_controls.heightSpin->setValue(qMax(0, preset.value("target_height").toInt(m_controls.heightSpin->value())));
    }

    if (m_controls.promptEdit && preset.contains("prompt")) {
        m_controls.promptEdit->setPlainText(preset.value("prompt").toString());
    }
    if (m_controls.negPromptEdit && preset.contains("neg_prompt")) {
        m_controls.negPromptEdit->setPlainText(preset.value("neg_prompt").toString());
    }

    if (m_controls.outputDirEdit) {
        if (preset.contains("output_dir")) {
            m_controls.outputDirEdit->setText(preset.value("output_dir").toString().trimmed());
        } else if (preset.contains("output_image")) {
            const QString legacyPath = preset.value("output_image").toString().trimmed();
            if (!legacyPath.isEmpty()) {
                m_controls.outputDirEdit->setText(QFileInfo(legacyPath).absolutePath());
            }
        }
    }

    if (m_controls.seedEdit && preset.contains("seed")) {
        const QString seedStr = preset.value("seed").toVariant().toString().trimmed();
        if (!seedStr.isEmpty()) {
            m_controls.seedEdit->setText(seedStr);
        }
    }

    if (m_controls.stepsSpin && preset.contains("steps")) {
        m_controls.stepsSpin->setValue(qBound(m_controls.stepsSpin->minimum(),
                                              preset.value("steps").toInt(m_controls.stepsSpin->value()),
                                              m_controls.stepsSpin->maximum()));
    }
    if (m_controls.cfgSpin && preset.contains("cfg")) {
        m_controls.cfgSpin->setValue(qBound(m_controls.cfgSpin->minimum(),
                                            preset.value("cfg").toDouble(m_controls.cfgSpin->value()),
                                            m_controls.cfgSpin->maximum()));
    }
    if (m_controls.samplerEdit && preset.contains("sampler_name")) {
        m_controls.samplerEdit->setText(preset.value("sampler_name").toString().trimmed());
    }
    if (m_controls.schedulerEdit && preset.contains("scheduler")) {
        m_controls.schedulerEdit->setText(preset.value("scheduler").toString().trimmed());
    }
    if (m_controls.denoiseSpin && preset.contains("denoise")) {
        m_controls.denoiseSpin->setValue(qBound(m_controls.denoiseSpin->minimum(),
                                                preset.value("denoise").toDouble(m_controls.denoiseSpin->value()),
                                                m_controls.denoiseSpin->maximum()));
    }

    if (m_controls.outputFormatCombo && preset.contains("output_format")) {
        const QString outputFormat = preset.value("output_format").toString().trimmed().toUpper();
        const int index = m_controls.outputFormatCombo->findText(outputFormat);
        if (index >= 0) {
            m_controls.outputFormatCombo->setCurrentIndex(index);
        } else if (!outputFormat.isEmpty()) {
            error = QString("Preset has unsupported output_format: %1").arg(outputFormat);
            return false;
        }
    }

    if (m_controls.hostEdit && preset.contains("host")) {
        m_controls.hostEdit->setText(preset.value("host").toString().trimmed());
    }
    if (m_controls.portSpin && preset.contains("port")) {
        m_controls.portSpin->setValue(qBound(m_controls.portSpin->minimum(),
                                             preset.value("port").toInt(m_controls.portSpin->value()),
                                             m_controls.portSpin->maximum()));
    }

    return true;
}
