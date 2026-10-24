import SwiftUI
import AVFoundation

struct CardDetailView: View {
    @EnvironmentObject private var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var card: DailyCard
    @State private var messageDraft: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var playbackError: String?

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
        .onDisappear { stopPlayback() }
    }

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Música", systemImage: "music.note")
                .font(.headline)
            if let title = card.songTitle {
                Text(title).font(.subheadline.weight(.semibold))
                if let artist = card.songArtist {
                    Text(artist).font(.caption).foregroundStyle(.secondary)
                }
                Button {
                    togglePlayback()
                } label: {
                    Label(isPlaying ? "Pausar" : "Reproducir", systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(card.songURL == nil)
                if let playbackError {
                    Text(playbackError).font(.caption).foregroundStyle(.red)
                }
            } else {
                Text("Todavía no hay una canción asignada a esta cartica.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("La música nunca se inicia automáticamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
    }

    private func togglePlayback() {
        guard let url = card.songURL else { return }
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            if player == nil {
                player = AVPlayer(url: url)
            }
            player?.play()
            isPlaying = true
        } catch {
            playbackError = "No se pudo iniciar el audio. Inténtalo de nuevo."
            isPlaying = false
        }
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
