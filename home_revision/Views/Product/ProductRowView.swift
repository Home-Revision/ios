import SwiftUI
import UIKit

struct ProductRowView: View {
    @Binding var product: Product
    let onUpdate: (Result<Product?, Error>) -> Void

    @State private var isExpanded: Bool = false
    @State private var quantity: Int
    @State private var targetQuantity: Int
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isShowingEditView: Bool = false // Для открытия экрана полного редактирования

    // Переменные для хранения исходных значений
    @State private var originalQuantity: Int
    @State private var originalTargetQuantity: Int

    init(product: Binding<Product>, onUpdate: @escaping (Result<Product?, Error>) -> Void) {
        self._product = product
        self.onUpdate = onUpdate
        _quantity = State(initialValue: product.wrappedValue.quantity)
        _targetQuantity = State(initialValue: product.wrappedValue.target_quantity)
        _originalQuantity = State(initialValue: product.wrappedValue.quantity)
        _originalTargetQuantity = State(initialValue: product.wrappedValue.target_quantity)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Основная строка продукта
            HStack {
                Text("\(product.title)")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(quantity)/\(targetQuantity) \(product.unit)")
                    .foregroundColor(quantity < targetQuantity ? Color.errorRed : Color.white)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.primaryOrange, location: CGFloat(min(quantity, targetQuantity)) / CGFloat(max(targetQuantity, 1))),
                        .init(color: Color.primaryOrange.opacity(0.3), location: CGFloat(min(quantity, targetQuantity)) / CGFloat(max(targetQuantity, 1)))
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(isExpanded ? 0 : 10)
            .gesture(
                TapGesture()
                    .onEnded {
                        // Открываем полный экран редактирования
                        isShowingEditView = true
                    }
            )
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        withAnimation {
                            if !isExpanded {
                                // Сохраняем исходные значения при открытии формы
                                originalQuantity = quantity
                                originalTargetQuantity = targetQuantity
                            } else {
                                // Если форма закрывается без сохранения
                                if !isSubmitting {
                                    quantity = originalQuantity
                                    targetQuantity = originalTargetQuantity
                                }
                            }
                            isExpanded.toggle()
                            // Триггерим тактильную обратную связь
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }
            )
            .sheet(isPresented: $isShowingEditView) {
                // Передаем обновленный продукт обратно через onUpdate
                EditProductView(product: $product.wrappedValue) { result in
                    switch result {
                    case .success(let updatedProduct):
                        if let updatedProduct = updatedProduct {
                            onUpdate(.success(updatedProduct))
                            // Обновляем локальные и исходные значения после редактирования
                            quantity = updatedProduct.quantity
                            targetQuantity = updatedProduct.target_quantity
                            originalQuantity = updatedProduct.quantity
                            originalTargetQuantity = updatedProduct.target_quantity
                        } else {
                            // Продукт был удален
                            onUpdate(.success(nil))
                        }
                    case .failure(let error):
                        onUpdate(.failure(error))
                    }
                }
            }

            // Расширенная форма для изменения количества
            if isExpanded {
                VStack(spacing: 10) {
                    HStack {
                        Text("Количество:")
                            .foregroundColor(.darkBrown)
                        Spacer()
                        Button(action: {
                            if quantity > 0 {
                                quantity -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.darkBrown)
                        }
                        Text("\(quantity)")
                            .frame(width: 40)
                            .foregroundColor(.darkBrown)
                        Button(action: {
                            quantity += 1
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.darkBrown)
                        }
                    }

                    HStack {
                        Text("Требуемое количество:")
                            .foregroundColor(.darkBrown)
                        Spacer()
                        Button(action: {
                            if targetQuantity > 0 {
                                targetQuantity -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.darkBrown)
                        }
                        Text("\(targetQuantity)")
                            .frame(width: 40)
                            .foregroundColor(.darkBrown)
                        Button(action: {
                            targetQuantity += 1
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.darkBrown)
                        }
                    }

                    Button(action: {
                        updateProduct()
                    }) {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentYellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isSubmitting)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(Color.backgroundBeige)
                .cornerRadius(10)
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onChange(of: product) { newProduct in
            // Обновляем локальные значения при изменении продукта
            quantity = newProduct.quantity
            targetQuantity = newProduct.target_quantity
            originalQuantity = newProduct.quantity
            originalTargetQuantity = newProduct.target_quantity
        }
    }

    // Метод для обновления продукта
    func updateProduct() {
        isSubmitting = true
        errorMessage = nil

        let parameters: [String: Any] = [
            "quantity": quantity,
            "target_quantity": targetQuantity
        ]

        guard let url = URL(string: "http://localhost:8080/api/products/update/\(product.id)/") else {
            errorMessage = "Неверный URL"
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Добавляем токен авторизации
        if let accessToken = getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Токен авторизации не найден"
            isSubmitting = false
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            errorMessage = "Ошибка при формировании данных"
            isSubmitting = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Некорректный ответ сервера"
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Успешное обновление
                    let updatedProduct = Product(
                        id: product.id,
                        user_id: product.user_id,
                        title: product.title,
                        description: product.description,
                        quantity: quantity,
                        target_quantity: targetQuantity,
                        unit: product.unit
                    )
                    onUpdate(.success(updatedProduct))

                    withAnimation {
                        isExpanded = false
                        // Триггерим тактильную обратную связь при закрытии
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                } else {
                    errorMessage = "Не удалось обновить продукт. Статус: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

    // Метод для удаления продукта
    func deleteProduct() {
        guard let url = URL(string: "http://localhost:8080/api/products/destroy/\(product.id)/") else {
            errorMessage = "Неверный URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Добавляем токен авторизации
        if let accessToken = getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Токен авторизации не найден"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Некорректный ответ сервера"
                    return
                }

                if httpResponse.statusCode == 204 {
                    // Продукт успешно удален
                    onUpdate(.success(nil))

                    withAnimation {
                        isExpanded = false
                        // Триггерим тактильную обратную связь при закрытии
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                } else {
                    errorMessage = "Не удалось удалить продукт. Статус: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

    // Метод для получения токена
    func getAccessToken() -> String? {
        return KeychainHelper.standard.read(service: "access-token", account: "your-app")
    }
}
