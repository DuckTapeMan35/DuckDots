import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtCore
import QtQuick.Controls
import QtQuick.Controls.impl
import "../wal" as Wal

PanelWindow {
  id: panel
  property color color0: Wal.Colors.color0
  property color color1: Wal.Colors.color1
  property color color2: Wal.Colors.color2
  property color color3: Wal.Colors.color3
  property color color4: Wal.Colors.color4
  property color color5: Wal.Colors.color5
  property color color6: Wal.Colors.color6
  property color color7: Wal.Colors.color7
  property color color8: Wal.Colors.color8
  property color color9: Wal.Colors.color9
  property color color10: Wal.Colors.color10
  property color color11: Wal.Colors.color11
  property color color12: Wal.Colors.color12
  property color color13: Wal.Colors.color13
  property color color14: Wal.Colors.color14
  property color color15: Wal.Colors.color15
  property string fontFamily: "Jetbrains Mono Nerd Font"
  property int fontSize: 12

  required property var modelData

  property int cpuUsage: 0
  property var lastCpuTotal: 0
  property var lastCpuIdle: 0
  property int memUsage: 0
  property int temperatureValue: 0
  property string windowTitle: ""
  property string appid: ""
  property var tags: []
  property string dateStr: Qt.formatDateTime(new Date(), "MM-dd")
  property string fullDate: Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
  property string timeStr: Qt.formatDateTime(new Date(), "HH:mm")
  property string songTitle: ""
  property bool isPlaying: false
  property string pickedColor: ""

  anchors {
    top:true
    left:true
    right:true
  }

  implicitHeight: 25

  margins {
    top: 0
    left: 0
    right: 0
  }

  Rectangle {
    id: bar
    anchors.fill: parent
    color: panel.color0
    radius: 0
  }

  // ------------------- Time Update Timer -----------------
  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: {
      dateStr = Qt.formatDateTime(new Date(), "MM-dd")
      fullDate  = Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
      timeStr   = Qt.formatDateTime(new Date(), "HH:mm")
    }
  }
  // ----------------- Song Monitor and toggle -----------------
  Process {
    id: musicTitleProc
    command: ["sh", "-c", "rmpc song"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        data = JSON.parse(data)
        songTitle = data.metadata?.title ?? data.file
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: musicStatusProc
    command: ["sh", "-c", "rmpc status"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        data = JSON.parse(data)
        isPlaying = (data.state === "Play")
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      musicTitleProc.running = true
      musicStatusProc.running = true
    }
  }
  Process {
    id: musicToggleProc
    command: ["sh", "-c", "rmpc togglepause"]
  }

  //------------------- Color Picker -----------------
  Process {
    id: colorPickProc
    command: ["sh", "-c", "~/.config/quickshell/scripts/waypick.sh"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        pickedColor = data.trim()
      }
    }
  }

  // ----------------- Notification Trigger -----------------
  Process {
    id: notifProc
    command: ["sh", "-c", "swaync-client -t"]
  }

  // ----------------- Power Menu Trigger -----------------
  Process {
    id: powerProc
    command: ["sh", "-c", "~/.config/wlogout/wlogoutmango.sh"]
  }

  // ----------------- CPU Monitor -----------------
  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var p = data.trim().split(/\s+/)
        var idle = parseInt(p[4]) + parseInt(p[5])
        var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
        if (lastCpuTotal > 0) {
          cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
        }
        lastCpuTotal = total
        lastCpuIdle = idle
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }

  // ----------------- Memory Monitor -----------------
  Process {
    id: memProc
    command: ["sh", "-c", "free -m | grep Mem"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        var total = parseInt(parts[1]) || 1
        var used = parseInt(parts[2]) || 0
        memUsage = Math.round((used / total) * 100)
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: memProc.running = true
  }

  // ----------------- Temperature Monitor -----------------
  Process {
    id: tempProc
    command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone*/temp | head -1"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        temperatureValue = Math.round(parseInt(data.trim()) / 1000)
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: tempProc.running = true
  }

  // ----------------- Window Title -----------------
  Process {
    id: windowProc
    command: ["sh", "-c", "mmsg -wc"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        if (parts[1] === "title") {
          if (parts[2]) {
            windowTitle = parts[2]
            if (windowTitle === "nvim") {
              windowTitle = " Neovim"
            }
          } else {
            windowTitle = "mango"
          }
        } else {
          if (parts[2]) {
            appid = parts[2]
          } else {
            appid = ""
          }
        }
      }
    }
    Component.onCompleted: running = true
  }
  // ----------------- Tags Listener -----------------
  Process {
    id: tagProc
    command: ["mmsg", "-w", "-t"]
    stdout: SplitParser {
      onRead: function(line) {
      var newTags = panel.tags.slice()
      var parts = line.trim().split(/\s+/)
      if (parts.length >= 6 && parts[1] === "tag") {
        var index = parseInt(parts[2]) - 1
        var focused = parts[3] === "1"
        var windows = parseInt(parts[4])
        var urgent = parts[5] === "1"
        newTags[index] = {
          focused: focused,
          hasWindows: windows > 0,
          urgent: urgent
        }
        panel.tags = newTags
        }
      }
    }
    Component.onCompleted: running = true
  }

  // ----------------- Left Layout -----------------
  RowLayout {
    id: leftRowLayout
    spacing: -1
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
    }

    Rectangle {
      id: distroIcon
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 30
      color: panel.color0
      Text {
        anchors.centerIn: parent
        text: "󰣇"
        color: panel.color9
        font { family: panel.fontFamily; pixelSize: 26 }
      }
    }
    Text {
      text: ""
      color: panel.color0
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.right: parent.right
        text: ""
        color: panel.color1
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    Rectangle {
      id: windowTitleRect
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: windowTitleText.paintedWidth
      color: panel.color1
      Text {
        id: windowTitleText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: (appid && windowTitle) ? " " + appid + ": " + windowTitle + " " : " mango "
        color: panel.color15
        elide: Text.ElideRight
        font { family: panel.fontFamily; pixelSize: panel.fontSize }
      }
    }
    Text {
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }

  // ----------------- Middle Layout -----------------
  RowLayout {
    id: middleRowLayout
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
    }
    spacing: -1
    // Temperature arrow
    Rectangle {
      Layout.preferredWidth: panel.height
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.right: parent.right
        text: ""
        color: panel.color1
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // Temperature module
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 50
      color: panel.color1
      Text {
        anchors.centerIn: parent
        text: temperatureValue + "°C"
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
    }
    // Temperature arrow
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.left: parent.left
        text: ""
        color: panel.color1
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // Memory arrow. No rectangle so they sit flush
    Text {
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    // Memory module
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 50
      color: panel.color2
      Text {
        anchors.centerIn: parent
        text: "󰘚 " + memUsage + "%"
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
    }
    // Memory arrow
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.left: parent.left
        text: ""
        color: panel.color2
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // CPU arrow. No rectangle so they sit flush
    Text {
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    // CPU module
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 50
      color: panel.color3
      Text {
        anchors.centerIn: parent
        text: "󰍛 " + cpuUsage + "%"
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
    }
    // CPU arrow. We need a rectangle here to get proper spacing
    Rectangle {
      Layout.preferredWidth: panel.height
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.left: parent.left
        text: ""
        color: panel.color3
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // Workspace/Tags Display
    Repeater {
      model: panel.tags
      delegate: Row {
        spacing: -1
        visible: modelData.hasWindows || modelData.focused
        // Arrow
        Text {
          text: ""
          color: modelData.focused ? panel.color3 : "transparent"
          font.family: panel.fontFamily
          font.pixelSize: 20
        }
        // Number
        Rectangle {
          width: 24
          height: 26
          color: modelData.focused ? panel.color3 : panel.color0
          Text {
            anchors.centerIn: parent
            text: index + 1
            color: panel.color15
            font.family: panel.fontFamily
            font.pixelSize: 12
            font.bold: true
          }
        }
        // Arrow
        Text {
          text: ""
          color: modelData.focused ? panel.color3 : "transparent"
          font.family: panel.fontFamily
          font.pixelSize: 20
        }
      }
    }

    // Time arrow
    Rectangle {
      Layout.preferredWidth: panel.height
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.right: parent.right
        text: ""
        color: panel.color3
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // Time module
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 60
      color: panel.color3
      Text {
        anchors.centerIn: parent
        text: panel.timeStr
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
    }
    // date arrow
    Text {
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.right: parent.right
        text: ""
        color: panel.color2
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // Date module
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 60
      color: panel.color2
      Text {
        anchors.centerIn: parent
        text: dateStr
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
    }
    // tray arrow
    Text {
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        anchors.right: parent.right
        text: ""
        color: panel.color1
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    Rectangle {
      id: trayContainer
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: trayRow.implicitWidth + 20
      color: panel.color1
      Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4
        Repeater {
          model: SystemTray.items
          delegate: Image {
            id: trayIcon
            width: 20
            height: 20
            source: modelData.icon

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                  modelData.activate()
                } else if (mouse.button === Qt.RightButton) {
                  var globalPos = parent.mapToGlobal(Qt.point(0, parent.height))
                  modelData.display(panel, globalPos.x-20, globalPos.y-10)
                }
              }
            }
          }
        }
      }
    }
    Text {
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  // ----------------- Right Layout -----------------
  RowLayout {
    spacing: -1
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
    }
    // Music arrow. No rectangle so they sit flush
    Text {
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    // Music module
    Rectangle {
      id: music
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: musicText.paintedWidth
      color: panel.color1
      Text {
        id: musicText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: (isPlaying ? "  " + songTitle + " " : "  " + songTitle + " ")
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: 14; bold: true }
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          musicToggleProc.running = true
        }
      }
    }
    // music arrow
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        text: ""
        color: panel.color1
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    Text {
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    // Color Picker
    Rectangle {
      id: colorPicker
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: colorPickDisplay.paintedWidth + colorPickName.paintedWidth
      color: panel.color2
      Text {
        id: colorPickDisplay
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: " "
        color: pickedColor ? pickedColor : panel.color15
        font { family: panel.fontFamily}
      }
      Text {
        id: colorPickName
        anchors.left: colorPickDisplay.right
        anchors.verticalCenter: parent.verticalCenter
        color: panel.color15
        text: pickedColor ? pickedColor : " "
        font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          colorPickProc.running = true
        }
      }
    }
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        text: ""
        color: panel.color2
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // notif arrow
    Text {
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    Rectangle {
      id: notif
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 25
      color: panel.color3
      Text {
        anchors.centerIn: parent
        text: ""
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: 16; bold: true }
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          notifProc.running = true
        }
      }
    }
    Rectangle {
      Layout.preferredWidth: 0
      Layout.preferredHeight: panel.height
      color: "transparent"
      Text {
        text: ""
        color: panel.color3
        font { family: panel.fontFamily; pixelSize: 20 }
      }
    }
    // power arrow
    Text {
      text: ""
      color: panel.color0
      font { family: panel.fontFamily; pixelSize: 20 }
    }
    Rectangle {
      Layout.preferredHeight: parent.height
      Layout.preferredWidth: 25
      color: panel.color0
      Text {
        anchors.centerIn: parent
        text: ""
        color: panel.color15
        font { family: panel.fontFamily; pixelSize: panel.pixelSize; bold: true }
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          powerProc.running = true
        }
      }
    }
  }
}
