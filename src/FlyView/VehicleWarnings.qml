import QtQuick

import QGroundControl
import QGroundControl.Controls

Rectangle {
    anchors.margins:    -ScreenTools.defaultFontPixelHeight
    height:             warningsCol.height
    width:              warningsCol.width
    color:              Qt.rgba(1, 1, 1, 0.5)
    radius:             ScreenTools.defaultFontPixelWidth / 2
    visible:            _noGPSLockVisible || _prearmErrorVisible || _batteryCritical || _batteryLow || _linkLost

    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _noGPSLockVisible:    _activeVehicle && _activeVehicle.requiresGpsFix && !_activeVehicle.coordinate.isValid
    property bool _prearmErrorVisible:  _activeVehicle && !_activeVehicle.armed && _activeVehicle.prearmError && !_activeVehicle.healthAndArmingCheckReport.supported

    property real _lowestBatteryPercent: 100
    property bool _batteryCritical:      _activeVehicle && _lowestBatteryPercent <= 10
    property bool _batteryLow:           _activeVehicle && !_batteryCritical && _lowestBatteryPercent <= 25
    property bool _linkLost:             _activeVehicle && _activeVehicle.vehicleLinkManager.communicationLost

    function updateBattery() {
        var lowest = 100
        if (_activeVehicle) {
            for (var i = 0; i < _activeVehicle.batteries.count; i++) {
                var pct = _activeVehicle.batteries.get(i).percentRemaining.rawValue
                if (!isNaN(pct) && pct >= 0 && pct < lowest) {
                    lowest = pct
                }
            }
        }
        _lowestBatteryPercent = lowest
    }

    Timer {
        interval:           2000
        running:            !!_activeVehicle
        repeat:             true
        triggeredOnStart:   true
        onTriggered:        updateBattery()
    }

    Column {
        id:         warningsCol
        spacing:    ScreenTools.defaultFontPixelHeight

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _linkLost
            color:                      "#b3261e"
            font.pointSize:             ScreenTools.largeFontPointSize
            font.bold:                  true
            text:                       qsTr("Connection lost — check your radio or Wi-Fi link")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _batteryCritical
            color:                      "#b3261e"
            font.pointSize:             ScreenTools.largeFontPointSize
            font.bold:                  true
            text:                       qsTr("Battery critical — land now")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _batteryLow
            color:                      "#9a6100"
            font.pointSize:             ScreenTools.largeFontPointSize
            font.bold:                  true
            text:                       qsTr("Battery low — landing soon")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _noGPSLockVisible
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("Waiting for GPS — wait for a good GPS signal before flying")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _prearmErrorVisible
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       _activeVehicle ? _activeVehicle.prearmError : ""
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _prearmErrorVisible
            width:                      ScreenTools.defaultFontPixelWidth * 50
            horizontalAlignment:        Text.AlignHCenter
            wrapMode:                   Text.WordWrap
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("The drone is not ready to fly. Fix the problem above to enable arming.")
        }
    }
}
