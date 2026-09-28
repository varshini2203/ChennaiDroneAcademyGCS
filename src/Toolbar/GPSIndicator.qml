import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// Used as the base class control for both VehicleGPSIndicator and RTKGPSIndicator

Item {
    id:             control
    width:          gpsIndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _rtkConnected:  QGroundControl.gpsRtk.connected.value
    property int    _satCount:      (_activeVehicle && !isNaN(_activeVehicle.gps.count.value)) ? _activeVehicle.gps.count.value : 0
    property real   _hdop:          (_activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)) ? _activeVehicle.gps.hdop.value : 0

    // Satellite count mapped to a 0-100 signal percentage, reduced when HDOP is poor
    property real   _gpsPercent: {
        var p = 0
        if (_satCount >= 12)        p = 100
        else if (_satCount >= 9)    p = 80
        else if (_satCount >= 6)    p = 60
        else if (_satCount >= 4)    p = 40
        else if (_satCount > 0)     p = 20
        if (_hdop > 2.5 && p > 40)  p = 40
        else if (_hdop > 1.5 && p > 60) p = 60
        return p
    }

    QGCPalette { id: qgcPal }

    Row {
        id:             gpsIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            spacing:        -ScreenTools.defaultFontPixelWidth / 2

            QGCLabel {
                id:                     gpsLabel
                rotation:               90
                text:                   qsTr("RTK")
                color:                  qgcPal.text
                anchors.verticalCenter: parent.verticalCenter
                visible:                _rtkConnected
            }

            QGCColoredImage {
                id:                 gpsIcon
                width:              height
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                source:             "/qmlimages/Gps.svg"
                fillMode:           Image.PreserveAspectFit
                sourceSize.height:  height
                opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
                color:              qgcPal.text
            }
        }

        SignalStrength {
            id:                     gpsBars
            anchors.verticalCenter: parent.verticalCenter
            size:                   parent.height * 0.5
            percent:                _gpsPercent
            visible:                !!_activeVehicle
        }

        QGCLabel {
            anchors.verticalCenter: parent.verticalCenter
            color:                  qgcPal.text
            text:                   _satCount
            visible:                !!_activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(gpsIndicatorPage, control)
    }

    Component {
        id: gpsIndicatorPage

        GPSIndicatorPage { }
    }
}
