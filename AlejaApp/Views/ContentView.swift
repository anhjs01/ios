import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cardStore: CardStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var navigationPath = NavigationPath()
    @StateObject private var reminderManager = ReminderManager()
    @State private var showReminderAlert = false

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
                        reminderControl
                        datePicker
                        dailyTheme

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tus carticas")
                                .font(.title2.bold())
                                .foregroundStyle(Color(red: 0.10, green: 0.23, blue: 0.36))

                            ForEach(cardsForSelectedDate) { card in
                                NavigationLink(value: card) {
                                    CardRow(card: card)
                                }
                                .buttonStyle(.plain)
                                .accessibilityHint("Abre la cartica para leerla, editar el mensaje y consultar la canción.")
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
            .alert("Recordatorios", isPresented: $showReminderAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(reminderManager.statusMessage ?? "Puedes gestionar los recordatorios en Ajustes.")
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onChange(of: selectedDate) { _, newDate in
                cardStore.ensureCards(for: newDate)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    reminderManager.refreshStatus()
                }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "aleja" else { return }

        let today = Calendar.current.startOfDay(for: .now)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        let requestedDayKey = queryItems.first(where: { $0.name == "date" })?.value
        let requestedSlotValue = queryItems.first(where: { $0.name == "slot" })?.value.flatMap(Int.init)
        let requestedSlot = requestedSlotValue.flatMap(CardSlot.init(rawValue:))

        let targetDate: Date
        if url.host == "card", let dayKey = requestedDayKey {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = Calendar.current.timeZone
            formatter.dateFormat = "yyyy-MM-dd"
            targetDate = formatter.date(from: dayKey).map(Calendar.current.startOfDay(for:)) ?? today
        } else if url.host == "today" {
            targetDate = today
        } else {
            return
        }

        selectedDate = targetDate
        cardStore.ensureCards(for: targetDate)
        let hour = Calendar.current.component(.hour, from: .now)
        let fallbackSlot: CardSlot = hour < 12 ? .morning : (hour < 18 ? .midday : .evening)
        let slot = requestedSlot ?? fallbackSlot
        if let card = cardStore.cards(for: targetDate).first(where: { $0.slot == slot }) {
            // Reset the path so repeated widget taps do not stack duplicate destinations.
            navigationPath = NavigationPath()
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

    private var reminderControl: some View {
        Button {
            Task {
                if reminderManager.isEnabled {
                    reminderManager.disableDailyReminders()
                } else {
                    await reminderManager.enableDailyReminders()
                }
                showReminderAlert = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: reminderManager.isEnabled ? "bell.badge.fill" : "bell")
                    .font(.title2)
                    .foregroundStyle(reminderManager.isEnabled ? .white : Color(red: 0.12, green: 0.47, blue: 0.75))
                    .frame(width: 46, height: 46)
                    .background(reminderManager.isEnabled ? Color(red: 0.12, green: 0.47, blue: 0.75) : Color.blue.opacity(0.09), in: RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminderManager.isEnabled ? "Recordatorios activados" : "Activar recordatorios")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.34))
                    Text("06:00 · 12:00 · 18:00")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: reminderManager.isEnabled ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(reminderManager.isEnabled ? Color.green : Color.gray)
            }
            .padding(14)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var dailyTheme: some View {
        if let theme = cardStore.calendarDay(for: selectedDate) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(theme.icono).font(.title2)
                    Text("El detalle de este día")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .firstTextBaseline) {
                    Text(theme.categoria)
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.34))
                    Spacer(minLength: 8)
                    Text("Día \(theme.dia) de 365")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(red: 0.12, green: 0.47, blue: 0.75))
                }
                ProgressView(value: Double(theme.dia), total: 365)
                    .tint(Color(red: 0.12, green: 0.47, blue: 0.75))
                Text(theme.fechaTexto)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
        }
    }

    private var calendarDateRange: ClosedRange<Date> {
        let start = cardStore.calendarDays.first?.date ?? Calendar.current.startOfDay(for: .now)
        let end = cardStore.calendarDays.last?.date ?? start
        return start...end
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Calendario")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.10, green: 0.23, blue: 0.36))
                Spacer()
                Button {
                    let today = Calendar.current.startOfDay(for: .now)
                    selectedDate = min(max(today, calendarDateRange.lowerBound), calendarDateRange.upperBound)
                } label: {
                    Label("Ir a hoy", systemImage: "calendar")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(Color(red: 0.12, green: 0.47, blue: 0.75))
            }
            DatePicker("Elegir día", selection: $selectedDate, in: calendarDateRange, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color(red: 0.13, green: 0.53, blue: 0.82))
                .padding(12)
                .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22))
            Text("Puedes explorar desde el 16 de octubre de 2026 hasta el 15 de octubre de 2027.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
