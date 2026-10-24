import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var card: DailyCard
    @State private var messageDraft: String

    init(card: DailyCard) {
        _card = State(initialValue: card)
        _messageDraft = State(initialValue: card.message)
    }

    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.96, blue: 1.0).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: card.slot.symbol)
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.slot.title).font(.title2.bold())
                            Text("\(card.dayKey) · \(card.slot.timeLabel)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text("Tu mensaje")
                        .font(.headline)
                    TextEditor(text: $messageDraft)
                        .frame(minHeight: 220)
                        .padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        .scrollContentBackground(.hidden)

                    Button {
                        card.message = messageDraft
                        cardStore.update(card)
                        dismiss()
                    } label: {
                        Label("Guardar cartica", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 16))
                    }

                    musicSection
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Canción del día", systemImage: "music.note")
                .font(.headline)
            if let title = card.songTitle {
                Text(title).font(.subheadline.weight(.semibold))
                if let artist = card.songArtist {
                    Text(artist).font(.caption).foregroundStyle(.secondary)
                }
                if let url = card.songURL {
                    Link(destination: url) {
                        Label("Abrir canción", systemImage: "play.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
                    }
                    Text("La canción solo se abre cuando tocas el botón. La reproducción y el audio en segundo plano dependen de YouTube y de la app disponible en el iPhone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Todavía no hay un enlace disponible para esta canción.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Todavía no hay una canción asignada a esta cartica.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
    }
}
