pragma Singleton
import QtQuick

QtObject {
    // Colors
    readonly property color background: Qt.rgba(0 , 0 , 0 , 1)
    readonly property color accent: "#ff0000"
    readonly property double opacity: 0.6

    // Dimensions
    readonly property int barHeight: 40
    readonly property int cornerRadius: 0
    readonly property int spacing: 0

    // Animations
    readonly property int animSpeed: 250
}
