import SwiftUI

struct MusicCatalogView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var selectedCategory = "Todas"

    private let categories = ["Todas", "Amor", "Filosófica", "Hot", "Ambiente"]

    private var filteredSongs: [CatalogSong] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cardStore.songs.filter { song in
            let matchesCategory = selectedCategory == "Todas" || song.categoryTitle == selectedCategory
            let matchesSearch = query.isEmpty
                || song.title.localizedCaseInsensitiveContains(query)
                || song.artist.localizedCaseInsensitiveContains(query)
                || song.categoryTitle.localizedCaseInsensitiveContains(query)
                || (song.note?.localizedCaseInsensitiveContains(query) ?? false)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rincón del sonido")
                        .font(.title2.bold())
                    Text("\(cardStore.songs.count) canciones del catálogo original. Elige una para abrirla manualmente.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section {
                Picker("Categoría", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
            }

            Section("Canciones · \(filteredSongs.count)") {
                if filteredSongs.isEmpty {
                    ContentUnavailableView(
                        "No encontramos canciones",
                        systemImage: "music.note.list",
                        description: Text("Prueba con otro título, artista, categoría o palabra clave.")
                    )
                } else {
                    ForEach(filteredSongs) { song in
                        HStack(spacing: 12) {
                            Image(systemName: "music.note")
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .frame(width: 42, height: 42)
                                .background(Color.blue.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(song.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(song.artist)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(song.categoryTitle)
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                                if song.youtubeID == nil || song.youtubeID?.isEmpty == true {
                                    Text("Abrirá una búsqueda en YouTube")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer(minLength: 4)
                            if let url = song.youtubeURL {
                                Link(destination: url) {
                                    Image(systemName: song.youtubeID?.isEmpty == false ? "play.circle.fill" : "magnifyingglass")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }
                                .accessibilityLabel(
                                    song.youtubeID?.isEmpty == false
                                        ? "Abrir \(song.title) en YouTube"
                                        : "Buscar \(song.title) de \(song.artist) en YouTube"
                                )
                            } else {
                                Image(systemName: "link.slash")
                                    .foregroundStyle(.tertiary)
                                    .accessibilityLabel("Enlace pendiente")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Buscar canción, artista o categoría")
        .navigationTitle("Música")
        .navigationBarTitleDisplayMode(.inline)
    }
}
