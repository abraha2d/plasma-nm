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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasmanm 0.1 as PlasmaNM

Item {
    id: toolBar;

    property bool expanded: false;

    signal toolbarExpanded();

    height: 30;

    PlasmaNM.NetworkStatus {
        id: networkStatus;

        onSetGlobalStatus: {
            statusLabel.text = status;
            progressIndicator.running = inProgress;
            if (connected) {
                statusIcon.source = "user-online";
                statusIcon.enabled = true;
            } else {
                statusIcon.source = "user-offline";
                statusIcon.enabled = false;
            }
        }
    }

    PlasmaCore.IconItem {
        id: statusIcon

        height: 30; width: 30;
        anchors { left: parent.left; bottom: parent.bottom; top: statusLabel.top; leftMargin: 5}

        PlasmaComponents.BusyIndicator {
            id: progressIndicator;

            anchors.fill: parent;
            running: false;
            visible: running;
        }
    }

    PlasmaComponents.Label {
        id: statusLabel;

        height: 30;
        anchors { left: statusIcon.right; right: toolButton.left; bottom: parent.bottom; leftMargin: 5 }
        elide: Text.ElideRight;
    }

    PlasmaCore.IconItem {
        id: toolButton;

        height: 30; width: 30;
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 5 }
        source: "configure";
    }

    OptionsWidget {
        id: options;

        anchors { left: parent.left; right: parent.right; leftMargin: 10 }
        visible: false;

        onOpenEditor: {
            if (mainWindow.autoHideOptions) {
                expanded = false;
            }
            handler.openEditor();
        }
    }

    MouseArea {
        id: toolbarMouseArea;

        anchors.fill: parent;

        onClicked: {
            hideOrShowOptions();
        }
    }

    states: [
        State {
            name: "Hidden"
            when: !expanded || !toolbar.toolbarExpandable
        },

        State {
            name: "Expanded";
            when: expanded && toolbar.toolbarExpandable;
            PropertyChanges { target: toolBar; height: options.childrenRect.height + 45 }
            PropertyChanges { target: options; visible: true }
        }
    ]

    transitions: Transition {
        NumberAnimation { duration: 300; properties: "height, visible" }
    }

    function hideOrShowOptions() {
        if (!expanded) {
            toolbarExpanded();
            expanded = !expanded;
            plasmoid.writeConfig("optionsExpanded", "expanded");
        // Toolbar may be set as expanded, but was closed from the item
        } else if (expanded && connectionView.itemExpandable == true && toolbar.toolbarExpandable == false) {
            toolbarExpanded();
            plasmoid.writeConfig("optionsExpanded", "expanded");
        } else {
            expanded = !expanded;
            plasmoid.writeConfig("optionsExpanded", "hidden");
        }
    }

    Component.onCompleted: {
        networkStatus.init();

        if (plasmoid.readConfig("optionsExpanded") == "expanded") {
            expanded = true;
            toolbarExpanded();
        }
    }
}
