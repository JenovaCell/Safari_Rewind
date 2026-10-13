# GTA VI Countdown (macOS widget)

Desktop widget (WidgetKit) counting down to **Nov 19, 2026 @ 12:00 AM (local time)** as `DAYS : HOURS : MINUTES`
in white over the GTA VI key art. After launch it swaps to a random GTA VI fact every 30 minutes
(characters, Vice City / Leonida, things to check out, trailers). Theory entries carry a `THEORY` badge.

Sizes: small (art cropped to Lucia & Jason), medium, large, extra large.

## Build (needs a Mac with Xcode 15+, macOS 14+)

```sh
brew install xcodegen
cd GTA6Countdown
xcodegen generate
open GTA6Countdown.xcodeproj
```

1. Select the `GTA6Countdown` and `GTA6CountdownWidget` targets → *Signing & Capabilities* → pick your Team
   (a free Apple ID works). Change the bundle ID prefix `com.example` in `project.yml` if you like.
2. Run the `GTA6Countdown` scheme once (it registers the widget).
3. Right-click the desktop → *Edit Widgets…* → search **GTA VI** → add it.

No XcodeGen? Create a macOS App + Widget Extension in Xcode, then drop in `Widget/GTA6Widget.swift`,
`Widget/Facts.swift` and `Widget/Assets.xcassets` (replace the template widget files) and `App/GTA6CountdownApp.swift`.

## Files

| File | What |
|---|---|
| `Widget/GTA6Widget.swift` | Launch date, timeline (per-minute countdown, per-30-min messages), all views |
| `Widget/Facts.swift` | The message pool. Edit freely |
| `Widget/Assets.xcassets` | Background art |
| `App/GTA6CountdownApp.swift` | Tiny host app (WidgetKit requires one) |
| `project.yml` | XcodeGen spec |

## Notes

- The launch date lives in `Launch.date` (widget) and `ContentView.launch` (app). Change both if it moves again.
- macOS decides how often a widget really refreshes. The timeline supplies a minute-by-minute entry list, which normally works well, but the number can occasionally lag a minute.
- Facts were written from Rockstar's trailers and character/region pages plus press coverage. I couldn't check them against live sources while writing, so skim `Facts.swift` and delete anything you disagree with.
