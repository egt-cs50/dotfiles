// AppLauncher.qml — Quickshell App Launcher for Hyprland / Arch Linux
// Place in ~/.config/quickshell/AppLauncher.qml
// Toggle visibility by setting `root.launcherVisible` from a keybind

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: root

    property bool launcherVisible: false

    // ── Edit this list to match your installed apps ────────────────────────
    property var apps: [
        { name: "Terminal",    icon: "utilities-terminal",       exec: "kitty" },
        { name: "Firefox",     icon: "firefox",                  exec: "firefox" },
        { name: "Files",       icon: "system-file-manager",      exec: "thunar" },
        { name: "Code",        icon: "code",                     exec: "code" },
        { name: "Discord",     icon: "discord",                  exec: "discord" },
        { name: "Spotify",     icon: "spotify",                  exec: "spotify" },
        { name: "Settings",    icon: "preferences-system",       exec: "systemsettings" },
        { name: "Calculator",  icon: "accessories-calculator",   exec: "qalculate-gtk" },
        { name: "Neovim",      icon: "nvim",                     exec: "kitty nvim" },
        { name: "Steam",       icon: "steam",                    exec: "steam" },
        { name: "VLC",         icon: "vlc",                      exec: "vlc" },
        { name: "Btop",        icon: "utilities-system-monitor", exec: "kitty btop" },
    ]

    // ── Hyprland layer-shell window ────────────────────────────────────────
    PanelWindow {
        id: launcher

        visible: root.launcherVisible
        width: 560
        height: 500

        anchors.centerIn: parent

        WaylandWindow.layer: WaylandWindow.Layer.Overlay
        WaylandWindow.keyboardFocus: WaylandWindow.KeyboardFocus.OnDemand
        WaylandWindow.exclusionMode: WaylandWindow.ExclusionMode.Ignore

        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus()
                searchInput.text = ""
            }
        }

        Keys.onEscapePressed: root.launcherVisible = false

        // ── Backdrop ───────────────────────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Qt.rgba(0.07, 0.07, 0.11, 0.78)
            border.color: Qt.rgba(1, 1, 1, 0.09)
            border.width: 1
        }

        // ── Layout ─────────────────────────────────────────────────────────
        ColumnLayout {
            anchors {
                fill: parent
                margins: 18
            }
            spacing: 14

            // Header
            Text {
                text: "APPLICATIONS"
                font.pixelSize: 11
                font.family: "monospace"
                font.letterSpacing: 3
                color: Qt.rgba(1, 1, 1, 0.28)
                Layout.alignment: Qt.AlignHCenter
            }

            // ── Search bar ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 42
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: searchInput.activeFocus
                             ? Qt.rgba(0.45, 0.72, 1.0, 0.65)
                             : Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 13
                        rightMargin: 13
                    }
                    spacing: 9

                    Text {
                        text: "⌕"
                        font.pixelSize: 18
                        color: Qt.rgba(1, 1, 1, 0.38)
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "#e8e8e8"
                        font.pixelSize: 14
                        font.family: "monospace"
                        selectionColor: Qt.rgba(0.45, 0.72, 1.0, 0.4)
                        selectedTextColor: "#ffffff"
                        clip: true

                        Text {
                            anchors.fill: parent
                            visible: !searchInput.text && !searchInput.activeFocus
                            text: "Search…"
                            color: Qt.rgba(1, 1, 1, 0.25)
                            font: searchInput.font
                            verticalAlignment: Text.AlignVCenter
                        }

                        Keys.onEscapePressed: {
                            if (text.length > 0) text = ""
                            else root.launcherVisible = false
                        }

                        Keys.onReturnPressed: {
                            if (appGrid.firstVisible >= 0)
                                root.launchApp(appGrid.firstVisible)
                        }
                    }

                    Text {
                        visible: searchInput.text.length > 0
                        text: "✕"
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.30)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: searchInput.text = ""
                        }
                    }
                }
            }

            // ── App grid ────────────────────────────────────────────────────
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                GridView {
                    id: appGrid
                    width: parent.width
                    cellWidth: 115
                    cellHeight: 105

                    property int firstVisible: -1

                    function isVisible(idx) {
                        const q = searchInput.text.toLowerCase().trim()
                        return !q || root.apps[idx].name.toLowerCase().includes(q)
                    }

                    function updateFirstVisible() {
                        for (let i = 0; i < root.apps.length; i++) {
                            if (isVisible(i)) { firstVisible = i; return }
                        }
                        firstVisible = -1
                    }

                    Connections {
                        target: searchInput
                        function onTextChanged() { appGrid.updateFirstVisible() }
                    }

                    Component.onCompleted: updateFirstVisible()
                    model: root.apps.length

                    delegate: Item {
                        width: appGrid.cellWidth
                        height: appGrid.cellHeight
                        visible: appGrid.isVisible(index)
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 100 } }

                        Rectangle {
                            id: card
                            anchors { fill: parent; margins: 7 }
                            radius: 12
                            color: cardMouse.containsMouse
                                   ? Qt.rgba(1, 1, 1, 0.11)
                                   : Qt.rgba(1, 1, 1, 0.04)
                            border.color: cardMouse.containsMouse
                                          ? Qt.rgba(1, 1, 1, 0.16)
                                          : Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1
                            scale: cardMouse.pressed ? 0.92 : 1.0

                            Behavior on color  { ColorAnimation  { duration: 110 } }
                            Behavior on scale  { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 7

                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 38; height: 38
                                    source: "image://icon/" + root.apps[index].icon
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: parent.status === Image.Error || parent.status === Image.Null
                                        width: 38; height: 38
                                        radius: 8
                                        color: Qt.rgba(0.45, 0.72, 1.0, 0.15)
                                        Text {
                                            anchors.centerIn: parent
                                            text: root.apps[index].name[0].toUpperCase()
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: Qt.rgba(0.6, 0.85, 1.0, 0.85)
                                        }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: root.apps[index].name
                                    font.pixelSize: 11
                                    font.family: "monospace"
                                    color: Qt.rgba(1, 1, 1, 0.75)
                                    elide: Text.ElideRight
                                    width: card.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launchApp(index)
                            }
                        }
                    }
                }
            }

            // Footer hint
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "↵ launch  ·  esc close"
                font.pixelSize: 10
                font.family: "monospace"
                font.letterSpacing: 1
                color: Qt.rgba(1, 1, 1, 0.18)
            }
        }
    }

    // ── Launch via hyprctl dispatch exec ──────────────────────────────────
    function launchApp(idx) {
        proc.command = ["hyprctl", "dispatch", "exec", root.apps[idx].exec]
        proc.running = true
        root.launcherVisible = false
    }

    Process {
        id: proc
        running: false
    }
}
