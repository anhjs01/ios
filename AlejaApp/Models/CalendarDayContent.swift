import Foundation

struct CalendarDayContent: Codable, Identifiable {
    let dia: Int
    let fecha: String
    let fechaTexto: String
    let categoria: String
    let icono: String
    let tono: String
    let color: CalendarColor
    let buenosDias: String
    let poema: [String]
    let detalle: String
    let buenasNoches: String
    let cancionTitulo: String
    let cancionArtista: String
    let youtubeId: String?
    let cancionUrl: String?

    var id: String { fecha }

    var date: Date {
        let parts = fecha.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return .now }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) ?? .now
    }

    var middayMessage: String {
        (poema + [detalle]).joined(separator: "\n\n")
    }
}

struct CalendarColor: Codable {
    let principal: String
    let suave: String
    let oscuro: String
}

struct CatalogSong: Codable, Identifiable, Hashable {
    let id: String
    let category: String
    let title: String
    let artist: String
    let youtubeID: String?
    let note: String?

    var youtubeURL: URL? {
        if let youtubeID, !youtubeID.isEmpty {
            return URL(string: "https://www.youtube.com/watch?v=\(youtubeID)")
        }
        var components = URLComponents(string: "https://www.youtube.com/results")
        components?.queryItems = [URLQueryItem(name: "search_query", value: "\(title) \(artist)")]
        return components?.url
    }

    var categoryTitle: String {
        switch category {
        case "amor": return "Amor"
        case "filosofica": return "Filosófica"
        case "hot": return "Hot"
        case "ambiente": return "Ambiente"
        default: return category.capitalized
        }
    }
}
