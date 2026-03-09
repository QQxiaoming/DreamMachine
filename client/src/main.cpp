#include "globalsetting.h"

#ifdef DREAMMACHINE_MOBILE_UI
#include "mobile_view_model.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#else
#include "mainwindow.h"

#ifdef DREAMMACHINE_ENABLE_QML_PREVIEW
#include "mobile_view_model.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#endif

#include <QApplication>
#endif

int main(int argc, char *argv[])
{
#ifdef DREAMMACHINE_MOBILE_UI
    QGuiApplication application(argc, argv);

    GlobalSetting settings;
    Q_UNUSED(settings);

    MobileViewModel viewModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("viewModel", &viewModel);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return application.exec();
#else
    QApplication::setAttribute(Qt::AA_DontUseNativeDialogs);
    QApplication application(argc, argv);

    GlobalSetting settings;
    Q_UNUSED(settings);

#ifdef DREAMMACHINE_ENABLE_QML_PREVIEW
    QCommandLineParser parser;
    parser.setApplicationDescription("DreamMachine Desktop Client");
    parser.addHelpOption();

    QCommandLineOption qmlOption("qml", "Launch QML mobile UI preview instead of QWidget UI.");
    parser.addOption(qmlOption);
    parser.process(application);

    if (parser.isSet(qmlOption)) {
        MobileViewModel viewModel;

        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("viewModel", &viewModel);
        engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
        if (engine.rootObjects().isEmpty()) {
            return -1;
        }

        return application.exec();
    }
#endif

    MainWindow window;
    window.show();

    return application.exec();
#endif
}
