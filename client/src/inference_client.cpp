#include "inference_client.h"
#include "mainwindow_utils.h"

#include <QBuffer>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QTcpSocket>

#include <limits>

namespace {

bool sendPacket(QTcpSocket &socket, const QJsonObject &payload, QString &error)
{
    const QByteArray body = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (body.size() > std::numeric_limits<quint32>::max()) {
        error = "Payload is too large";
        return false;
    }

    QByteArray header(4, '\0');
    const quint32 bodyLen = static_cast<quint32>(body.size());
    header[0] = static_cast<char>((bodyLen >> 24) & 0xFF);
    header[1] = static_cast<char>((bodyLen >> 16) & 0xFF);
    header[2] = static_cast<char>((bodyLen >> 8) & 0xFF);
    header[3] = static_cast<char>(bodyLen & 0xFF);

    if (socket.write(header) != header.size() || !socket.waitForBytesWritten(5000)) {
        error = "Failed to send packet header";
        return false;
    }
    if (socket.write(body) != body.size() || !socket.waitForBytesWritten(5000)) {
        error = "Failed to send packet body";
        return false;
    }
    return true;
}

bool recvExact(QTcpSocket &socket, QByteArray &out, qsizetype count, int timeoutMs, QString &error)
{
    out.clear();
    out.reserve(count);

    while (out.size() < count) {
        if (socket.bytesAvailable() <= 0 && !socket.waitForReadyRead(timeoutMs)) {
            error = "Timed out while receiving server response";
            return false;
        }

        const QByteArray chunk = socket.read(count - out.size());
        if (chunk.isEmpty()) {
            if (socket.state() != QAbstractSocket::ConnectedState) {
                error = "Connection closed while receiving data";
                return false;
            }
            continue;
        }
        out.append(chunk);
    }

    return true;
}

bool recvPacket(QTcpSocket &socket, QJsonObject &obj, QString &error)
{
    QByteArray header;
    if (!recvExact(socket, header, 4, 120000, error)) {
        return false;
    }

    const quint32 bodyLen = (static_cast<quint32>(static_cast<unsigned char>(header[0])) << 24)
                            | (static_cast<quint32>(static_cast<unsigned char>(header[1])) << 16)
                            | (static_cast<quint32>(static_cast<unsigned char>(header[2])) << 8)
                            | static_cast<quint32>(static_cast<unsigned char>(header[3]));

    QByteArray body;
    if (!recvExact(socket, body, bodyLen, 120000, error)) {
        return false;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        error = QString("Invalid JSON response: %1").arg(parseError.errorString());
        return false;
    }

    obj = doc.object();
    return true;
}

bool encodeInputImages(const QStringList &paths, QJsonArray &encodedImages, QString &error)
{
    encodedImages = QJsonArray();
    for (const QString &path : paths) {
        QImage image(path);
        if (image.isNull()) {
            error = QString("Failed to decode input image: %1").arg(path);
            return false;
        }

        const QSize clamped = clampResolutionKeepAspect(image.width(), image.height());
        if (clamped.width() != image.width() || clamped.height() != image.height()) {
            image = image.scaled(clamped, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }

        QByteArray encoded;
        QBuffer buffer(&encoded);
        if (!buffer.open(QIODevice::WriteOnly) || !image.save(&buffer, "PNG")) {
            error = QString("Failed to encode input image: %1").arg(path);
            return false;
        }
        encodedImages.append(QString::fromLatin1(encoded.toBase64()));
    }

    return true;
}

} // namespace

InferResult InferenceClient::run(const InferRequestParams &params) const
{
    InferResult result;

    QJsonArray inputImages;
    QString imageError;
    if (!encodeInputImages(params.inputImages, inputImages, imageError)) {
        result.error = imageError;
        return result;
    }

    QJsonObject req;
    req["input_images_b64"] = inputImages;
    req["target_width"] = params.noInputImages ? params.targetWidth : QJsonValue::Null;
    req["target_height"] = params.noInputImages ? params.targetHeight : QJsonValue::Null;
    req["prompt"] = params.prompt;
    req["output_format"] = params.outputFormat;
    req["seed"] = params.seed;
    req["steps"] = params.steps;
    req["cfg"] = params.cfg;
    req["sampler_name"] = params.samplerName;
    req["scheduler"] = params.scheduler;
    req["denoise"] = params.denoise;
    req["neg_prompt"] = params.negPrompt;

    QTcpSocket socket;
    socket.connectToHost(params.host, static_cast<quint16>(params.port));
    if (!socket.waitForConnected(10000)) {
        result.error = QString("Connect failed: %1").arg(socket.errorString());
        return result;
    }

    QString ioError;
    if (!sendPacket(socket, req, ioError)) {
        result.error = ioError;
        return result;
    }

    QJsonObject resp;
    if (!recvPacket(socket, resp, ioError)) {
        result.error = ioError;
        return result;
    }

    if (!resp.value("ok").toBool()) {
        result.error = QString("Server inference failed:\nerror: %1\ntraceback: %2")
                           .arg(resp.value("error").toString(), resp.value("traceback").toString("<none>"));
        return result;
    }

    const QString outputB64 = resp.value("output_image_b64").toString();
    if (outputB64.isEmpty()) {
        result.error = "Server response missing output_image_b64";
        return result;
    }

    const QByteArray imageBytes = QByteArray::fromBase64(outputB64.toLatin1());
    if (imageBytes.isEmpty()) {
        result.error = "Generated image bytes are empty";
        return result;
    }

    result.ok = true;
    result.generatedImageBytes = imageBytes;
    result.outputFormat = resp.value("output_format").toString(params.outputFormat);
    if (resp.contains("seed") && !resp.value("seed").isNull()) {
        result.seed = resp.value("seed").toVariant().toLongLong();
    } else {
        result.seed = params.seed;
    }
    result.width = resp.value("width").toInt();
    result.height = resp.value("height").toInt();
    result.ckptPath = resp.value("ckpt_path").toString();

    return result;
}
