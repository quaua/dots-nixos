//@ pragma UseQApplication

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
	  font.bold: true
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

	    Process {
              id: runSteam
	      command: ["sh", "-c", "steam steam://open/main"]
	      running: false
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
                  if ( modelData.id.toLowerCase() === "steam" ) {
                    runSteam.running = true
	          }
	          else {
                    modelData.activate();
                  }
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
