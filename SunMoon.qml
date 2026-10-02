import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Apple Watch "Solar" style: the sun's elevation over the local day as a
// curve, a horizon line, and a dot at the sun's current position.
BarWidget {
  id: root
  moduleName: "vsvito.sun-moon"

  // Location comes from the weather widget's setting; Friedrichshafen (Bodensee)
  // is the fallback when none is configured.
  property real latitude: 47.66
  property real longitude: 9.48
  property date now: new Date()

  readonly property color fg: bar ? bar.foreground : "white"
  readonly property color bg: bar ? bar.background : "black"

  readonly property real graphWidth: 44
  readonly property real graphHeight: Math.max(12, barSize - 10)
  readonly property real dotRadius: 2.5
  readonly property int samples: 96

  // Sampled elevations for the local day, and the scale that fits them in the graph
  readonly property var dayCurve: {
    var start = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    var points = [], maxAbs = 1
    for (var i = 0; i <= samples; i++) {
      var alt = sunAltitude(new Date(start + i / samples * 86400000), latitude, longitude)
      points.push(alt)
      maxAbs = Math.max(maxAbs, Math.abs(alt))
    }
    return { start: start, points: points, maxAbs: maxAbs }
  }
  readonly property real currentAltitude: sunAltitude(now, latitude, longitude)
  readonly property bool isDay: currentAltitude > -0.833

  implicitWidth: vertical ? barSize : graphWidth + 8
  implicitHeight: barSize

  function xFor(fraction) { return dotRadius + fraction * (graphWidth - 2 * dotRadius) }
  function yFor(alt) { return graphHeight / 2 - alt / dayCurve.maxAbs * (graphHeight / 2 - dotRadius) }

  // Split the curve at the horizon into daylight (above) or night segments
  function segments(above) {
    var pts = dayCurve.points, out = [], current = []
    for (var i = 0; i < pts.length; i++) {
      var inside = (pts[i] >= 0) === above
      if (i > 0 && (pts[i - 1] >= 0) !== (pts[i] >= 0)) {
        var t = pts[i - 1] / (pts[i - 1] - pts[i])
        var crossing = Qt.point(xFor((i - 1 + t) / samples), yFor(0))
        if (inside) {
          current = [crossing]
        } else {
          current.push(crossing)
          if (current.length > 1) out.push(current)
          current = []
        }
      }
      if (inside) current.push(Qt.point(xFor(i / samples), yFor(pts[i])))
    }
    if (current.length > 1) out.push(current)
    return out
  }

  // Low-precision solar position (https://aa.usno.navy.mil/faq/sun_approx)
  function sunAltitude(date, lat, lon) {
    var rad = Math.PI / 180
    var n = date.getTime() / 86400000 + 2440587.5 - 2451545
    var g = (357.529 + 0.98560028 * n) * rad
    var q = 280.459 + 0.98564736 * n
    var l = (q + 1.915 * Math.sin(g) + 0.020 * Math.sin(2 * g)) * rad
    var e = (23.439 - 0.00000036 * n) * rad
    var ra = Math.atan2(Math.cos(e) * Math.sin(l), Math.cos(l)) / rad
    var dec = Math.asin(Math.sin(e) * Math.sin(l))
    var gmst = 18.697374558 + 24.06570982441908 * n
    var ha = (gmst * 15 + lon - ra) * rad
    return Math.asin(Math.sin(lat * rad) * Math.sin(dec) + Math.cos(lat * rad) * Math.cos(dec) * Math.cos(ha)) / rad
  }

  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/settings/weather.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var data = JSON.parse(text())
        var lat = parseFloat(data.latitude), lon = parseFloat(data.longitude)
        if (!isNaN(lat) && !isNaN(lon)) {
          root.latitude = lat
          root.longitude = lon
        }
      } catch (e) {}
    }
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Item {
    id: graph
    width: root.graphWidth
    height: root.graphHeight
    anchors.centerIn: parent

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer

      // Horizon
      ShapePath {
        strokeColor: Qt.alpha(root.fg, 0.35)
        strokeWidth: 1
        fillColor: "transparent"
        startX: 0; startY: root.yFor(0)
        PathLine { x: root.graphWidth; y: root.yFor(0) }
      }

      // Night part of the curve, dimmed
      ShapePath {
        strokeColor: Qt.alpha(root.fg, 0.35)
        strokeWidth: 1.5
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathMultiline { paths: root.segments(false) }
      }

      // Daylight part of the curve
      ShapePath {
        strokeColor: root.fg
        strokeWidth: 1.5
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathMultiline { paths: root.segments(true) }
      }
    }

    // The sun: filled by day, hollow below the horizon
    Rectangle {
      readonly property real fraction: (root.now.getTime() - root.dayCurve.start) / 86400000
      width: root.dotRadius * 2 + 1
      height: width
      radius: width / 2
      x: root.xFor(fraction) - width / 2
      y: root.yFor(root.currentAltitude) - height / 2
      color: root.isDay ? root.fg : root.bg
      border.color: root.fg
      border.width: root.isDay ? 0 : 1
    }
  }
}
