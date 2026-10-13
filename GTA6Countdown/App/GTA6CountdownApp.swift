import SwiftUI

/// Host app. WidgetKit extensions have to ship inside an app, so this just shows a live
/// countdown and tells you how to add the widget.
@main
struct GTA6CountdownApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 420, height: 260)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    private let launch: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 11; c.day = 19; c.hour = 0; c.minute = 0
        return Calendar.current.date(from: c) ?? .distantFuture
    }()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let mins = max(0, Int((launch.timeIntervalSince(ctx.date) / 60).rounded(.up)))
            VStack(spacing: 14) {
                Text("GTA VI COUNTDOWN")
                    .font(.headline).tracking(3)
                Text(String(format: "%02d : %02d : %02d", mins / 1440, (mins % 1440) / 60, mins % 60))
                    .font(.system(size: 44, weight: .heavy)).monospacedDigit()
                Text("Right-click the desktop → Edit Widgets… → search “GTA VI”.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }
}
