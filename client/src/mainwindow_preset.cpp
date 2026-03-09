#include "mainwindow.h"
#include "filedialog.h"
#include "globalsetting.h"

#include <QComboBox>
#include <QDir>
#include <QDoubleSpinBox>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QSpinBox>
#include <QTextEdit>

QJsonObject MainWindow::collectPresetObject() const
{
    return m_settingsMapper.toPresetObject();
}

bool MainWindow::applyPresetObject(const QJsonObject &preset, QString &error)
{
    if (!m_settingsMapper.applyPresetObject(preset, error)) {
        return false;
    }

    refreshTargetSizeEditability();

    return true;
}

void MainWindow::savePreset()
{  
    GlobalSetting settings;
    QString lastPath = settings.value("Global/presetPath", QDir::current().absolutePath()).toString();
    const QString filePath = FileDialog::getSaveFileName(
        this,
        "Save Preset",
        QDir(lastPath).absoluteFilePath("dreammachine_preset.json"),
        "JSON (*.json);;All files (*.*)");
    if (filePath.isEmpty()) {
        return;
    }

    QString error;
    if (!m_presetStorage.saveToFile(filePath, collectPresetObject(), error)) {
        QMessageBox::critical(this, "Save Preset Failed", error);
        return;
    }

    if (!filePath.isEmpty()) {
        settings.setValue("Global/presetPath", QFileInfo(filePath).absolutePath());
    }

    m_statusLabel->setText("Preset Saved");
}

void MainWindow::loadPreset()
{
    GlobalSetting settings;
    QString lastPath = settings.value("Global/presetPath", QDir::current().absolutePath()).toString();
    const QString filePath = FileDialog::getOpenFileName(
        this,
        "Load Preset",
        QDir(lastPath).absoluteFilePath("dreammachine_preset.json"),
        "Preset files (*.json *.png);;JSON (*.json);;PNG Images (*.png);;All files (*.*)");
    if (filePath.isEmpty()) {
        return;
    }

    loadPresetFromFile(filePath, true);

    if (!filePath.isEmpty()) {
        settings.setValue("Global/presetPath", QFileInfo(filePath).absolutePath());
    }
}

bool MainWindow::loadPresetFromFile(const QString &filePath, bool showErrors)
{
    QJsonObject preset;
    QString loadError;
    if (!m_presetStorage.loadFromFile(filePath, preset, loadError)) {
        if (showErrors) {
            QMessageBox::critical(this, "Load Preset Failed", loadError);
        }
        return false;
    }

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
    GlobalSetting settings;
    QString lastPath = settings.value("Global/presetPath", QDir::current().absolutePath()).toString();
    const QString presetPath = QDir(lastPath).absoluteFilePath("dreammachine_preset.json");
    if (!QFileInfo::exists(presetPath)) {
        return;
    }

    if (loadPresetFromFile(presetPath, false)) {
        m_statusLabel->setText("Preset Auto Loaded");
    }
}
