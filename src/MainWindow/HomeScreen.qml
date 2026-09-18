import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// HomeScreen
//      Landing page shown after login, before the map. A bottom navigation bar
//      lets you jump straight to Plan/Analyze/Settings, while the Start button
//      takes you into the Fly (map) view.
Item {
    id: root

    signal startClicked
    signal planClicked
    signal analyzeClicked
    signal settingsClicked

    readonly property color _bg:           "#F0F9FF"
    readonly property color _skyLight:     "#7DD3FC"
    readonly property color _sky:          "#38BDF8"
    readonly property color _skyDeep:      "#0284C7"
    readonly property color _navActiveBg:  "#FFFFFF"
    readonly property color _navText:      "#F0F9FF"
    readonly property color _textColor:    "#0F172A"
    readonly property color _mutedText:    "#64748B"

    // ---- Page background ---------------------------------------------------
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#FFFFFF" }
            GradientStop { position: 1.0; color: root._bg }
        }
    }

    // ---- Bottom navigation bar ---------------------------------------------
    Rectangle {
        id:             bottomNav
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         navRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 1.6

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: root._skyLight }
            GradientStop { position: 1.0; color: root._sky }
        }

        // Subtle top highlight so the bar reads as a distinct raised dock
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            height:         2
            color:          "#FFFFFF"
            opacity:        0.6
        }

        Row {
            id:                 navRow
            anchors.centerIn:   parent
            spacing:            ScreenTools.defaultFontPixelWidth * 3

            Repeater {
                model: [
                    { key: "home",     objectName: "home_navHome",     label: qsTr("Home"),     icon: "/res/QGCLogoWhite.svg",      action: function() { } },
                    { key: "plan",     objectName: "home_navPlan",     label: qsTr("Plan"),     icon: "/qmlimages/Plan.svg",         action: function() { root.planClicked() } },
                    { key: "analyze",  objectName: "home_navAnalyze",  label: qsTr("Analyze"),  icon: "/qmlimages/Analyze.svg",      action: function() { root.analyzeClicked() } },
                    { key: "settings", objectName: "home_navSettings", label: qsTr("Settings"), icon: "/res/GearWithPaperPlane.svg", action: function() { root.settingsClicked() } }
                ]

                delegate: Item {
                    id:     navItemRoot
                    width:  navItemColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 2
                    height: navItemColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.7

                    readonly property bool _isActive: modelData.key === "home"

                    Rectangle {
                        anchors.centerIn:   parent
                        width:              navItemColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.8
                        height:             navItemColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.6
                        radius:             height * 0.5
                        color:              navItemRoot._isActive ? root._navActiveBg : "#FFFFFF"
                        opacity:            navItemRoot._isActive ? 1.0 : (navMouseArea.containsMouse ? 0.25 : 0.0)

                        Behavior on opacity {
                            NumberAnimation { duration: 120 }
                        }
                    }

                    ColumnLayout {
                        id:                 navItemColumn
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelHeight * 0.25

                        Image {
                            Layout.alignment:   Qt.AlignHCenter
                            source:             modelData.icon
                            sourceSize.width:   ScreenTools.defaultFontPixelHeight * 1.4
                            sourceSize.height:  ScreenTools.defaultFontPixelHeight * 1.4
                            fillMode:           Image.PreserveAspectFit
                        }

                        QGCLabel {
                            Layout.alignment:       Qt.AlignHCenter
                            text:                   modelData.label
                            color:                  navItemRoot._isActive ? root._skyDeep : root._navText
                            font.pointSize:         ScreenTools.smallFontPointSize
                            font.bold:              navItemRoot._isActive
                            horizontalAlignment:    Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        id:             navMouseArea
                        objectName:     modelData.objectName
                        anchors.fill:   parent
                        hoverEnabled:   true
                        onClicked:      modelData.action()
                    }
                }
            }
        }
    }

    // ---- Main content: branding + Start button -----------------------------
    ColumnLayout {
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.bottom:     bottomNav.top
        anchors.margins:    ScreenTools.defaultFontPixelHeight

        ColumnLayout {
            Layout.alignment:   Qt.AlignHCenter
            Layout.topMargin:   ScreenTools.defaultFontPixelHeight * 3
            spacing:            ScreenTools.defaultFontPixelHeight * 0.75

            Rectangle {
                Layout.alignment:   Qt.AlignHCenter
                width:              ScreenTools.defaultFontPixelHeight * 7.5
                height:             width
                radius:             width * 0.5
                color:              "#FFFFFF"
                border.width:       2
                border.color:       root._skyLight

                Image {
                    anchors.centerIn:   parent
                    source:             "/res/QGCLogoWhite.svg"
                    sourceSize.width:   parent.width * 0.72
                    sourceSize.height:  parent.height * 0.72
                    fillMode:           Image.PreserveAspectFit
                }
            }

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                Layout.topMargin:   ScreenTools.defaultFontPixelHeight * 0.5
                text:               QGroundControl.appName
                font.pointSize:     ScreenTools.largeFontPointSize
                font.bold:          true
                color:              root._textColor
            }

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                text:               qsTr("Ready when you are")
                font.pointSize:     ScreenTools.defaultFontPointSize
                color:              root._mutedText
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            id:                 startButton
            objectName:         "home_startButton"
            Layout.alignment:   Qt.AlignHCenter
            width:              Math.max(startRow.implicitWidth + ScreenTools.defaultFontPixelWidth * 4, ScreenTools.defaultFontPixelWidth * 22)
            height:             startRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 1.5

            radius:             height * 0.5

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: startMouseArea.pressed ? root._skyDeep : root._sky }
                GradientStop { position: 1.0; color: root._skyDeep }
            }

            RowLayout {
                id:                 startRow
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelWidth * 0.75

                Image {
                    source:             "/res/FlyingPaperPlane.svg"
                    sourceSize.width:   ScreenTools.defaultFontPixelHeight * 1.2
                    sourceSize.height:  ScreenTools.defaultFontPixelHeight * 1.2
                    fillMode:           Image.PreserveAspectFit
                }

                QGCLabel {
                    text:               qsTr("Start")
                    font.pointSize:     ScreenTools.mediumFontPointSize
                    font.bold:          true
                    color:              "#FFFFFF"
                }
            }

            MouseArea {
                id:             startMouseArea
                objectName:     "home_startMouseArea"
                anchors.fill:   parent
                onClicked:      root.startClicked()
            }
        }

        Item { Layout.fillHeight: true }
    }
}
