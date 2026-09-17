import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#1b1c1d"

    signal registerRequested()

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
            text: qsTr("Chennai Drone Academy")
            color: "white"
            font.pointSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: userField
            placeholderText: qsTr("Username")
            Layout.fillWidth: true
            KeyNavigation.tab: passField
            onAccepted: passField.forceActiveFocus()
            onTextChanged: AuthController.clearError()
        }

        TextField {
            id: passField
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
            onAccepted: loginButton.clicked()
            onTextChanged: AuthController.clearError()
        }

        Label {
            text: AuthController.errorString
            color: "#ff6b6b"
            visible: text !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: loginButton
            text: qsTr("Log In")
            Layout.fillWidth: true
            onClicked: AuthController.login(userField.text, passField.text)
        }

        Button {
            text: qsTr("Create an account")
            flat: true
            Layout.fillWidth: true
            onClicked: {
                AuthController.clearError()
                root.registerRequested()
            }
        }
    }
}
