#include "mainwindow_utils.h"

#include <QDir>

namespace {

constexpr int kMaxResolution = 1280;

} // namespace

QSize clampResolutionKeepAspect(int width, int height)
{
    if (width <= 0 || height <= 0) {
        return QSize(width, height);
    }

    if (width <= kMaxResolution && height <= kMaxResolution) {
        return QSize(width, height);
    }

    const double scale = qMin(static_cast<double>(kMaxResolution) / static_cast<double>(width),
                              static_cast<double>(kMaxResolution) / static_cast<double>(height));
    const int scaledW = qMax(1, qRound(static_cast<double>(width) * scale));
    const int scaledH = qMax(1, qRound(static_cast<double>(height) * scale));
    return QSize(scaledW, scaledH);
}

QString inferDefaultOutputDir()
{
    return QDir::current().absolutePath();
}

QString extensionForFormat(const QString &format)
{
    const QString fmt = format.trimmed().toUpper();
    if (fmt == "JPEG" || fmt == "JPG") {
        return "jpg";
    }
    if (fmt == "WEBP") {
        return "webp";
    }
    return "png";
}
