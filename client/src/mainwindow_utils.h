#ifndef MAINWINDOW_UTILS_H
#define MAINWINDOW_UTILS_H

#include <QSize>
#include <QString>

QSize clampResolutionKeepAspect(int width, int height);
QString inferDefaultOutputDir();
QString extensionForFormat(const QString &format);

#endif // MAINWINDOW_UTILS_H
