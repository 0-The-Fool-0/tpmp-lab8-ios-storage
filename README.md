# TPMP Lab 8 — iOS storage, location and maps

A coursework collection of Swift and Objective-C iOS examples covering plist and `UserDefaults` persistence, Core Data, Core Location, MapKit, and a pair of variant 3 applications: an audio library and Minsk parks browser.

## Structure and technology

- `example1`–`example7`: plist catalogue, demo authentication, location, maps/geocoding, booking, Core Data students and weather forecast.
- `task2-1`: Audioteka using plist, `UserDefaults`, collection views and localized UI.
- `task2-2`: MinskParks using MapKit, Core Location, Core Data and a weather API.
- Swift, Objective-C, UIKit, MapKit, Core Data, Xcode.

## Build and run

Use Xcode on macOS. The `example1`–`example7` and `task2-1` folders provide XcodeGen `project.yml` manifests; run `xcodegen generate` in the project folder, then open the generated Xcode project. `task2-2` includes `MinskParks.xcodeproj`. Run in an iOS Simulator or device. Weather examples require a personal OpenWeather API key. `OpenWeatherAPIKey` values in this snapshot are placeholders; configure a local key and do not commit it. No build or tests are claimed as run.

## Snapshot and attribution

This is a clean snapshot from the local working copy; it does not include private repository history. The local Git history records Lab 8 setup and documentation commits but does not identify authorship of the currently uncommitted application files. Individual contribution therefore needs manual clarification. Local archive files, upload helper scripts, report drafts and simulator screenshots were excluded; the working source folders were retained.

This is coursework, not a production app. Authentication examples are demonstrations only.
