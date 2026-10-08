# Sonnenkurve für die Bar

<img src="https://raw.githubusercontent.com/vsvito420/omarchy-sun-moon/main/icon.svg" width="72" alt="Icon der Sonnenkurve">

Ein kleines Widget für die Omarchy-Bar, links neben der Uhr: die Sonnenhöhe über den ganzen Tag
als Kurve, ein Horizont und ein Punkt, wo die Sonne gerade steht.

![Die Sonnenkurve in der Bar, neben Uhr und Wetter](https://raw.githubusercontent.com/vsvito420/omarchy-sun-moon/main/screenshots/closeup.png)

## Was es zeigt

- **Kurve** – die Sonnenhöhe von Mitternacht bis Mitternacht
  - hell über dem Horizont (Tag), gedimmt darunter (Nacht)
  - im Sommer hoch und breit, im Winter flach und kurz
- **Horizont** – dünne Linie in der Mitte
- **Sonnenpunkt** – tagsüber gefüllt, nach Sonnenuntergang hohl
- **Standort** – kommt aus dem Omarchy-Wetter-Widget und zieht mit, wenn man ihn dort ändert
  - ohne Wetter-Standort: Berlin (52,52° N, 13,40° O)

![Omarchy-Desktop mit der Sonnenkurve unten in der Mitte](https://raw.githubusercontent.com/vsvito420/omarchy-sun-moon/main/screenshots/desktop.png)

## Installieren

```bash
omarchy plugin add https://github.com/vsvito420/omarchy-sun-moon.git --enable
```

Legt das Plugin nach `~/.config/omarchy/plugins/vsvito.sun-moon` und setzt das Widget in die Mitte der Bar.

## So funktioniert's

- **Code:** [`SunMoon.qml`](https://github.com/vsvito420/omarchy-sun-moon/blob/main/SunMoon.qml) – reines QML, kein Netzwerk, kein API-Key
- **Sonnenstand:** [USNO-Näherungsformel](https://aa.usno.navy.mil/faq/sun_approx), 96-mal pro Tag (alle 15 Minuten) berechnet
  und mit `QtQuick.Shapes` gezeichnet; am Horizont wird die Kurve geteilt
- **Tag oder Nacht:** Der Punkt wird hohl, sobald die Sonne unter −0,833° steht (inklusive Lichtbrechung)
- **Standort:** liest `latitude` / `longitude` aus `~/.local/state/omarchy/settings/weather.json`
- aktualisiert sich jede Minute, die Farben kommen von der Bar und passen so zu jedem Theme

## Siehe auch

- [[Omarchy]]
- [[AirPods unter Omarchy]], [[Energieprofil-Tacho für die Bar]]
