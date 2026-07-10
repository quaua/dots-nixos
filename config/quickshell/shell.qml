//@ pragma UseQApplication

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQml.Models
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Controls

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
        WlrLayershell.layer: WlrLayershell.Top
        implicitHeight: Appearance.barHeight 
        color: "transparent"

        Rectangle {
            id: bar
            anchors.fill: parent
            color: Colors.md3.background
            opacity: 0.6
        }

        // Workspaces
        Rectangle {
            id: workspacesBlock
            width: workspaces.width + 45
            height: Appearance.barHeight - 8
            radius: height/2 - 4
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
        PanelWindow {
            id: calweaPopup
            WlrLayershell.namespace: "calweaPopup"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            anchors.top: true
            margins.top: mainBarWindow.implicitHeight + 8
            margins.left: mainBarWindow.width / 2 - implicitWidth / 2
            implicitWidth: 700
            implicitHeight: 400
            color: "transparent"
            visible: false

            onVisibleChanged: {
                if (visible) {
                    calendar.monthOffset = 0
                    calendar.updateCalendarGrid();
                }
            }

            Rectangle {
                id: surfacecalweaPopup
                anchors.fill: parent
                color: Qt.alpha(Colors.md3.surface_container_lowest, 0.8)
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    spacing: 16
                    Rectangle {
                        property var currentTime: new Date()
                        property int monthOffset: 0
                        property string targetMonthName: ""

                        id: calendar
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 32
                        Layout.rightMargin: 0

                        RowLayout {
                            id: navButtons
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 25
                            spacing: 8
                            Repeater {
                                model: [
                                    { label: "<", value: -1 },
                                    { label: ">", value: 1 },
                                ]
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 8
                                    color: msButton.containsMouse ? Colors.md3.primary : Qt.alpha(Colors.md3.primary, 0.06)
                                    border.width: 1
                                    border.color: Qt.alpha(Colors.md3.primary, 0.1)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                            easing.type: Easing.OutCubic 
                                        }
                                    }

                                    MouseArea {
                                        id: msButton
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        onClicked: {
                                            calendar.monthOffset += modelData.value
                                            calendar.updateCalendarGrid();
                                        }

                                        Text {
                                            text: modelData.label
                                            anchors.centerIn: parent
                                            font.pixelSize: 16
                                            font.weight: 500
                                            font.family: Globals.fontFamily
                                            color: msButton.containsMouse ? Colors.md3.on_primary : Qt.alpha(Colors.md3.primary, 0.6)

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 200
                                                    easing.type: Easing.OutCubic 
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: "CALENDAR"
                            font.pixelSize: 14
                            font.weight: 1000
                            font.family: Globals.fontFamily
                            font.letterSpacing: 1.5
                            color: Qt.alpha(Colors.md3.primary, 0.5)
                        }

                        Component.onCompleted: {
                            calendar.updateCalendarGrid();
                        }

                        function updateCalendarGrid() {
                            let d = new Date(); //current time
                            d.setDate(1); // set day as 1st day for d variable
                            d.setMonth(d.getMonth() + calendar.monthOffset); // set month with offset for d variable

                            let targetMonth = d.getMonth();
                            let targetYear = d.getFullYear();

                            let actualToday = new Date();
                            let isRealCurrentMonth = (actualToday.getMonth() === targetMonth && actualToday.getFullYear() === targetYear);
                            let todayDate = actualToday.getDate();

                            calendar.targetMonthName = Qt.formatDateTime(d, "MMMM yyyy");

                            let firstDay = new Date(targetYear, targetMonth, 1).getDay();
                            firstDay = (firstDay === 0) ? 6 : firstDay - 1; 

                            let daysInMonth = new Date(targetYear, targetMonth + 1, 0).getDate();
                            let daysInPrevMonth = new Date(targetYear, targetMonth, 0).getDate();

                            calendarModel.clear();

                            for (let i = firstDay - 1; i >= 0; i--) {
                                calendarModel.append({ dayNum: (daysInPrevMonth - i).toString(), isCurrentMonth: false, isToday: false });
                            }
                            for (let i = 1; i <= daysInMonth; i++) {
                                calendarModel.append({ dayNum: i.toString(), isCurrentMonth: true, isToday: (isRealCurrentMonth && i === todayDate) });
                            }
                            let remaining = 42 - calendarModel.count;
                            for (let i = 1; i <= remaining; i++) {
                                calendarModel.append({ dayNum: i.toString(), isCurrentMonth: false, isToday: false });
                            }
                        }

                        Timer {
                            interval: 1000; running: true; repeat: true; triggeredOnStart: true
                            onTriggered: {
                                calendar.currentTime = new Date();
                                if (calendar.currentTime.getHours() === 0 && calendar.currentTime.getMinutes() === 0 && calendar.currentTime.getSeconds() === 0) {
                                    calendar.updateCalendarGrid();
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.topMargin: 32

                            Text {
                                text: calendar.targetMonthName
                                font.weight: 1000
                                font.pixelSize: 22
                                font.family: Globals.fontFamily
                                color: Colors.md3.on_surface
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 8
                                Layout.topMargin: 8
                                Repeater {
                                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: Qt.alpha(Colors.md3.primary, 0.5)
                                        font.pixelSize: 14
                                        font.family: Globals.fontFamily
                                        font.weight: 700
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            ListModel { id: calendarModel }
                            GridLayout {
                                columns: 7
                                rowSpacing: 8
                                columnSpacing: 4
                                Repeater {
                                    model: calendarModel
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: model.isToday ? Colors.md3.primary : "transparent"
                                        radius: 8
                                        Text {
                                            anchors.centerIn: parent
                                            text: model.dayNum 
                                            font.family: Globals.fontFamily
                                            font.weight: model.isToday ? 1000 : 600
                                            opacity: model.isCurrentMonth ? 1.0 : 0.2
                                            font.pixelSize: 14
                                            color: model.isCurrentMonth ? (model.isToday ? Colors.md3.on_primary : Colors.md3.on_surface) : Colors.md3.on_surface
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Process {
                        property int weatherTemp: 0
                        property int weatherFeelsLike: 0
                        property int weatherHumidity: 0
                        property int weatherWindSpeed: 0
                        property string cityName: ""
                        property string weatherDesc: ""
                        property bool dataLoaded: false

                        id: weatherReader
                        running: false
                        command: ["bash", "-c", "python $HOME/DESKTOPdir/pythonScripts/weather.py"]

                        stdout: StdioCollector {
                            onStreamFinished: {
                                try {
                                    let data = JSON.parse(this.text)
                                    weatherReader.weatherTemp = Math.round(data.main.temp)
                                    weatherReader.weatherFeelsLike = Math.round(data.main.feels_like)
                                    weatherReader.weatherHumidity = data.main.humidity
                                    weatherReader.weatherWindSpeed = Math.round(data.wind.speed)
                                    weatherReader.cityName = data.name
                                    weatherReader.weatherDesc = data.weather[0].description
                                    weatherReader.dataLoaded = true
                                } catch(e) { console.log("ERROR: " + e) }
                            }
                        }
                    }

                    Process {
                        property var forecastData: []

                        id: forecast5days
                        running: false
                        command: ["bash", "-c", "python $HOME/DESKTOPdir/pythonScripts/5dayforecast.py"]

                        stdout: StdioCollector {
                            onStreamFinished: {
                                try {
                                    let data = JSON.parse(this.text)
                                    forecast5days.forecastData = data
                                } catch(e) { console.log("ERROR: " + e) }
                            }
                        }
                    }

                    Timer {
                        interval: 600000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: {
                            weatherReader.running = true
                            forecast5days.running = true
                        }
                    }

                    Rectangle {
                        id: weather
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 32
                        Layout.leftMargin: 0

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            Text {
                                text: "WEATHER — " + (weatherReader.dataLoaded ? weatherReader.cityName.toUpperCase() : "ERROR")
                                Layout.alignment: Qt.AlignTop
                                font.pixelSize: 14
                                font.weight: 1000
                                font.family: Globals.fontFamily
                                font.letterSpacing: 1.5
                                color: Qt.alpha(Colors.md3.primary, 0.5)
                            }
                            RowLayout {
                                spacing: -4
                                Layout.alignment: Qt.AlignTop
                                Text {
                                    text: (weatherReader.dataLoaded ? weatherReader.weatherTemp : "ERR")
                                    Layout.topMargin: 2
                                    font.weight: 1000
                                    font.family: Globals.fontFamily
                                    font.pixelSize: 52
                                    color: Colors.md3.on_surface
                                }
                                Text {
                                    text: "°C"
                                    Layout.topMargin: 2
                                    Layout.bottomMargin: 32
                                    Layout.leftMargin: 4
                                    font.weight: 1000
                                    font.family: Globals.fontFamily
                                    font.pixelSize: 24
                                    color: Qt.alpha(Colors.md3.on_surface, 0.6)
                                }
                            }
                            Text {
                                text: (weatherReader.dataLoaded ? weatherReader.weatherDesc.charAt(0).toUpperCase() + weatherReader.weatherDesc.slice(1) : "ERROR")
                                Layout.topMargin: -12
                                Layout.bottomMargin: 14
                                Layout.alignment: Qt.AlignTop
                                font.weight: 700
                                font.family: Globals.fontFamily
                                font.pixelSize: 14
                                color: Qt.alpha(Colors.md3.on_surface, 0.5)
                            }
                            RowLayout {
                                spacing: 8
                                Layout.fillWidth: true
                                Layout.preferredHeight: 62

                                Repeater {
                                    model: [
                                        { label: "HUMIDITY",   value: weatherReader.dataLoaded ? weatherReader.weatherHumidity + "%" : "ERR" },
                                        { label: "WIND",       value: weatherReader.dataLoaded ? weatherReader.weatherWindSpeed + " m/s" : "ERR" },
                                        { label: "FEELS LIKE", value: weatherReader.dataLoaded ? weatherReader.weatherFeelsLike + "°C" : "ERR" }
                                    ]

                                    Rectangle {
                                        height: 62
                                        Layout.fillWidth: true
                                        color: Qt.alpha(Colors.md3.primary, 0.06)
                                        border.width: 1
                                        border.color: Qt.alpha(Colors.md3.primary, 0.1)
                                        radius: 8

                                        ColumnLayout {
                                            anchors.left: parent.left
                                            spacing: 4

                                            Text {
                                                text: modelData.label
                                                Layout.topMargin: 10
                                                Layout.leftMargin: 12
                                                font.pixelSize: 11
                                                font.weight: 700
                                                font.letterSpacing: 1.3
                                                color: Qt.alpha(Colors.md3.on_surface, 0.35)
                                                font.family: Globals.fontFamily
                                            }

                                            Text {
                                                text: modelData.value
                                                Layout.leftMargin: 12
                                                font.pixelSize: 18
                                                font.weight: 1000
                                                color: Colors.md3.on_surface
                                                font.family: Globals.fontFamily
                                            }
                                        }
                                    }
                                }
                            }
                            Text {
                                text: "5-DAY FORECAST"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 4
                                font.weight: 800
                                font.family: Globals.fontFamily
                                font.letterSpacing: 1.5
                                color: Qt.alpha(Colors.md3.primary, 0.45)
                                font.pixelSize: 13
                            }
                            RowLayout {
                                spacing: 6
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                Repeater {
                                    model: forecast5days.forecastData
                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        height: 100
                                        color: Qt.alpha(Colors.md3.primary, 0.05)
                                        border.width: 1
                                        border.color: Qt.alpha(Colors.md3.primary, 0.08)
                                        radius: 8

                                        ColumnLayout {
                                            spacing: 10
                                            anchors.fill: parent

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.bottomMargin: -6
                                                text: modelData.day_of_week
                                                font.family: Globals.fontFamily
                                                font.letterSpacing: 1.5
                                                color: Qt.alpha(Colors.md3.on_surface, 0.35)
                                                font.pixelSize: 13
                                                font.weight: 1000
                                            }
                                            Image {
                                                id: iconWeather
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.bottomMargin: -20
                                                Layout.topMargin: -20
                                                source: "/home/jaga/DESKTOPdir/weatherIcons/" + modelData.icon
                                            }
                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.bottomMargin: -18
                                                text: modelData.max + "°"
                                                font.family: Globals.fontFamily
                                                color: Colors.md3.on_surface
                                                font.pixelSize: 16
                                                font.weight: 1000
                                            }
                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: modelData.min + "°"
                                                color: Qt.alpha(Colors.md3.on_surface , 0.3)
                                                font.pixelSize: 12
                                                font.family: Globals.fontFamily
                                                font.weight: 800
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

        // Time
        Rectangle {
            id: timerBox
            anchors.centerIn: parent
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
                    triggeredOnStart: true
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
                                console.log("ID:    ", modelData.id)
                                console.log("Title: ", modelData.title)
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
