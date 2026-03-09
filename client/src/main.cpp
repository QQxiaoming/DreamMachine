#include "mainwindow.h"
#include "globalsetting.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_DontUseNativeDialogs);
    QApplication application(argc, argv);

    GlobalSetting settings;

    MainWindow window;
    window.show();

    return application.exec();
}
