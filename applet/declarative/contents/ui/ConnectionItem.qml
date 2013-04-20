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
import org.kde.qtextracomponents 0.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: connectionItem;

    property bool isWireless: (itemType == 14) ? true : false;
    property bool expanded: false;

    Item {
        id: priv;
        property Item detailWidget;
    }

    signal activateConnectionItem(string connectionPath, variant devicePaths, string specificObjectParameter);
    signal addAndActivateConnectionItem(variant devicePaths, string specificObjectParameter);
    signal deactivateConnectionItem(string connectionPath);
    signal editConnectionItem(string connectionUuid);
    signal removeConnectionItem(string connectionName, string connectionPath);
    signal itemExpanded();

    height: 30;
    anchors { left: parent.left; right: parent.right }

    QIconItem {
        id: connectionTypeIcon;

        height: 30; width: 25;
        anchors { left: parent.left; top: parent.top; leftMargin: 5 }
        icon: QIcon(itemConnectionIcon);

        QIconItem {
            id: connectionSecurityIcon;
            width: 15; height: 15;
            anchors { bottom: parent.bottom; right: parent.right }
            icon: QIcon("object-locked");
            visible: itemSecure;
        }
    }

    PlasmaComponents.Label {
        id: connectionNameLabel;

        height: 30;
        anchors { left: connectionTypeIcon.right; right: connectButton.left; top: parent.top; leftMargin: 5 }
        text: itemName;
        elide: Text.ElideRight;
        font.weight: itemConnected ? Font.DemiBold : Font.Normal;
    }

    PlasmaComponents.ToolButton {
        id: connectButton;

        width: 30; height: 30;
        anchors { right: parent.right; top: parent.top; rightMargin: 5 }
        iconSource: itemConnected ? "user-online" : "user-offline";

        PlasmaComponents.BusyIndicator {
            id: connectingIndicator;
            anchors.fill: parent;
            running: itemConnecting;
            visible: running;
        }

        onClicked: {
            if (!itemConnected && !itemConnecting) {
                if (itemUuid) {
                    activateConnectionItem(itemConnectionPath, itemDevicePaths, itemSpecificParameter);
                } else {
                    addAndActivateConnectionItem(itemDevicePaths, itemSpecificParameter);
                }
            } else {
                deactivateConnectionItem(itemConnectionPath);
            }

            expanded = false;
        }
    }

    MouseArea {
        id: mouseAreaShowInfo;

        anchors {
            top: connectionItem.top;
            bottom: connectionTypeIcon.bottom;
            left: connectionItem.left;
            right: connectButton.left;
        }

        onClicked: {
            if (!expanded) {
                itemExpanded();
                expanded = !expanded;
            // Item may be set as expanded, but was closed from the toolbar
            } else if (expanded && connectionView.itemExpandable == false && toolbar.toolbarExpandable == true) {
                itemExpanded();
            } else {
                expanded = !expanded;
            }
        }
    }

    Component {
        id: detailWidgetComponent;
        DetailsWidget {

            anchors {
                left: parent.left;
                right: parent.right;
                top: connectionTypeIcon.bottom;
                bottom: parent.bottom;
                topMargin: 10;
                leftMargin: 10;
                rightMargin: 10
                bottomMargin: 5;
            }
            text: itemDetailInformations;
            editable: itemUuid == "" ? false : true;
            enableTraffic: {
                if (itemActiveDevicePath != "" && itemConnected && itemType != 11) {
                    true;
                } else {
                    false;
                }
            }
            device: itemActiveDevicePath;

            onHideDetails: {
                expanded = false;
            }

            onEditConnection: {
                connectionItem.editConnectionItem(itemUuid);
            }

            onRemoveConnection: {
                connectionItem.removeConnectionItem(itemName, itemConnectionPath);
            }
        }
    }

    states: [
        State {
            name: "Collapsed";
            when: !expanded || !connectionView.itemExpandable;
            StateChangeScript { script: if (priv.detailWidget) {priv.detailWidget.destroy()} }
        },

        State {
            name: "Details";
            when: (expanded && connectionView.itemExpandable);
            PropertyChanges { target: connectionItem; height: connectionItem.ListView.view.height }
            PropertyChanges { target: connectionItem.ListView.view; interactive: false }
            PropertyChanges { target: connectionItem.ListView.view; contentY: connectionItem.y }
            StateChangeScript { script: priv.detailWidget = detailWidgetComponent.createObject(connectionItem); }
        },

        State {
            name: "Hidden";
            when: ((!connectionView.activeExpanded && itemSection == i18n("Active connections")) ||
                   (!connectionView.previousExpanded && itemSection == i18n("Previous connections")) ||
                   (!connectionView.unknownExpanded && itemSection == i18n("Unknown connections")))
            PropertyChanges { target: connectionItem; height: 0; }
            PropertyChanges { target: connectionItem; visible: false; }
        }
    ]

    transitions: Transition {
        NumberAnimation { duration: 200; properties: "height, contentY" }
    }
}
