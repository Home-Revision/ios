import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notificationManager = NotificationManager.shared // Используем NotificationManager

    var body: some View {
        AuthFormView(title: "Регистрация", actionButtonTitle: "Зарегистрироваться") { phoneNumber, password in
            authViewModel.register(phoneNumber: phoneNumber, password: password)
        }
        .notificationBanner(notificationManager: notificationManager) // Применение модификатора для баннера
    }
}

//#Preview {
//    RegistrationView()
//}
