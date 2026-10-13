import Foundation

/// Post-launch message pool. Add, remove or reword freely.
/// `.official` = something Rockstar has stated or shown in trailers / on its website.
/// `.theory`   = widely reported or fan-analysed, NOT confirmed by Rockstar.
struct Fact: Identifiable {
    enum Category: String {
        case lucia = "LUCIA"
        case jason = "JASON"
        case crew = "THE CREW"
        case city = "VICE CITY"
        case leonida = "LEONIDA"
        case spots = "CHECK THIS OUT"
        case trailers = "TRAILERS"

        var icon: String {
            switch self {
            case .lucia, .jason: return "🔫"
            case .crew: return "💎"
            case .city: return "🌴"
            case .leonida: return "🐊"
            case .spots: return "📍"
            case .trailers: return "🎬"
            }
        }
    }
    enum Kind { case official, theory }

    let category: Category
    let kind: Kind
    let text: String
    var id: String { text }
}

extension Fact {
    static let all: [Fact] = [
        // MARK: Lucia
        .init(category: .lucia, kind: .official,
              text: "Lucia Caminos is one of two lead characters — the first woman to headline a mainline GTA in the 3D era."),
        .init(category: .lucia, kind: .official,
              text: "Trailer 1 opens with Lucia in a Leonida correctional facility, before her release."),
        .init(category: .lucia, kind: .official,
              text: "Rockstar's bio says Lucia was raised to fight for her family — and that it landed her in prison."),
        .init(category: .lucia, kind: .theory,
              text: "THEORY: Lucia and Jason's \"Bonnie & Clyde\" dynamic is a nod to the classic outlaw-couple crime story."),
        .init(category: .lucia, kind: .official,
              text: "Trailer 2 shows Lucia and Jason as partners — they're in this together from the start."),

        // MARK: Jason
        .init(category: .jason, kind: .official,
              text: "Jason Duval is the second lead. Trailer 2 leans heavily on his side of the story."),
        .init(category: .jason, kind: .official,
              text: "Rockstar's bio says Jason served in the Army before drifting into trouble in the Leonida Keys."),
        .init(category: .jason, kind: .theory,
              text: "THEORY: With two leads, fans expect GTA V-style switching between Lucia and Jason. Rockstar hasn't detailed it."),

        // MARK: The crew
        .init(category: .crew, kind: .official,
              text: "Rockstar's character page includes Cal Hampton, Boobie Ike, Dre'Quan Priest, Raul Bautista and Brian Heder."),
        .init(category: .crew, kind: .official,
              text: "Boobie Ike is billed as a local Vice City entrepreneur. Think gold chains and big sunglasses."),
        .init(category: .crew, kind: .official,
              text: "Raul Bautista is a bank robber with a plan, per Rockstar's character page."),
        .init(category: .crew, kind: .official,
              text: "Real Dimez, the duo of Roxy and Bae-Luxe, is among the official character profiles."),
        .init(category: .crew, kind: .theory,
              text: "THEORY: The man with the rifle in front of a bank in the key art is widely taken to be Raul Bautista."),

        // MARK: Vice City
        .init(category: .city, kind: .official,
              text: "Vice City is back. The Miami-inspired city first appeared in 2002's GTA: Vice City."),
        .init(category: .city, kind: .official,
              text: "Vice City sits in Leonida, Rockstar's take on the state of Florida."),
        .init(category: .city, kind: .official,
              text: "Neon, palm trees, beaches and nightclubs are all over the trailers. The Vice City vibe is intact."),
        .init(category: .city, kind: .theory,
              text: "THEORY: The 2002 Vice City map is expected to be just one part of a much bigger Leonida."),
        .init(category: .city, kind: .official,
              text: "Both trailers are styled like viral phone clips and social posts — Leonida is very online."),

        // MARK: Leonida
        .init(category: .leonida, kind: .official,
              text: "Rockstar's site lists Leonida's regions: Leonida Keys, Grassrivers, Port Gellhorn, Ambrosia, Mount Kalaga and Vice City."),
        .init(category: .leonida, kind: .official,
              text: "The Leonida Keys are Rockstar's take on the Florida Keys — islands, boats and bridges."),
        .init(category: .leonida, kind: .official,
              text: "Grassrivers is Leonida's swampland, the Everglades-inspired region. Mind the gators."),
        .init(category: .leonida, kind: .official,
              text: "Mount Kalaga National Park is a wilderness region — a break from the neon."),
        .init(category: .leonida, kind: .official,
              text: "Alligators and flamingos keep turning up in the trailers. Leonida wildlife is part of the look."),
        .init(category: .leonida, kind: .theory,
              text: "THEORY: Ambrosia, shown as farmland, is expected to be Leonida's rural stretch."),

        // MARK: Places / things to check out
        .init(category: .spots, kind: .official,
              text: "Go for a boat ride. Speedboats and watercraft are all over the trailers."),
        .init(category: .spots, kind: .official,
              text: "Look up. Trailer 1 and 2 both show helicopters and floatplane-style aircraft over the water."),
        .init(category: .spots, kind: .official,
              text: "Stunt bikers are shown popping wheelies past police cars. Try it on a bike near the coast."),
        .init(category: .spots, kind: .official,
              text: "Cruise the beachfront. Palm-lined streets and Art Deco buildings fill the trailers."),
        .init(category: .spots, kind: .theory,
              text: "THEORY: Fans expect a big return of boat, jet-ski and swamp-airboat activities."),

        // MARK: Trailers / background
        .init(category: .trailers, kind: .official,
              text: "Trailer 1 landed on Dec 4, 2023 and set a record for views in 24 hours."),
        .init(category: .trailers, kind: .official,
              text: "Trailer 1 uses Tom Petty's \"Love Is a Long Road\" — it's a Vice City anthem now."),
        .init(category: .trailers, kind: .official,
              text: "Trailer 2 arrived May 6, 2025 and put Lucia and Jason's partnership front and centre."),
        .init(category: .trailers, kind: .official,
              text: "GTA VI is built for PlayStation 5 and Xbox Series X|S. A PC version hasn't been announced."),
        .init(category: .trailers, kind: .official,
              text: "Release: Nov 19, 2026. It was delayed twice from the original 2025 target."),
    ]

    /// Deterministic, random-looking pick per half-hour slot, so every widget size shows the same line
    /// and consecutive slots never repeat.
    static func pick(slot: Int) -> Fact {
        func index(_ s: Int) -> Int {
            var x = UInt64(bitPattern: Int64(s)) &* 6364136223846793005 &+ 1442695040888963407
            x ^= x >> 33
            x = x &* 0xff51afd7ed558ccd
            x ^= x >> 33
            return Int(x % UInt64(all.count))
        }
        var i = index(slot)
        if i == index(slot - 1) { i = (i + 1) % all.count }
        return all[i]
    }
}
