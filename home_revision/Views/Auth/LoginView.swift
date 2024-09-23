import SwiftUI
import Foundation

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notificationManager = NotificationManager.shared // Используем NotificationManager

    var body: some View {
        AuthFormView(title: "Вход", actionButtonTitle: "Войти") { phoneNumber, password in
            authViewModel.login(phoneNumber: phoneNumber, password: password)
        }
        .notificationBanner(notificationManager: notificationManager) // Применение модификатора для баннера
    }
}

//#Preview {
//    LoginView()
//}
