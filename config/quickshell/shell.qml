//@ pragma UseQApplication

import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQml.Models
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
PanelWindow {
    id: mainBarWindow
        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            left: 0
            right: 0
            top: 0
        }

        WlrLayershell.namespace: "bar"
        WlrLayershell.layer: WlrLayershell.Bottom
        implicitHeight: Appearance.barHeight 
        color: "transparent"

        // Border + Background Rectangle
        Rectangle {
            id: bar
            anchors.fill: parent
            //color: Qt.rgba(0 , 0 , 0 , 0.75)
            color: Colors.md3.background
            opacity: 0.85
            border.width: 0
            radius: 0
        }

        // Workspaces
        Rectangle {
            id: workspacesBlock
            width: workspaces.width + 45
            height: Appearance.barHeight - 8
            radius: height/2 - 4
            //color: Qt.rgba(0 , 0 , 0 , 0.2)
            color: Qt.alpha(Colors.md3.surface_container_lowest, 0.4)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 15
            Row {
                id: workspaces
                spacing: 15
                anchors.centerIn: parent
                Repeater {
                    model: 10
                    Rectangle {
                        readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)		    
                        readonly property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        readonly property bool prevOccupied: index > 0 && Hyprland.workspaces.values.find(w => w.id === index) !== undefined
                        readonly property bool nextOccupied: index < 9 && Hyprland.workspaces.values.find(w => w.id === index + 2) !== undefined
                        property bool isHovered: ms.containsMouse

                        anchors.verticalCenter: parent.verticalCenter
                        width: 10
                        height: 10
                        radius: width/2
                        color: isFocused ? Qt.rgba(1 , 1 , 1 , 0.9) : ( isHovered ? Qt.rgba(1 , 1 , 1 , 0.55) : Qt.rgba(1 , 1 , 1 , 0.2) )
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Rectangle {
                            width: 25
                            height: 25
                            radius: width/2
                            color: ws ? Qt.rgba(1 , 1 , 1 , 0.1) : "transparent"
                            anchors.centerIn: parent

                            MouseArea {
                                id: ms
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    let target = index + 1;
                                    Hyprland.dispatch(`workspace ${target}`);
                                } 
                            }


                            topLeftRadius: prevOccupied ? 0 : height/2
                            bottomLeftRadius: prevOccupied ? 0 : height/2
                            topRightRadius: nextOccupied ? 0 : height/2
                            bottomRightRadius: nextOccupied ? 0 : height/2
                        }
                    }
                }
            }
        }

        //Calendar PopUp
        PopupWindow {
            id: calweaPopup
            anchor.window: mainBarWindow
            anchor.rect.x: mainBarWindow.width / 2 - implicitWidth / 2
            anchor.rect.y: mainBarWindow.implicitHeight + 4
            implicitWidth: 700
            implicitHeight: 400
            color: "transparent"
            visible: false

            Rectangle {
                id: surfacecalweaPopup
                anchors.fill: parent
                color: Qt.alpha(Colors.md3.surface_container_lowest, 1)
                border.width: 1
                border.color: Qt.alpha(Colors.md3.primary, 0.35)
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    spacing: 4
                    Rectangle {
                        id: calendar
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 32
                        Layout.rightMargin: 0

                        Text {
                            text: "CALENDAR"
                            Layout.alignment: Qt.AlignTop
                            font.pixelSize: 14
                            font.weight: 1000
                            font.family: Globals.fontFamily
                            font.letterSpacing: 1.5
                            color: Qt.alpha(Colors.md3.primary, 0.5)
                        }
                        
                    //----
                    property date currentDate: new Date()

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: calendar.currentDate = new Date()
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 32

                        // Month and Year Header
                        Text {
                            text: Qt.formatDate(calendar.currentDate, "MMMM yyyy")
                            font.weight: 1000
                            font.pixelSize: 22
                            font.family: Globals.fontFamily
                            color: "white"
                        }

                        DayOfWeekRow {
                            locale: Qt.locale("en_GB")
                            Layout.fillWidth: true
                            Layout.bottomMargin: 4
                            Layout.topMargin: 4

                            delegate: Text {
                                required property var model
                                text: model.longName.substring(0, 2)
                                color: Qt.alpha(Colors.md3.primary, 0.5)
                                font.pixelSize: 14
                                font.family: Globals.fontFamily
                                font.weight: 700
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MonthGrid {
                            id: monthGrid
                            month: calendar.currentDate.getMonth()
                            year: calendar.currentDate.getFullYear()
                            locale: Qt.locale("en_GB")
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            delegate: Item {
                                required property var model
        
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 40
                                    height: 30
                                    radius: 8
                                    color: model.today ? Colors.md3.primary : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: model.day
                                    color: model.month === monthGrid.month ? (model.today ? Colors.md3.on_primary : "white") : Colors.md3.on_surface
                                    font.pixelSize: 14
                                    font.family: Globals.fontFamily
                                    font.weight: model.today ? 1000 : 600
                                    opacity: model.month === monthGrid.month ? 1.0 : 0.2
                                }
                            }
                        }
                    }
                    //----

                    }
                    Rectangle {
                        id: weather
                        color: "transparent"
                        //border.width: 1 //delete
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 32
                        Layout.leftMargin: 0
                    }

                }
            }
        }

        // Time
        Rectangle {
            id: timerBox
            anchors.centerIn: parent
            //color: timerClick.containsMouse ? Qt.rgba(1 , 1 , 1 , 0.05) : Qt.rgba(0 , 0 , 0 , 0.2)
            color: timerClick.containsMouse ? Qt.alpha(Colors.md3.surface_variant, 0.4) : Qt.alpha(Colors.md3.surface_container_lowest, 0.4)
            width: rowTime.width + 40
            height: Appearance.barHeight - 8
            radius: height/2 - 4

            MouseArea {
                id: timerClick
                anchors.fill: parent
                hoverEnabled: true
                onClicked: calweaPopup.visible = !calweaPopup.visible
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic 
                }
            }

            Row {
                id: rowTime
                spacing: 10
                anchors.centerIn: parent

                Text {
                    id: time
                    text: Qt.formatDateTime(new Date(), "HH:mm ddd, dd/MM")
                    color: "white"
                    font.pixelSize: 16
                    font.family: Globals.fontFamily
                    font.weight: 800
                    anchors.verticalCenter: parent.verticalCenter
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        time.text = Qt.formatDateTime(new Date(), "HH:mm ddd, dd/MM")
                    }
                }
            }
        }

        //Language Indicator
        Rectangle {
            id: langBox

            property string layoutName: "??"
            property string layoutShort: layoutName.substring(0, 2).toUpperCase()

            width: lang.width + 16
            height: Appearance.barHeight - 8
            radius: height/2 - 4
            anchors.right: trayBox.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            color: msLang.containsMouse ? Qt.alpha(Colors.md3.surface_variant, 0.4) : Qt.alpha(Colors.md3.surface_container_lowest, 0.4)

            Process {
                id: fetchLayout
                command: ["hyprctl", "devices", "-j"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const kbs = JSON.parse(this.text).keyboards
                            const main = kbs.find(k => k.main) ?? kbs[0]
                            if (main) langBox.layoutName = main.active_keymap
                        } catch(e) {}
                    }
                }
            }

            Process {
                id: switchLayout
                command: ["hyprctl", "switchxkblayout", "all", "next"]
            }

            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    if (event.name === "activelayout")
                    langBox.layoutName = event.data.split(",").pop().trim()
                }
            }

            MouseArea {
                id: msLang
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if ( mouse.button === Qt.LeftButton ) {
                        switchLayout.running = true
                    }
                    else {
                        console.log("ПКМ нажал")
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic 
                }
            }

            Text {
                id: lang
                text: langBox.layoutShort
                font.pixelSize: 16
                font.family: Globals.fontFamily
                font.weight: 800
                color: "white"
                anchors.centerIn: parent
            }
        }

        //Tray
        Rectangle {
            id: trayBox
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 15
            //color: Qt.rgba(0 , 0 , 0 , 0.2)
            color: Qt.alpha(Colors.md3.surface_container_lowest, 0.4)
            width: trays.width + 16
            height: Appearance.barHeight - 8
            radius: height/2 - 4
            visible: SystemTray.items.values.length > 0
            Row {
                id: trays
                spacing: 8
                anchors.centerIn: parent
                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        width: 24
                        height: 24
                        opacity: msTray.containsMouse ? 1 : 0.8
                        Image {
                            anchors.fill: parent
                            source: modelData.icon 
                            fillMode: Image.PreserveAspectFit
                        }

                        QsMenuAnchor {
                            id: trayMenuAnchor
                            menu: modelData.menu
                            anchor.window: mainBarWindow
                        }

                        MouseArea {
                            id: msTray
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (mouse) => {
                                console.log("--- Tray Item Debug ---")
                                console.log("ID:    ", modelData.id)
                                console.log("Title: ", modelData.title)
                                console.log("-----------------------")      
                                if ( mouse.button === Qt.LeftButton ) {
                                    modelData.activate();
                                }
                                else if ( mouse.button === Qt.RightButton ) {
                                    if ( modelData.hasMenu ) {
                                        var mappedCoords = msTray.mapToItem(mainBarWindow.contentItem, mouse.x, mouse.y);
                                        trayMenuAnchor.anchor.rect = Qt.rect(mappedCoords.x, mappedCoords.y, 0, 0);
                                        trayMenuAnchor.open();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
