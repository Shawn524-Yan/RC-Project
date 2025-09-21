import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtPositioning 5.15
import QtLocation 5.15

Window {
    visible: true
    width: 1024
    height: 600
    title: "Robot Matrix"
    property string currentView: "none"
    property bool recording: false

    Row {
        anchors.fill: parent

        // 256
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

        // 右侧显示区域800x600
        Rectangle {
            width: 800
            height: 600
            color: "#885353ff"

            Loader {
                id: viewLoader
                anchors.fill: parent
                sourceComponent: controller.currentView === "pointCloud" ? pointCloudView :
                                 controller.currentView === "camera" ? cameraView :
                                 controller.currentView === "map" ? mapView : null
            }
        }
    }

    // 模拟视图组件可替换为真实内容
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
        Map {
            id: mapItem
            anchors.fill: parent
            zoomLevel: 16
            center: QtPositioning.coordinate(-37.7877333,175.2834924)

            plugin: Plugin {
                name: "osm"
                PluginParameter { name: "osm.mapping.offline.directory"; value: Qt.resolvedUrl("../resource/tile") }
                PluginParameter { name: "osm.mapping.offline.tiles"; value: "true" }
            }

            MouseArea {
                z: 999
                anchors.fill: parent
                //drag.target: mapItem
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                property bool isDragging: false
                property var lastMousePos
                hoverEnabled: true
                propagateComposedEvents: true
                onPressed: {
                    console.log("Pressed:", mouse.button)
                    if (mouse.button === Qt.LeftButton) {
                        isDragging = true
                        lastMousePos = Qt.point(mouseX, mouseY)
                    }
                }

                onReleased: {
                    if (mouse.button === Qt.LeftButton) {
                        isDragging = false
                    }
                }

                onClicked: {
                    console.log("Mouse clicked:", mouse.button)
                }
                onPositionChanged: {
                    if (isDragging) {
                        var dx =  lastMousePos.x - mouseX
                        var dy =  lastMousePos.y - mouseY
                        lastMousePos = Qt.point(mouseX, mouseY)

                        var metersPerPixel = 156543.03392 * Math.cos(mapItem.center.latitude * Math.PI / 180) / Math.pow(2, mapItem.zoomLevel)
                        var deltaLon = dx * metersPerPixel / (111320 * Math.cos(mapItem.center.latitude * Math.PI / 180))
                        var deltaLat = -dy * metersPerPixel / 110540

                        mapItem.center.latitude += deltaLat
                        mapItem.center.longitude += deltaLon
                    }
                }

                onWheel:function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        mapItem.zoomLevel = Math.min(mapItem.zoomLevel + 1, 20)
                    } else {
                        mapItem.zoomLevel = Math.max(mapItem.zoomLevel - 1, 1)
                    }
                }
                onDoubleClicked: {
                    mapItem.zoomLevel = Math.min(mapItem.zoomLevel + 1, 20)
                }
            }

            // Optional: Touch support for pinch zoom
            MultiPointTouchArea {
                anchors.fill: parent
                minimumTouchPoints: 2
                maximumTouchPoints: 2
                onTouchUpdated: {
                    if (touchPoints.length === 2) {
                        var p1 = touchPoints[0]
                        var p2 = touchPoints[1]
                        var dx = p2.x - p1.x
                        var dy = p2.y - p1.y
                        var distance = Math.sqrt(dx*dx + dy*dy)
                        if (typeof lastDistance !== "undefined") {
                            if (distance > lastDistance + 10) {
                                mapItem.zoomLevel = Math.min(mapItem.zoomLevel + 1, 20)
                            } else if (distance < lastDistance - 10) {
                                mapItem.zoomLevel = Math.max(mapItem.zoomLevel - 1, 1)
                            }
                        }
                        lastDistance = distance
                    }
                }
                property real lastDistance: 0
            }
        }
    }
}
