import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardStore: CardStore
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var navigationPath = NavigationPath()

    private var cardsForSelectedDate: [DailyCard] {
        cardStore.cards(for: selectedDate)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.86, green: 0.95, blue: 1.0), Color(red: 0.97, green: 0.98, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        musicCatalogLink
                        datePicker

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tus carticas")
                                .font(.title2.bold())
                                .foregroundStyle(Color(red: 0.10, green: 0.23, blue: 0.36))

                            ForEach(cardsForSelectedDate) { card in
                                NavigationLink(value: card) {
                                    CardRow(card: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationDestination(for: DailyCard.self) { card in
                CardDetailView(card: card)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onChange(of: selectedDate) { _, newDate in
                cardStore.ensureCards(for: newDate)
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "aleja", url.host == "today" else { return }
        let today = Calendar.current.startOfDay(for: .now)
        selectedDate = today
        cardStore.ensureCards(for: today)
        let hour = Calendar.current.component(.hour, from: .now)
        let slot: CardSlot = hour < 12 ? .morning : (hour < 18 ? .midday : .evening)
        if let card = cardStore.cards(for: today).first(where: { $0.slot == slot }) {
            navigationPath.append(card)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(Color.pink)
                Text("Para Aleja")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.23, blue: 0.36))
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.82))
            }
            Text("Pequeños detalles para acompañarte.")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.34))
            Text("Tres momentos al día, para cuando quieras leerlos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 14)
    }

    private var musicCatalogLink: some View {
        NavigationLink {
            MusicCatalogView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "headphones")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color(red: 0.12, green: 0.47, blue: 0.75), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rincón del sonido")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.34))
                    Text("Explora las canciones del catálogo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calendario")
                .font(.headline)
                .foregroundStyle(Color(red: 0.10, green: 0.23, blue: 0.36))
            DatePicker("Elegir día", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color(red: 0.13, green: 0.53, blue: 0.82))
                .padding(12)
                .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22))
        }
    }
}

private struct CardRow: View {
    let card: DailyCard

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: card.slot.symbol)
                .font(.title2)
                .foregroundStyle(Color(red: 0.10, green: 0.48, blue: 0.76))
                .frame(width: 52, height: 52)
                .background(Color(red: 0.86, green: 0.95, blue: 1.0), in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 5) {
                Text(card.slot.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(card.slot.timeLabel) · Toca para abrir")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(15)
        .background(.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.blue.opacity(0.08), lineWidth: 1))
    }
}
