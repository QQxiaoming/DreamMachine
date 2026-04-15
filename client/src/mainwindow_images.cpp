#include "mainwindow.h"
#include "mainwindow_utils.h"
#include "filedialog.h"
#include "globalsetting.h"

#include <QDir>
#include <QBuffer>
#include <QColor>
#include <QImage>
#include <QJsonObject>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPainter>
#include <QPixmap>
#include <QPushButton>
#include <QSpinBox>
#include <QTextEdit>

namespace {
bool buildComparisonImageBytes(const QString &originalImagePath,
                               const QByteArray &generatedImageBytes,
                               QByteArray &comparisonImageBytes,
                               QString &error)
{
    const QString normalizedOriginalPath = originalImagePath.trimmed();
    if (normalizedOriginalPath.isEmpty()) {
        error = "Original image is empty.";
        return false;
    }

    if (generatedImageBytes.isEmpty()) {
        error = "No generated image to compare. Please run inference first.";
        return false;
    }

    QImage originalImage(normalizedOriginalPath);
    if (originalImage.isNull()) {
        error = QString("Failed to load original image: %1").arg(normalizedOriginalPath);
        return false;
    }

    QImage generatedImage;
    if (!generatedImage.loadFromData(generatedImageBytes)) {
        error = "Failed to decode generated image for comparison save.";
        return false;
    }

    const QSize clampedOriginalSize = clampResolutionKeepAspect(originalImage.width(), originalImage.height());
    if (clampedOriginalSize.width() != originalImage.width() || clampedOriginalSize.height() != originalImage.height()) {
        originalImage = originalImage.scaled(clampedOriginalSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    const QSize clampedGeneratedSize = clampResolutionKeepAspect(generatedImage.width(), generatedImage.height());
    if (clampedGeneratedSize.width() != generatedImage.width() || clampedGeneratedSize.height() != generatedImage.height()) {
        generatedImage = generatedImage.scaled(clampedGeneratedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    const int targetHeight = qMax(originalImage.height(), generatedImage.height());
    if (targetHeight <= 0) {
        error = "Invalid image size for comparison.";
        return false;
    }

    QImage leftImage = originalImage;
    if (leftImage.height() != targetHeight) {
        leftImage = leftImage.scaledToHeight(targetHeight, Qt::SmoothTransformation);
    }

    QImage rightImage = generatedImage;
    if (rightImage.height() != targetHeight) {
        rightImage = rightImage.scaledToHeight(targetHeight, Qt::SmoothTransformation);
    }

    const int padding = 12;
    const int gap = 8;
    const int canvasWidth = padding + leftImage.width() + gap + rightImage.width() + padding;
    const int canvasHeight = padding + targetHeight + padding;

    QImage canvas(canvasWidth, canvasHeight, QImage::Format_ARGB32);
    canvas.fill(QColor("#111111"));

    QPainter painter(&canvas);
    painter.setRenderHint(QPainter::Antialiasing, true);

    const int imageTop = padding;
    painter.drawImage(padding, imageTop, leftImage);
    painter.drawImage(padding + leftImage.width() + gap, imageTop, rightImage);

    painter.setPen(QColor("#4a4a4a"));
    const int dividerX = padding + leftImage.width() + (gap / 2);
    painter.drawLine(dividerX, imageTop, dividerX, imageTop + targetHeight);

    comparisonImageBytes.clear();
    QBuffer buffer(&comparisonImageBytes);
    if (!buffer.open(QIODevice::WriteOnly) || !canvas.save(&buffer, "PNG")) {
        error = "Failed to encode comparison image.";
        return false;
    }

    return true;
}
}

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

    if(m_inputImageList->count() > 0) {
        const QString firstImagePath = m_inputImageList->item(0)->text();
        QFile file(firstImagePath);
        if (file.open(QIODevice::ReadOnly)) {
            const QByteArray imageBytes = file.readAll();
            updatePreviewDisplay(imageBytes);
        }
    } else {
        m_previewLabel->setText("No Image");
        m_previewLabel->setPixmap(QPixmap());
    }

    if (!files.isEmpty()) {
        settings.setValue("Global/addInputImagesPath", QFileInfo(files.first()).absolutePath());
    }

    refreshTargetSizeEditability();
    if (m_saveComparisonButton) {
        m_saveComparisonButton->setEnabled(!m_lastGeneratedImageBytes.isEmpty() && m_inputImageList->count() > 0);
    }
}

void MainWindow::removeSelectedImage()
{
    const auto selected = m_inputImageList->selectedItems();
    for (QListWidgetItem *item : selected) {
        delete m_inputImageList->takeItem(m_inputImageList->row(item));
    }

    if(m_inputImageList->count() > 0) {
        const QString firstImagePath = m_inputImageList->item(0)->text();
        QFile file(firstImagePath);
        if (file.open(QIODevice::ReadOnly)) {
            const QByteArray imageBytes = file.readAll();
            updatePreviewDisplay(imageBytes);
        }
    } else {
        m_previewLabel->setText("No Image");
        m_previewLabel->setPixmap(QPixmap());
    }

    refreshTargetSizeEditability();
    if (m_saveComparisonButton) {
        m_saveComparisonButton->setEnabled(!m_lastGeneratedImageBytes.isEmpty() && m_inputImageList->count() > 0);
    }
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

void MainWindow::saveComparisonImage()
{
    if (m_inputImageList->count() <= 0) {
        QMessageBox::warning(this, "No Input Image", "Please add an input image first.");
        return;
    }

    QByteArray comparisonImageBytes;
    QString comparisonError;
    if (!buildComparisonImageBytes(m_inputImageList->item(0)->text(),
                                   m_lastGeneratedImageBytes,
                                   comparisonImageBytes,
                                   comparisonError)) {
        QMessageBox::critical(this, "Save Compare Failed", comparisonError);
        return;
    }

    ImageService::SaveRequest request;
    request.imageBytes = comparisonImageBytes;
    request.outputFormat = "PNG";
    request.outputDirPath = m_settingsMapper.outputDirPath();
    request.effectiveSeed = m_lastEffectiveSeed;
    request.preset = collectPresetObject();

    const ImageService::SaveResult saveResult = m_imageService.saveGeneratedImage(request);
    if (!saveResult.ok) {
        if (request.outputDirPath.isEmpty()) {
            QMessageBox::warning(this, "Missing Output Directory", saveResult.error);
        } else {
            QMessageBox::critical(this, "Save Compare Failed", saveResult.error);
        }
        return;
    }

    m_statusLabel->setText("Saved Compare");
    m_resultEdit->append(QString("Saved comparison image: %1").arg(saveResult.filePath));
}
