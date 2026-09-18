import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Button {
    id:             control
    padding:        ScreenTools.defaultFontPixelWidth * 0.6
    leftPadding:    ScreenTools.defaultFontPixelWidth * 0.6
    rightPadding:   ScreenTools.defaultFontPixelWidth * 0.6
    hoverEnabled:   !ScreenTools.isMobile
    autoExclusive:  true
    icon.color:     textColor

    // This button now always sits on the sidebar's blue gradient panel (see AppSettings.qml),
    // so text/icons are white normally, and the selected item gets a white pill with blue text.
    property color textColor: checked || pressed ? "#0ea5e9" : "#ffffff"
    property bool expandable: false
    property bool expanded:   false

    signal toggleExpand()

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  control.enabled
    }

    background: Rectangle {
        color:      checked || pressed ? "#ffffff" : "#ffffff"
        opacity:    checked || pressed ? 1 : enabled && hovered ? .15 : 0
        radius:     height / 2
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth * 0.75

        Rectangle {
            width:          ScreenTools.defaultFontPixelHeight * 1.6
            height:         width
            radius:         width / 2
            color:          "transparent"

            QGCColoredImage {
                anchors.centerIn:   parent
                source:             control.icon.source
                color:              control.icon.color
                width:              ScreenTools.defaultFontPixelHeight * 0.9
                height:             width
            }
        }

        QGCLabel {
            id:                     displayText
            Layout.fillWidth:       true
            text:                   control.text
            color:                  control.textColor
            font.bold:              control.checked
            horizontalAlignment:    QGCLabel.AlignLeft
        }

        QGCColoredImage {
            visible:    control.expandable
            source:     "/InstrumentValueIcons/cheveron-right.svg"
            color:      control.textColor
            width:      ScreenTools.defaultFontPixelHeight * 0.75
            height:     width
            rotation:   control.expanded ? 90 : 0

            MouseArea {
                anchors.fill: parent
                anchors.margins: -ScreenTools.defaultFontPixelWidth
                onClicked: control.toggleExpand()
            }
        }
    }
}
