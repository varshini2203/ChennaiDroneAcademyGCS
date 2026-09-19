import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

/// Toolbar button that takes the user back to the Home landing screen.
/// Drop it at the left edge of any view's toolbar:
///
///     BackToHomeButton { Layout.fillHeight: true }   // inside a Row/RowLayout
///     BackToHomeButton { height: parent.height }     // inside an Item/Rectangle
Button {
    id:             control
    objectName:     "toolbar_backToHome"

    /// Arrow-only by default. Set to true to show "Home" next to the arrow.
    property bool   showLabel:  false
    /// Arrow/label color. Defaults to the same color the other toolbar buttons use.
    property color  iconColor:  control.pressed ? qgcPal.buttonHighlightText : qgcPal.buttonText

    height:         ScreenTools.toolbarHeight
    leftPadding:    ScreenTools.defaultFontPixelWidth
    rightPadding:   ScreenTools.defaultFontPixelWidth
    checkable:      false
    hoverEnabled:   !ScreenTools.isMobile
    text:           qsTr("Home")

    Accessible.role:    Accessible.Button
    Accessible.name:    qsTr("Back to Home")

    ToolTip.visible:    hovered
    ToolTip.delay:      600
    ToolTip.text:       qsTr("Back to Home")

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    onClicked: {
        // Honors the same guards as every other view switch (invalid field values,
        // calibration in progress, ...) and shows the usual toast if blocked.
        if (mainWindow.allowViewSwitch()) {
            mainWindow.closeIndicatorDrawer()
            mainWindow.showHomeScreen()
        }
    }

    background: Rectangle {
        color:          control.pressed ? qgcPal.buttonHighlight : (control.hovered ? Qt.rgba(0, 0, 0, 0.06) : "transparent")
        border.color:   "red"
        border.width:   QGroundControl.corePlugin.showTouchAreas ? 3 : 0
    }

    contentItem: Row {
        spacing: ScreenTools.defaultFontPixelWidth * 0.5

        // Left arrow drawn in code so no new image resource has to be registered
        Canvas {
            id:                     arrow
            width:                  ScreenTools.defaultFontPixelHeight * 1.5
            height:                 width
            anchors.verticalCenter: parent.verticalCenter

            property color strokeColor: control.iconColor

            onStrokeColorChanged:   requestPaint()
            onWidthChanged:         requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = strokeColor
                ctx.lineWidth   = Math.max(2, width * 0.11)
                ctx.lineCap     = "round"
                ctx.lineJoin    = "round"

                var m  = width  * 0.14      // edge margin
                var cy = height * 0.5
                var h  = width  * 0.30      // arrow-head size

                ctx.beginPath()
                ctx.moveTo(width - m, cy)   // shaft
                ctx.lineTo(m, cy)
                ctx.moveTo(m + h, cy - h)   // head
                ctx.lineTo(m, cy)
                ctx.lineTo(m + h, cy + h)
                ctx.stroke()
            }
        }

        Label {
            visible:                control.showLabel && text !== ""
            text:                   control.text
            color:                  control.iconColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}