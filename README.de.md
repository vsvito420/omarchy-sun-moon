<div align="center">

<img src="icon.svg" width="96" alt="Sun & Moon Icon">

# omarchy-sun-moon

**Eine Sonnenkurve im Stil der Apple Watch für die Omarchy-Leiste: der Lauf der Sonne über den Tag, mit einem Punkt, wo sie gerade steht.**
Für [Omarchy](https://omarchy.org) / Hyprland.

[![Omarchy](https://img.shields.io/badge/Omarchy-Shell_Plugin-1793d1?style=for-the-badge&logo=archlinux&logoColor=white)](https://omarchy.org)
[![QML](https://img.shields.io/badge/QML-Quickshell-41cd52?style=for-the-badge&logo=qt&logoColor=white)](#so-funktionierts)
[![Lizenz: MIT](https://img.shields.io/badge/Lizenz-MIT-green?style=for-the-badge)](LICENSE)
[![English](https://img.shields.io/badge/read_me-English-black?style=for-the-badge)](README.md)

![Das Sonne-&-Mond-Widget in der Omarchy-Leiste](screenshots/closeup.png)

</div>

---

## Was es zeigt

![Omarchy-Desktop mit dem Widget links neben der Uhr](screenshots/desktop.png)

| | |
|---|---|
| ☀️ **Sonnenkurve** | Die Sonnenhöhe über deinen Tag, von Mitternacht bis Mitternacht |
| ➖ **Horizont** | Eine dünne Linie. Darüber ist Tag (helle Kurve), darunter Nacht (gedimmte Kurve) |
| ⚪ **Sonnenpunkt** | Wo die Sonne gerade steht: tagsüber gefüllt, nach Sonnenuntergang hohl |
| 📍 **Dein Standort** | Nimmt den Standort aus dem Omarchy-Wetter-Widget und zieht mit, wenn du ihn änderst |
| 📦 **Keine Abhängigkeiten** | Reines QML, kein Netzwerk, kein API-Key. Alles wird lokal berechnet |

Die Kurve ändert sich mit den Jahreszeiten: im Sommer hoch und breit, im Winter flach und kurz.

## Installation

```bash
omarchy plugin add https://github.com/vsvito420/omarchy-sun-moon.git --enable
```

Das klont das Plugin nach `~/.config/omarchy/plugins/vsvito.sun-moon` und setzt das Widget in die Mitte der Leiste.
Verschieben, zum Beispiel direkt vor die Uhr:

```bash
omarchy bar move vsvito.sun-moon --before omarchy.clock
```

Aktualisieren mit `omarchy plugin update vsvito.sun-moon`, entfernen mit `omarchy plugin remove vsvito.sun-moon`.

## Standort

Das Widget liest `latitude` und `longitude` aus `~/.local/state/omarchy/settings/weather.json`. Dort speichert das
Omarchy-**Wetter**-Widget seinen Standort. Stell deinen Ort dort ein, und die Sonnenkurve passt sich sofort an.

Ohne Wetter-Standort nimmt es Berlin (52,52° N, 13,40° O).
Für einen anderen Ersatz-Standort änderst du `latitude` / `longitude` oben in `SunMoon.qml`.

## So funktioniert's

```
        ╭──●──╮            ● Sonne jetzt (gefüllt = Tag, hohl = Nacht)
 ──────╯       ╰──────     Horizont
 ╲___╱           ╲___╱     Nachtteil, gedimmt
 0:00     12:00     24:00
```

- **Sonnenstand:** die [USNO-Näherungsformel](https://aa.usno.navy.mil/faq/sun_approx), 96-mal über den Tag berechnet
  (alle 15 Minuten) und mit `QtQuick.Shapes` gezeichnet. Wo die Kurve den Horizont schneidet, wird sie geteilt.
- **Tag oder Nacht:** Der Punkt wird hohl, sobald die Sonne unter −0,833° steht, dem üblichen Wert inklusive Lichtbrechung.
- Aktualisiert sich jede Minute. Die Farben kommen von der Leiste und passen so zu jedem Omarchy-Theme.

## Voraussetzungen

- Omarchy mit der Quickshell-basierten Shell (Leisten-Widgets über `~/.config/omarchy/plugins/`)
- Läuft in einer waagerechten Leiste, oben oder unten

## Lizenz

[MIT](LICENSE) © 2026 vsvito420
