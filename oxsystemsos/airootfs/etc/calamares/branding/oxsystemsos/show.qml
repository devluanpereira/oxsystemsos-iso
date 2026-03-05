import QtQuick 2.15

Rectangle {
    anchors.fill: parent
    color: "#0c111b"

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: "banner.png"
        opacity: 0.20
    }

    Column {
        anchors.centerIn: parent
        spacing: 14

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "ox-logo.svg"
            sourceSize.width: 160
            sourceSize.height: 160
            fillMode: Image.PreserveAspectFit
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "OXSystemsOS"
            color: "#d8f8ff"
            font.pixelSize: 36
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Instalando sistema..."
            color: "#9ad8ff"
            font.pixelSize: 20
        }
    }
}
