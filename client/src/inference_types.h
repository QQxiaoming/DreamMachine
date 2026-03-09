#ifndef INFERENCE_TYPES_H
#define INFERENCE_TYPES_H

#include <QByteArray>
#include <QString>
#include <QStringList>
#include <QtGlobal>

struct InferResult {
    bool ok = false;
    QString error;
    QByteArray generatedImageBytes;
    QString outputFormat;
    qint64 seed = 0;
    int width = 0;
    int height = 0;
    QString ckptPath;
};

struct InferRequestParams {
    QStringList inputImages;
    int targetWidth = 0;
    int targetHeight = 0;
    bool noInputImages = false;
    QString prompt;
    QString outputDir;
    qint64 seed = 0;
    int steps = 4;
    double cfg = 1.0;
    QString samplerName;
    QString scheduler;
    double denoise = 1.0;
    QString negPrompt;
    QString outputFormat;
    QString host;
    int port = 17890;
};

#endif // INFERENCE_TYPES_H
