import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Auth

ToolIndicatorPage {
    id: root

    readonly property color _navBg:        "#FFFFFF"
    readonly property color _navBgAlt:     "#FFFFFF"
    readonly property color _activePill:   "#EDE9FE"
    readonly property color _activeText:   "#6D5BD0"
    readonly property color _textColor:    "#475569"
    readonly property color _mutedText:    "#94A3B8"

    // Best-effort guess at which view is currently active, used only to
    // highlight the matching nav item. Falls back to "" (nothing highlighted)
    // if none of these match -- harmless either way.
    readonly property string _currentView: {
        if (typeof mainWindow === "undefined") return ""
        if (mainWindow.flyView && mainWindow.flyView.visible)   return "fly"
        if (mainWindow.planView && mainWindow.planView.visible) return "plan"
        if (mainWindow.geoView && mainWindow.geoView.visible)   return "geo"
        if (mainWindow.toolDrawer && mainWindow.toolDrawer.visible) {
            if (mainWindow.toolDrawer.toolTitle === qsTr("Analyze Tools"))            return "analyze"
            if (mainWindow.toolDrawer.toolTitle === qsTr("Vehicle Configuration"))    return "configure"
            if (mainWindow.toolDrawer.toolTitle === qsTr("Application Settings"))     return "settings"
        }
        return ""
    }

    contentComponent: Component {
        Rectangle {
            id: navBar
            implicitWidth:  navRow.implicitWidth + (ScreenTools.defaultFontPixelWidth * 2)
            implicitHeight: navRow.implicitHeight + versionColumn.implicitHeight + (ScreenTools.defaultFontPixelHeight * 1.5)
            radius:         ScreenTools.defaultFontPixelHeight * 1.2
            color:          root._navBg
            border.width:   1
            border.color:   "#E2E8F0"

            ColumnLayout {
                anchors.fill:    parent
                anchors.margins: ScreenTools.defaultFontPixelWidth * 0.75
                spacing:         ScreenTools.defaultFontPixelHeight * 0.5

                RowLayout {
                    id:      navRow
                    Layout.fillWidth: true
                    spacing: ScreenTools.defaultFontPixelWidth * 0.5

                    Repeater {
                        model: [
                            {
                                key: "fly", objectName: "toolbar_viewFly", label: qsTr("Fly"),
                                icon: "/res/FlyingPaperPlane.svg", visible: true,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showFlyView()
                                    }
                                }
                            },
                            {
                                key: "plan", objectName: "toolbar_viewPlan", label: qsTr("Plan"),
                                icon: "/qmlimages/Plan.svg", visible: true,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showPlanView()
                                    }
                                }
                            },
                            {
                                key: "geo", objectName: "toolbar_viewGeo", label: qsTr("GeoView"),
                                icon: "/InstrumentValueIcons/globe.svg",
                                visible: QGroundControl.settingsManager.geoViewSettings.enabled.rawValue,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showGeoView()
                                    }
                                }
                            },
                            {
                                key: "analyze", objectName: "toolbar_viewAnalyze", label: qsTr("Analyze"),
                                icon: "/qmlimages/Analyze.svg",
                                visible: QGroundControl.corePlugin.showAdvancedUI,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showAnalyzeTool()
                                    }
                                }
                            },
                            {
                                key: "configure", objectName: "toolbar_viewConfigure", label: qsTr("Configure"),
                                icon: "/res/GearWithPaperPlane.svg", visible: true,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showVehicleConfig()
                                    }
                                }
                            },
                            {
                                key: "settings", objectName: "toolbar_viewSettings", label: qsTr("Settings"),
                                icon: "/res/QGCLogoWhite.svg",
                                visible: !QGroundControl.corePlugin.options.combineSettingsAndSetup,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.showSettingsTool()
                                    }
                                }
                            },
                            {
                                key: "close", objectName: "toolbar_viewClose", label: qsTr("Close"),
                                icon: "/res/OpenDoor.svg", visible: true,
                                action: function() {
                                    if (mainWindow.allowViewSwitch()) {
                                        mainWindow.closeIndicatorDrawer()
                                        mainWindow.close()
                                    }
                                }
                            },
                            {
                                key: "logout", objectName: "toolbar_viewLogout", label: qsTr("Logout"),
                                icon: "/res/OpenDoor.svg", visible: true,
                                action: function() {
                                    console.log("[AUTH-DEBUG] toolbar Logout clicked, loggedIn before =", AuthController.loggedIn)
                                    mainWindow.closeIndicatorDrawer()
                                    AuthController.logout()
                                    console.log("[AUTH-DEBUG] toolbar Logout: AuthController.logout() returned, loggedIn after =", AuthController.loggedIn)
                                }
                            }
                        ]

                        delegate: Item {
                            id: navItemRoot
                            visible:        modelData.visible
                            Layout.fillWidth:       true
                            Layout.preferredWidth:  modelData.visible ? implicitWidth : 0
                            implicitWidth:  navItemColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.6
                            implicitHeight: navItemColumn.implicitHeight + ScreenTools.defaultFontPixelHeight

                            readonly property bool _isActive: modelData.key === root._currentView

                            Rectangle {
                                id:     activePill
                                anchors.centerIn: parent
                                width:  navItemColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.6
                                height: navItemColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.7
                                radius: height * 0.5
                                color:  navItemRoot._isActive ? root._activePill : (navMouseArea.pressed ? "#F1F5F9" : (navMouseArea.containsMouse ? "#F8FAFC" : "transparent"))

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }
                            }

                            ColumnLayout {
                                id:               navItemColumn
                                anchors.centerIn: parent
                                spacing:          ScreenTools.defaultFontPixelHeight * 0.25

                                // QGCColoredImage tints the SVG to a color we control,
                                // instead of trusting whatever color is baked into the
                                // source asset (several stock QGC icons are baked for a
                                // dark toolbar and are invisible or near-invisible here).
                                QGCColoredImage {
                                    Layout.alignment:   Qt.AlignHCenter
                                    source:             modelData.icon
                                    sourceSize.width:   ScreenTools.defaultFontPixelHeight * 1.4
                                    sourceSize.height:  ScreenTools.defaultFontPixelHeight * 1.4
                                    width:              ScreenTools.defaultFontPixelHeight * 1.4
                                    height:             ScreenTools.defaultFontPixelHeight * 1.4
                                    fillMode:           Image.PreserveAspectFit
                                    color:              navItemRoot._isActive ? root._activeText : root._textColor
                                }

                                Label {
                                    Layout.alignment:       Qt.AlignHCenter
                                    text:                   modelData.label
                                    color:                  navItemRoot._isActive ? root._activeText : root._textColor
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

                // Thin divider between nav row and version footer
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#E2E8F0"
                    opacity: 1.0
                }

                ColumnLayout {
                    id: versionColumn
                    Layout.fillWidth: true
                    spacing: 0

                    QGCLabel {
                        id: versionLabel
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("%1 Version").arg(QGroundControl.appName)
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: root._mutedText
                        wrapMode: QGCLabel.WordWrap
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: QGroundControl.qgcVersion
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: root._mutedText
                        wrapMode: QGCLabel.WrapAnywhere
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: QGroundControl.qgcAppDate
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: root._mutedText
                        wrapMode: QGCLabel.WrapAnywhere
                        visible: QGroundControl.qgcDailyBuild

                        QGCMouseArea {
                            anchors.topMargin: -(parent.y - versionLabel.y)
                            anchors.fill: parent

                            onClicked: (mouse) => {
                                if (mouse.modifiers & Qt.ControlModifier) {
                                    QGroundControl.corePlugin.showTouchAreas = !QGroundControl.corePlugin.showTouchAreas
                                    showTouchAreasNotification.open()
                                } else if (ScreenTools.isMobile || mouse.modifiers & Qt.ShiftModifier) {
                                    mainWindow.closeIndicatorDrawer()
                                    if (!QGroundControl.corePlugin.showAdvancedUI) {
                                        advancedModeOnConfirmation.open()
                                    } else {
                                        advancedModeOffConfirmation.open()
                                    }
                                }
                            }

                            // This allows you to change this on mobile
                            onPressAndHold: {
                                QGroundControl.corePlugin.showTouchAreas = !QGroundControl.corePlugin.showTouchAreas
                                showTouchAreasNotification.open()
                            }
                        }
                    }
                }
            }
        }
    }
}