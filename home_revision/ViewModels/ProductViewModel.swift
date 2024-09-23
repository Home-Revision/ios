import Foundation

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String? = nil

    func fetchProducts() {
        // Попытка получить токен
        guard let accessToken = getAccessToken() else {
            DispatchQueue.main.async {
                self.errorMessage = "Токен не найден"
            }
            return
        }

        // Проверка URL
        guard let url = URL(string: "http://localhost:8080/api/products/list/") else {
            DispatchQueue.main.async {
                self.errorMessage = "Неверный URL"
            }
            return
        }

        // Создание запроса
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Добавляем токен в заголовок

        // Выполнение запроса
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Некорректный ответ сервера"
                }
                return
            }

            // Парсинг ответа
            do {
                let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = decodedProducts
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Ошибка парсинга данных: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // Метод для получения access token из хранилища (например, Keychain)
    private func getAccessToken() -> String? {
        // Получение токена из Keychain или другого хранилища
        return KeychainHelper.standard.read(service: "access-token", account: "your-app")
    }
}
