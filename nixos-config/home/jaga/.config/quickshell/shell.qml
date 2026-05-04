import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQml.Models
import Quickshell.Services.SystemTray
import Quickshell.Wayland

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

    WlrLayershell.namespace: "bar"
    implicitHeight: Appearance.barHeight 
    color: "transparent"
  
    // Border + Background Rectangle
    Rectangle {
      id: bar
      anchors.fill: parent
      color: Qt.rgba(0 , 0 , 0 , 0.75)
      border.width: 0
      radius: 0
    }

    // Workspaces
    Rectangle {
      id: workspacesBlock
      width: workspaces.width + 45
      height: Appearance.barHeight - 8
      radius: height/2
      color: Qt.rgba(0 , 0 , 0 , 0.35)
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
	    //property bool isHovered: ms.containsMouse

	    anchors.verticalCenter: parent.verticalCenter
	    width: 10
	    height: 10
	    radius: height/2
	    color: isFocused ? Qt.rgba(1 , 1 , 1 , 0.9) : Qt.rgba(1 , 1 , 1 , 0.2)
	    Rectangle {
	      width: 25
	      height: 25
	      radius: height/2
	      color: ws ? Qt.rgba(1 , 1 , 1 , 0.1) : "transparent"
	      anchors.centerIn: parent

	      topLeftRadius: prevOccupied ? 0 : height/2
              bottomLeftRadius: prevOccupied ? 0 : height/2
              topRightRadius: nextOccupied ? 0 : height/2
	      bottomRightRadius: nextOccupied ? 0 : height/2
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
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 15
      spacing: 8
      
      Repeater {
        model: SystemTray.items
	
	delegate: MouseArea {
	  id: trayItem
	  width: 25
	  height: 25
	  hoverEnabled: true

	  Image {
	    anchors.fill: parent
	    source: modelData.icon
	    fillMode: Image.PreserveAspectFit
	  }
	}
      }  
    }
  }
}
