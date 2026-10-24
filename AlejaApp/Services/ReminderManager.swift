import Foundation
import Combine
import UserNotifications

@MainActor
final class ReminderManager: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var statusMessage: String?

    private let center = UNUserNotificationCenter.current()

    init() {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = Set(requests.map(\.identifier))
            let enabled = ["aleja.morning", "aleja.midday", "aleja.evening"].allSatisfy(ids.contains)
            Task { @MainActor [weak self] in
                self?.isEnabled = enabled
            }
        }
    }

    func refreshStatus() {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = Set(requests.map(\.identifier))
            let enabled = ["aleja.morning", "aleja.midday", "aleja.evening"].allSatisfy(ids.contains)
            Task { @MainActor [weak self] in
                self?.isEnabled = enabled
            }
        }
    }

    func enableDailyReminders() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                isEnabled = false
                statusMessage = "Las notificaciones están desactivadas. Puedes habilitarlas en Ajustes del iPhone."
                return
            }

            let schedule: [(id: String, hour: Int, title: String, body: String)] = [
                ("aleja.morning", 6, "Buenos días, Aleja 💙", "Tu cartica de la mañana te está esperando."),
                ("aleja.midday", 12, "Una pausa para ti ✨", "Tómate un momento para leer tu cartica del mediodía."),
                ("aleja.evening", 18, "Cierra el día con cariño 🌙", "Tu cartica de la noche está lista cuando quieras leerla.")
            ]

            for item in schedule {
                let content = UNMutableNotificationContent()
                content.title = item.title
                content.body = item.body
                content.sound = .default

                var components = DateComponents()
                components.hour = item.hour
                components.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
                try await center.add(request)
            }

            isEnabled = true
            statusMessage = "Recordatorios diarios activados para las 06:00, 12:00 y 18:00."
        } catch {
            center.removePendingNotificationRequests(withIdentifiers: [
                "aleja.morning", "aleja.midday", "aleja.evening"
            ])
            isEnabled = false
            statusMessage = "No fue posible configurar todos los recordatorios. Se limpiaron las solicitudes parciales; inténtalo de nuevo."
        }
    }

    func disableDailyReminders() {
        center.removePendingNotificationRequests(withIdentifiers: [
            "aleja.morning", "aleja.midday", "aleja.evening"
        ])
        isEnabled = false
        statusMessage = "Recordatorios desactivados."
    }
}
