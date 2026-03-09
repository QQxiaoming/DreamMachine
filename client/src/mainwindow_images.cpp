#include "mainwindow.h"
#include "mainwindow_utils.h"
#include "filedialog.h"
#include "globalsetting.h"

#include <QDir>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPixmap>
#include <QSpinBox>
#include <QTextEdit>

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
    if (m_imageService.readImageSize(firstImagePath, width, height)) {
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
    GlobalSetting settings;
    QString lastPath = settings.value("Global/addInputImagesPath", QDir::current().absolutePath()).toString();
    const QStringList files = FileDialog::getOpenFileNames(
        this,
        "Select Input Images",
        lastPath,
        "Images (*.png *.jpg *.jpeg *.webp *.bmp);;All files (*.*)");

    for (const QString &file : files) {
        if (m_inputImageList->count() >= 4) {
            QMessageBox::warning(this, "Input Limit", "最多支持 4 张输入图。");
            break;
        }
        m_inputImageList->addItem(file);
    }

    if (!files.isEmpty()) {
        settings.setValue("Global/addInputImagesPath", QFileInfo(files.first()).absolutePath());
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
    const QString dir = FileDialog::getExistingDirectory(
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
    QPixmap pixmap;
    QString error;
    if (!m_imageService.buildPreviewPixmap(imageBytes,
                                           pixmap,
                                           error)) {
        m_previewLabel->setText(error);
        m_previewLabel->setPixmap(QPixmap());
        return;
    }

    m_previewLabel->setPixmap(pixmap);
}

void MainWindow::saveGeneratedImage()
{
    ImageService::SaveRequest request;
    request.imageBytes = m_lastGeneratedImageBytes;
    request.outputFormat = m_lastGeneratedFormat;
    request.outputDirPath = m_settingsMapper.outputDirPath();
    request.effectiveSeed = m_lastEffectiveSeed;
    request.preset = collectPresetObject();

    const ImageService::SaveResult saveResult = m_imageService.saveGeneratedImage(request);
    if (!saveResult.ok) {
        if (m_lastGeneratedImageBytes.isEmpty()) {
            QMessageBox::warning(this, "No Image", saveResult.error);
        } else if (request.outputDirPath.isEmpty()) {
            QMessageBox::warning(this, "Missing Output Directory", saveResult.error);
        } else {
            QMessageBox::critical(this, "Save Failed", saveResult.error);
        }
        return;
    }

    m_statusLabel->setText("Saved");
    m_resultEdit->append(QString("Saved image: %1").arg(saveResult.filePath));
}
