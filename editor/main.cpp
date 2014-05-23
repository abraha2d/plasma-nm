/*
    Copyright 2013 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "connectioneditor.h"
#include "connectiondetaileditor.h"
#include <config.h>

#include <KGlobal>
#include <KIcon>
#include <KAboutData>

#include <QApplication>
#include <QUrl>
#include <QCommandLineParser>

#include <NetworkManagerQt/Settings>
#include <NetworkManagerQt/Connection>
#include <NetworkManagerQt/ConnectionSettings>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(KIcon("network-defaultroute"));

    KAboutData about("kde5-nm-connection-editor", i18n("Connection editor"),
                     PLASMA_NM_VERSION_STRING, i18n("Manage your network connections"),
                     KAboutLicense::GPL, i18n("(C) 2013-2014 Jan Grulich and Lukáš Tinkl"),
                     i18n("This application allows you to create, edit and delete network connections.\n\nUsing NM version: %1", NetworkManager::version()));
    about.addAuthor(i18n("Jan Grulich"), i18n("Developer"), "jgrulich@redhat.com");
    about.addAuthor(i18n("Lukáš Tinkl"), i18n("Developer"), "ltinkl@redhat.com");
    about.addCredit(i18n("Lamarque Souza"), i18n("libnm-qt author"), "lamarque@kde.org");
    about.addCredit(i18n("Daniel Nicoletti"), i18n("various bugfixes"), "dantti12@gmail.com");
    about.addCredit(i18n("Will Stephenson"), i18n("VPN plugins"), "wstephenson@kde.org");
    about.addCredit(i18n("Ilia Kats"), i18n("VPN plugins"), "ilia-kats@gmx.net");
    about.setProductName("plasma-nm/editor");

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    about.setupCommandLine(&parser);
    parser.addPositionalArgument("uuid", i18n("Edit connection"), "[uuid]");
    parser.addHelpOption();
    parser.addVersionOption();

#warning "Translations for kde5-nm-connection-editor disabled"
    KGlobal::locale()->insertCatalog("libplasmanm_editor");  // setting widgets
    KGlobal::locale()->insertCatalog("plasma_applet_org.kde.plasma.networkmanagement");  // mobile wizard, UiUtils, ...

    parser.process(app);

    const QStringList args = parser.positionalArguments();
    if (!args.isEmpty()) {
        NetworkManager::Connection::Ptr connection = NetworkManager::findConnectionByUuid(args.first());

        if (connection) {
            NetworkManager::ConnectionSettings::Ptr connectionSetting = connection->settings();

            ConnectionDetailEditor * editor = new ConnectionDetailEditor(connectionSetting);
            editor->show();
        } else {
            return 1;
        }
    } else {
        ConnectionEditor * editor = new ConnectionEditor();
        editor->show();
    }

    return app.exec();
}
