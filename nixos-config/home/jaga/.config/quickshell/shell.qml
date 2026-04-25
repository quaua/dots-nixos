import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

ShellRoot {
  PanelWindow {
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
  implicitHeight: 30 
  color: "transparent"
  
  // Border + Background Rectangle
  Rectangle {
    anchors.fill: parent
    color: '#1a1a1a'
    border.width: 0
    radius: 0
  }

  // Logo
  Image {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 15
    source: "Untitled.svg"
    width: 20
    height: 20
  }

  // Workspaces
  Row {
    id: workspaces
    anchors.centerIn: parent
    anchors.leftMargin: 0
    spacing: 12
    Repeater {
      model: 10 // Number of workspaces
      Rectangle {
        readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)		    
        readonly property bool isOccupied: {
        // We search the list of all workspaces known to Hyprland
          for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            if (Hyprland.workspaces.values[i].id === (index + 1)) {
              return true;
            }
          }
          return false;
        }
        width: isFocused ? 45 : 15
        height: 15
        radius: 10
        color: {
          if (isFocused) return "#ded0db"
          if (isOccupied) return "#9C929A"
          return "#3b3b3b" // A very dark color for empty workspaces
        }
        // Smooth animation for width changes
        Behavior on width {
          NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
    
        // Smooth animation for color changes
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }

  Item {
    id: time
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 125
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: {
        timeText.text = Qt.formatDateTime(new Date(), "ddd MM/dd")
        timeHour.text = Qt.formatDateTime(new Date(), "h:mma")
      }
    }
    Row {
      spacing: 10
      anchors.right: parent.right
      anchors.rightMargin: 5
      anchors.verticalCenter: parent.verticalCenter

      Text {
        text: "󰥔"
        color: "#ded0db"
        font.pixelSize: 20
        font.family: Globals.iconFont
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
      }

      Text {
        id: timeHour
        text: Qt.formatDateTime(new Date(), "h:mma")
        color: "white"
        font.pixelSize: 16
        font.family: Globals.fontFamily
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        width: 2
        height: parent.parent.parent.height - 10
        color: "#7c757a"
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        id: timeText
        text: Qt.formatDateTime(new Date(), "ddd dd/MM")
        color: "white"
        font.pixelSize: 16
        font.family: Globals.fontFamily
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }

  // Separator before volume
  Rectangle {
    anchors.right: parent.right
    anchors.rightMargin: 110
    anchors.verticalCenter: parent.verticalCenter
    width: 2
    height: parent.height - 10
    color: "#7c757a"
  }

        Item {
            id: volume
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 22.5
            width: 80
            height: parent.height

            property string volumeLevel: ""
            property bool muted: false
            property bool isToggling: false

            Process {
                id: volumeProcess
                running: true
                command: ["bash", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\" | while read -r line; do pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1; done"]
                stdout: SplitParser {
                    onRead: data => {
                        var vol = data.trim().replace('%', '')
                        if (vol) {
                            volume.volumeLevel = vol
                        }
                    }
                }
            }

            Process {
                id: initialVolume
                command: ["bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1"]
                stdout: SplitParser {
                    onRead: data => {
                        var vol = data.trim().replace('%', '')
                        if (vol) {
                            volume.volumeLevel = vol
                        }
                    }
                }
            }

            Process {
                id: muteStatus
                command: ["bash", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -oE 'yes|no'"]
                stdout: SplitParser {
                    onRead: data => {
                        volume.muted = (data.trim() === "yes")
                        if (volume.isToggling)
                            volume.isToggling = false
                    }
                }
            }

            Component.onCompleted: {
                initialVolume.running = true
                muteStatus.running = true
            }

            Row {
                spacing: 5
                anchors.centerIn: parent
                clip: false

                Text {
                    id: volumeIcon
                    width: 28
                    height: 28
                    text: volume.muted ? "󰖁" : "󰕾"
                    color: "#ded0db"
                    font.pixelSize: 20
                    font.family: Globals.iconFont
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        
                        onClicked: {
                            if (volume.isToggling)
                                return

                            volume.isToggling = true
                            muteToggle.command = ["bash", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
                            muteToggle.running = true
                            volume.muted = !volume.muted
                            muteStatusRefresh.start()
                        }

                        onEntered: parent.opacity = 0.6
                        onExited: parent.opacity = 1.0

                        Timer {
                            id: muteStatusRefresh
                            interval: 150
                            repeat: false
                            onTriggered: {
                                muteStatus.running = true
                                volume.isToggling = false
                            }
                        }

                        Process {
                            id: muteToggle
                            command: []
                        }
                    }
                }

                Text {
                    id: volumeText
                    text: volume.volumeLevel ? volume.volumeLevel + "%" : "--"
                    color: "white"
                    font.pixelSize: 16
                    font.family: Globals.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
