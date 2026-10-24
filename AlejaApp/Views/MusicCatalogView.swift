import SwiftUI

struct MusicCatalogView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var searchText = ""
    @State private var selectedCategory = "Todas"

    private let categories = ["Todas", "Amor", "Filosófica", "Hot", "Ambiente"]

    private var filteredSongs: [CatalogSong] {
        cardStore.songs.filter { song in
            let matchesCategory = selectedCategory == "Todas" || song.categoryTitle == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || song.title.localizedCaseInsensitiveContains(query)
                || song.artist.localizedCaseInsensitiveContains(query)
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
                        description: Text("Prueba con otro título, artista o categoría.")
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
                        }
                        Spacer(minLength: 4)
                        if let url = song.youtubeURL {
                            Link(destination: url) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                            .accessibilityLabel("Abrir \(song.title) en YouTube")
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
        .searchable(text: $searchText, prompt: "Buscar canción o artista")
        .navigationTitle("Música")
        .navigationBarTitleDisplayMode(.inline)
    }
}
