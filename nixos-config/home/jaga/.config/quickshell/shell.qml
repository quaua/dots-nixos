import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQml.Models

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
    implicitHeight: 32 
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
      width: 24
      height: 24
    }

    // Workspaces
    Row {
      id: workspaces
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: 55
      spacing: 10
      Repeater {
        model: 10 // Number of workspaces
        Rectangle {
          readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === (index + 1)		    
	  readonly property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
	  property bool isHovered: ms.containsMouse

          width: isFocused ? 35 : 15
          height: 15
	  radius: 10
	  color: isFocused ? "#ded0db" : (isHovered ? "#737373" : (ws ? "#9c929a" : "#3b3b3b"))

	  MouseArea {
	    id: ms
	    hoverEnabled: true
            anchors.fill: parent
            onClicked: Hyprland.dispatch("workspace " + (index + 1))
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

    Row {
      spacing: 10
      anchors.centerIn: parent

      Text {
        id: timeHour
        text: Qt.formatDateTime(new Date(), "h:mma")
        color: "white"
        font.pixelSize: 16
        font.family: Globals.fontFamily
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

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
          timeText.text = Qt.formatDateTime(new Date(), "MMM dd")
          timeHour.text = Qt.formatDateTime(new Date(), "hh:mm A")
        }
      }
    }

    //Tray
    Row {
      id: sysTray
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 15
      spacing: 5

      Instantiator {
        model: sysTray.items
	delegate: Image {
	  width: 24
	  height: 24
	  source: modelData.icon || "image-missing"
	  parent: sysTray
	}
      }
    }
  }
}
