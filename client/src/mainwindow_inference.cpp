#include "mainwindow.h"
#include "mainwindow_utils.h"

#include <QComboBox>
#include <QDoubleSpinBox>
#include <QFuture>
#include <QFutureWatcher>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QRandomGenerator>
#include <QSpinBox>
#include <QTextEdit>
#include <QtConcurrent>

#include <limits>

void MainWindow::startInference()
{
    if (m_settingsMapper.promptText().trimmed().isEmpty()) {
        QMessageBox::warning(this, "Missing Prompt", "Prompt 不能为空。");
        return;
    }
    if (m_settingsMapper.outputDirPath().isEmpty()) {
        QMessageBox::warning(this, "Missing Output", "请指定输出目录。");
        return;
    }
    if (m_settingsMapper.inputImageCount() == 0
        && (m_settingsMapper.targetWidth() <= 0 || m_settingsMapper.targetHeight() <= 0)) {
        QMessageBox::warning(this, "Missing Size", "无输入图时必须指定 target width/height。");
        return;
    }

    qint64 seedInput = 0;
    QString seedError;
    if (!m_settingsMapper.tryParseSeed(seedInput, seedError)) {
        QMessageBox::warning(this, "Invalid Seed", "Seed 必须是整数。");
        return;
    }

    qint64 effectiveSeed = seedInput;
    if (seedInput == -1) {
        effectiveSeed = static_cast<qint64>(QRandomGenerator::global()->generate64()
                                            & static_cast<quint64>(std::numeric_limits<qint64>::max()));
    }
    m_lastEffectiveSeed = effectiveSeed;

    InferRequestParams params = m_settingsMapper.toInferRequestParams(effectiveSeed);

    {
        const QSize clampedTarget = clampResolutionKeepAspect(params.targetWidth, params.targetHeight);
        params.targetWidth = clampedTarget.width();
        params.targetHeight = clampedTarget.height();
    }

    setRunningState(true);
    m_resultEdit->clear();

    const QFuture<InferResult> future = QtConcurrent::run([this, params]() {
        return m_inferenceClient.run(params);
    });
    m_watcher->setFuture(future);
}
