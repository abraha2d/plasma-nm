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

import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasmanm 0.1 as PlasmaNm
import org.kde.active.settings 0.1

Item {
    property variant selectedItemModel;

    anchors.fill: parent;

    ConnectionSettings {
        id: connectionSettings;
    }

    PlasmaExtras.ScrollArea {
        id: settingsScrollArea;

        anchors {
            left: parent.left;
            right: parent.right;
            top: parent.top;
            bottom: connectDisconnectButton.top;
            bottomMargin: 10;
        }

        flickableItem: Flickable {

            contentHeight: childrenRect.height;
            clip: true;

            Loader {
                id: connectionSettingsLoader;

                height: childrenRect.height;
                anchors {
                    left: parent.left;
                    right: parent.right;
                    top: parent.top;
                }

                onLoaded: {
                    console.log("loaded");
                    if (selectedItemModel.itemUuid) {
                        var map = [];
                        map = connectionSettings.loadSettings(selectedItemModel.itemUuid);
                        item.loadSettings(map);
                    } else {
                        item.resetSettings();
                    }
                }
            }
        }
    }

    PlasmaComponents.Button {
        anchors {
            right: connectDisconnectButton.left;
            bottom: parent.bottom;
            rightMargin: 10;
        }
        text: "Print setting";

        onClicked: {
            //TODO pass the resultingMap to NM
            //TODO add a connection type
            //TODO do a real action
            if (connectionSettingsLoader.status == Loader.Ready)
                connectionSettingsLoader.item.getSettings();
        }
    }

    PlasmaComponents.Button {
        id: connectDisconnectButton;

        anchors {
            right: parent.right;
            bottom: parent.bottom;
            rightMargin: 5;
        }
        text: {
            if (selectedItemModel) {
                if (selectedItemModel.itemConnected || selectedItemModel.itemConnecting) {
                    i18n("Disconnect");
                } else {
                    i18n("Connect");
                }
            } else {
                "";
            }
        }

        onClicked: {
            if (selectedItemModel) {
                if (!selectedItemModel.itemConnected && !selectedItemModel.itemConnecting) {
                    if (selectedItemModel.itemUuid) {
                        handler.activateConnection(selectedItemModel.itemConnectionPath, selectedItemModel.itemDevicePath, selectedItemModel.itemSpecificPath);
                    } else {
                        handler.addAndActivateConnection(selectedItemModel.itemDevicePath, selectedItemModel.itemSpecificPath);
                    }
                } else {
                    handler.deactivateConnection(selectedItemModel.itemConnectionPath);
                }
            }
        }
    }

    states: [
        State {
            id: wirelessSetting;
            when: selectedItemModel && selectedItemModel.itemType == 14;
            PropertyChanges { target: connectionSettingsLoader; source: "WirelessSetting.qml" }
        },
        State {
            id: wiredSetting;
            when: selectedItemModel && selectedItemModel.itemType == 13;
            PropertyChanges { target: connectionSettingsLoader; source: "WiredSetting.qml" }
        }
    ]

    onSelectedItemModelChanged: {
        console.log(selectedItemModel.itemName);
        if (selectedItemModel.itemUuid && connectionSettingsLoader.status == Loader.Ready) {
            var map = [];
            map = connectionSettings.loadSettings(selectedItemModel.itemUuid);
            connectionSettingsLoader.item.loadSettings(map);
        } else if (connectionSettingsLoader.status == Loader.Ready) {
            connectionSettingsLoader.item.resetSettings();
        }
    }
}
