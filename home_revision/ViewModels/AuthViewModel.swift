import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    init() {
        checkAuth()
    }

    func checkAuth() {
        if let _ = getAccessTokenFromKeychain() {
            // Здесь можно добавить дополнительную проверку токена, например, на срок действия
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }

    func login(phoneNumber: String, password: String) {
        guard let url = URL(string: "http://localhost:8080/api/users/token/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = ["phone_number": phoneNumber, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Произошла ошибка",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Некорректный ответ сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Некорректный ответ сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                if httpResponse.statusCode == 401 {
                    // Обработка 401 ошибки
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let detail = json["detail"] as? String {
                        NotificationManager.shared.showNotification(
                            message: detail,
                            type: .error,
                            shouldVibrate: false
                        )
                    } else {
                        self.errorMessage = "Неизвестная ошибка авторизации"
                        NotificationManager.shared.showNotification(
                            message: "Неизвестная ошибка авторизации",
                            type: .error,
                            shouldVibrate: true
                        )
                    }
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Нет данных от сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Нет данных от сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access"] as? String,
                   let refreshToken = json["refresh"] as? String {
                    self.saveTokensToKeychain(accessToken: accessToken, refreshToken: refreshToken)
                    self.isAuthenticated = true
                    NotificationManager.shared.showNotification(
                        message: "Успешный вход",
                        type: .success,
                        shouldVibrate: true
                    )
                } else {
                    self.errorMessage = "Некорректный ответ сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Некорректный ответ сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                }
            }
        }.resume()
    }

    func register(phoneNumber: String, password: String) {
        guard let url = URL(string: "http://localhost:8080/api/users/register/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = ["phone_number": phoneNumber, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Произошла ошибка",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Некорректный ответ сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Некорректный ответ сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                if httpResponse.statusCode == 400 {
                    // Обработка 400 ошибки
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessages = json["error"] as? [String],
                       let errorMessage = errorMessages.first {
                        self.errorMessage = errorMessage
                        NotificationManager.shared.showNotification(
                            message: errorMessage,
                            type: .error,
                            shouldVibrate: true
                        )
                    } else {
                        self.errorMessage = "Ошибка регистрации"
                        NotificationManager.shared.showNotification(
                            message: "Ошибка регистрации",
                            type: .error,
                            shouldVibrate: true
                        )
                    }
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Нет данных от сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Нет данных от сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access"] as? String,
                   let refreshToken = json["refresh"] as? String {
                    self.saveTokensToKeychain(accessToken: accessToken, refreshToken: refreshToken)
                    self.isAuthenticated = true
                } else {
                    self.errorMessage = "Некорректный ответ сервера"
                    NotificationManager.shared.showNotification(
                        message: self.errorMessage ?? "Некорректный ответ сервера",
                        type: .error,
                        shouldVibrate: true
                    )
                }
            }
        }.resume()
    }

    func logout() {
        deleteTokensFromKeychain()
        isAuthenticated = false
    }

    // Методы работы с Keychain
    func saveTokensToKeychain(accessToken: String, refreshToken: String) {
        KeychainHelper.standard.save(accessToken, service: "access-token", account: "your-app")
        KeychainHelper.standard.save(refreshToken, service: "refresh-token", account: "your-app")
    }

    func getAccessTokenFromKeychain() -> String? {
        return KeychainHelper.standard.read(service: "access-token", account: "your-app")
    }

    func getRefreshTokenFromKeychain() -> String? {
        return KeychainHelper.standard.read(service: "refresh-token", account: "your-app")
    }

    func deleteTokensFromKeychain() {
        KeychainHelper.standard.delete(service: "access-token", account: "your-app")
        KeychainHelper.standard.delete(service: "refresh-token", account: "your-app")
    }
}
