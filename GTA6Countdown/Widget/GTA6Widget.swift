import SwiftUI
import WidgetKit

// MARK: - Launch date

enum Launch {
    /// Nov 19, 2026 at 12:00 AM in the viewer's local time zone.
    static let date: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 11; c.day = 19; c.hour = 0; c.minute = 0
        return Calendar.current.date(from: c) ?? .distantFuture
    }()

    /// How often the post-launch message changes.
    static let messageInterval: TimeInterval = 30 * 60
}

// MARK: - Timeline

struct CountdownParts {
    let days: Int, hours: Int, minutes: Int

    init(from now: Date, to target: Date) {
        let seconds = max(0, target.timeIntervalSince(now))
        let total = Int((seconds / 60).rounded(.up))   // round up so "00:00:01" reads as 1 minute left
        days = total / 1440
        hours = (total % 1440) / 60
        minutes = total % 60
    }
}

struct CountdownEntry: TimelineEntry {
    enum Content {
        case countdown(CountdownParts)
        case message(Fact)
    }
    let date: Date
    let content: Content
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry { entry(at: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let now = Date()
        let minuteStart = Calendar.current.dateInterval(of: .minute, for: now)?.start ?? now
        var dates: [Date] = []

        if now < Launch.date {
            // One entry per minute for the next hour, plus one exactly at launch if it falls inside.
            dates = (0..<60).map { minuteStart.addingTimeInterval(Double($0) * 60) }
            if let last = dates.last, Launch.date > minuteStart, Launch.date <= last {
                dates.append(Launch.date)
            }
        } else {
            // After launch: a new random message every 30 minutes, 24 hours at a time.
            let slot = floor(now.timeIntervalSince(Launch.date) / Launch.messageInterval)
            let slotStart = Launch.date.addingTimeInterval(slot * Launch.messageInterval)
            dates = (0..<48).map { slotStart.addingTimeInterval(Double($0) * Launch.messageInterval) }
        }

        let entries = dates.sorted().map { entry(at: $0) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(at date: Date) -> CountdownEntry {
        if date < Launch.date {
            return CountdownEntry(date: date, content: .countdown(CountdownParts(from: date, to: Launch.date)))
        }
        let slot = Int(floor(date.timeIntervalSince(Launch.date) / Launch.messageInterval))
        return CountdownEntry(date: date, content: .message(Fact.pick(slot: slot)))
    }
}

// MARK: - Styling per widget size

private struct Metrics {
    let number: CGFloat
    let label: CGFloat
    let body: CGFloat
    let inset: CGFloat
    let shortLabels: Bool

    init(_ family: WidgetFamily) {
        switch family {
        case .systemSmall:      self = Metrics(number: 34, label: 8,  body: 11, inset: 10, shortLabels: true)
        case .systemMedium:     self = Metrics(number: 52, label: 9,  body: 13, inset: 14, shortLabels: false)
        case .systemLarge:      self = Metrics(number: 66, label: 11, body: 17, inset: 18, shortLabels: false)
        default:                self = Metrics(number: 92, label: 13, body: 20, inset: 22, shortLabels: false)
        }
    }

    private init(number: CGFloat, label: CGFloat, body: CGFloat, inset: CGFloat, shortLabels: Bool) {
        self.number = number; self.label = label; self.body = body
        self.inset = inset; self.shortLabels = shortLabels
    }
}

private let pink = Color(red: 1.0, green: 0.60, blue: 0.84)

// MARK: - Views

struct ArtBackground: View {
    let family: WidgetFamily
    let dimming: Double

    private let aspect: CGFloat = 2000.0 / 1133.0

    var body: some View {
        GeometryReader { geo in
            // Small widget is square, so zoom in on Lucia & Jason; everything else shows the full art.
            let zoom: CGFloat = family == .systemSmall ? 1.6 : 1.0
            let focus = family == .systemSmall ? CGPoint(x: 0.27, y: 0.38) : CGPoint(x: 0.5, y: 0.5)
            let w = max(geo.size.width, geo.size.height * aspect) * zoom
            let h = w / aspect
            let x = min(0, max(geo.size.width - w, geo.size.width / 2 - focus.x * w))
            let y = min(0, max(geo.size.height - h, geo.size.height / 2 - focus.y * h))

            ZStack(alignment: .topLeading) {
                Image("Background")
                    .resizable()
                    .frame(width: w, height: h)
                    .offset(x: x, y: y)
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.35),
                        .init(color: Color(red: 0.04, green: 0.01, blue: 0.13).opacity(dimming), location: 1.0),
                    ],
                    startPoint: .top, endPoint: .bottom)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

struct CountdownView: View {
    let parts: CountdownParts
    let family: WidgetFamily

    var body: some View {
        let m = Metrics(family)
        HStack(alignment: .top, spacing: m.number * 0.12) {
            unit(parts.days, m.shortLabels ? "D" : "DAYS", m)
            colon(m)
            unit(parts.hours, m.shortLabels ? "H" : "HOURS", m)
            colon(m)
            unit(parts.minutes, m.shortLabels ? "M" : "MINUTES", m)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, m.inset)
        .padding(.bottom, m.inset)
    }

    private func unit(_ value: Int, _ label: String, _ m: Metrics) -> some View {
        VStack(spacing: 3) {
            Text(String(format: "%02d", value))
                .font(.system(size: m.number, weight: .heavy))
                .monospacedDigit()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: m.label, weight: .semibold))
                .tracking(m.label * 0.25)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private func colon(_ m: Metrics) -> some View {
        Text(":")
            .font(.system(size: m.number * 0.85, weight: .heavy))
            .foregroundStyle(.white.opacity(0.7))
            .offset(y: -m.number * 0.06)
    }
}

struct MessageView: View {
    let fact: Fact
    let family: WidgetFamily

    var body: some View {
        let m = Metrics(family)
        VStack(alignment: .leading, spacing: m.body * 0.4) {
            HStack(spacing: 6) {
                Text("\(fact.category.icon) \(fact.category.rawValue)")
                    .font(.system(size: max(9, m.body * 0.65), weight: .bold))
                    .tracking(2)
                    .foregroundStyle(pink)
                Spacer(minLength: 0)
                if fact.kind == .theory {
                    Text("THEORY")
                        .font(.system(size: max(8, m.body * 0.55), weight: .bold))
                        .tracking(1)
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(.white.opacity(0.18), in: Capsule())
                        .foregroundStyle(.white)
                }
            }
            Text(fact.text)
                .font(.system(size: m.body, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(m.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.07, green: 0.03, blue: 0.16).opacity(0.8),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(pink.opacity(0.5), lineWidth: 1))
        .padding(m.inset)
    }
}

struct GTA6WidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            switch entry.content {
            case .countdown(let parts): CountdownView(parts: parts, family: family)
            case .message(let fact):    MessageView(fact: fact, family: family)
            }
        }
        .containerBackground(for: .widget) {
            ArtBackground(family: family, dimming: isMessage ? 0.95 : 0.85)
        }
    }

    private var isMessage: Bool {
        if case .message = entry.content { return true }
        return false
    }
}

// MARK: - Widget

@main
struct GTA6CountdownWidget: Widget {
    let kind = "GTA6CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GTA6WidgetView(entry: entry)
        }
        .configurationDisplayName("GTA VI Countdown")
        .description("Days : Hours : Minutes until Nov 19, 2026. After launch, shows random GTA VI facts.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Xcode previews

#Preview("Countdown XL", as: .systemExtraLarge) {
    GTA6CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, content: .countdown(CountdownParts(from: .now, to: .now.addingTimeInterval(36 * 86400 + 6 * 3600 + 19 * 60))))
}

#Preview("Countdown Small", as: .systemSmall) {
    GTA6CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, content: .countdown(CountdownParts(from: .now, to: .now.addingTimeInterval(36 * 86400 + 6 * 3600 + 19 * 60))))
}

#Preview("Message", as: .systemMedium) {
    GTA6CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, content: .message(Fact.all[0]))
    CountdownEntry(date: .now, content: .message(Fact.all[7]))
}
