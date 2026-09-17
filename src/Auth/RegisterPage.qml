import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QGroundControl.Auth

Rectangle {
    id: root
    color: "#1b1c1d"

    signal backRequested()

    focus: true

    Component.onCompleted: {
        AuthController.clearError()
        userField.forceActiveFocus()
    }

    // Blocks every mouse / wheel / hover event from reaching the app behind the overlay
    MouseArea {
        anchors.fill:       parent
        hoverEnabled:       true
        acceptedButtons:    Qt.AllButtons
        onWheel:            function(wheel) { wheel.accepted = true }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 320
        spacing: 14

        Label {
            text: qsTr("Create Account")
            color: "white"
            font.pointSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: userField
            placeholderText: qsTr("Username")
            Layout.fillWidth: true
            onAccepted: passField.forceActiveFocus()
            onTextChanged: AuthController.clearError()
        }

        TextField {
            id: passField
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
            onAccepted: confirmField.forceActiveFocus()
            onTextChanged: AuthController.clearError()
        }

        TextField {
            id: confirmField
            placeholderText: qsTr("Confirm password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
            onAccepted: registerButton.clicked()
            onTextChanged: AuthController.clearError()
        }

        Label {
            text: AuthController.errorString
            color: "#ff6b6b"
            visible: text !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            id: successLabel
            text: qsTr("Account created. Please log in.")
            color: "#4caf50"
            visible: false
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: registerButton
            text: qsTr("Register")
            Layout.fillWidth: true
            onClicked: {
                if (AuthController.registerUser(userField.text, passField.text, confirmField.text)) {
                    successLabel.visible = true
                    backTimer.start()
                }
            }
        }

        Button {
            text: qsTr("Back to login")
            flat: true
            Layout.fillWidth: true
            onClicked: {
                AuthController.clearError()
                root.backRequested()
            }
        }
    }

    Timer {
        id: backTimer
        interval: 800
        repeat: false
        onTriggered: {
            AuthController.clearError()
            root.backRequested()
        }
    }
}
