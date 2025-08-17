import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    visible: true
    width: 1024
    height: 600
    title: "Robot Matrix"
    property string currentView: "none"
    property bool recording: false

    Row {
        anchors.fill: parent

        // 左侧控制面板（256宽）
        Rectangle {
            width: 256
            height: parent.height
            color: "#f0f0f0"
            border.color: "#cccccc"

            Column {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 20

                Text { text: "Switch View:" }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Button { text: "Point Cloud"; onClicked:controller.switch_view("pointCloud") }
                    Button { text: "Camera"; onClicked: controller.switch_view("camera") }
                    Button { text: "Map"; onClicked: controller.switch_view("map") }
                }

                Rectangle { width: parent.width; height: 1; color: "#cccccc" }

                Text { text: "Initial Position:" }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    TextField { id: xInput; placeholderText: "X coordinate"; width: 200 }
                    TextField { id: yInput; placeholderText: "Y coordinate"; width: 200 }
                    TextField { id: zInput; placeholderText: "Z coordinate"; width: 200 }
                }

                Rectangle { width: parent.width; height: 1; color: "#cccccc" }
                Text { text: "Coordinate System:"; width: 200; horizontalAlignment: Text.AlignLeft }
                Column {
                    
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    ComboBox {
                        id: coordSystemSelector
                        width: 200
                        model: ["NZTM", "MT2000"]
                        currentIndex: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        onCurrentTextChanged: {
                            console.log("Choosed Coordinate System:", currentText)
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#cccccc" }

                Switch {
                    id: recordSwitch
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: recording ? "Stop Recording" : "Start Recording"
                    checked: controller.recording
                    onToggled: controller.toggle_recording()
                }
            }
        }

        // 右侧显示区域（800x600）
        Rectangle {
            width: 800
            height: 600
            color: "#000000"

            Loader {
                id: viewLoader
                anchors.fill: parent
                sourceComponent: currentView === "pointCloud" ? pointCloudView :
                                 currentView === "camera" ? cameraView :
                                 currentView === "map" ? mapView : null
            }
        }
    }

    // 模拟视图组件（可替换为真实内容）
    Component {
        id: pointCloudView
        Rectangle {
            color: "darkblue"
            anchors.fill: parent
            Text { anchors.centerIn: parent; color: "white"; text: "Point Cloud view" }
        }
    }

    Component {
        id: cameraView
        Rectangle {
            color: "darkgreen"
            anchors.fill: parent
            Text { anchors.centerIn: parent; color: "white"; text: "Camera view" }
        }
    }

    Component {
        id: mapView
        Rectangle {
            color: "darkred"
            anchors.fill: parent
            Text { anchors.centerIn: parent; color: "white"; text: "Map view" }
        }
    }
}
