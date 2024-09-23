import SwiftUI

struct EditProductView: View {
    let product: Product
    @State private var title: String
    @State private var description: String
    @State private var quantity: String
    @State private var targetQuantity: String
    @State private var unit: String
    @State private var isChanged: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isSubmitting: Bool = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    let onProductUpdated: (Product) -> Void

    let units = ["шт", "кг", "гр", "л", "мл"]

    init(product: Product, onProductUpdated: @escaping (Product) -> Void) {
        self.product = product
        _title = State(initialValue: product.title)
        _description = State(initialValue: product.description ?? "")
        _quantity = State(initialValue: String(product.quantity))
        _targetQuantity = State(initialValue: String(product.target_quantity))
        _unit = State(initialValue: product.unit)
        self.onProductUpdated = onProductUpdated
    }

    var body: some View {
        ZStack {
            Color.backgroundBeige
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Редактировать продукт")
                    .font(.largeTitle)
                    .foregroundColor(.darkBrown)
                    .padding(.top, 20)

                Divider()
                    .frame(height: 1)
                    .background(Color.gray)
                    .opacity(0.3)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Основные данные")
                            .font(.headline)
                            .foregroundColor(.darkBrown)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        TextField("Название", text: $title, onEditingChanged: { _ in isChanged = true })
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Описание", text: $description, onEditingChanged: { _ in isChanged = true })
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Количество", text: $quantity, onEditingChanged: { _ in isChanged = true })
                            .keyboardType(.numberPad)
                            .onChange(of: quantity) { newValue in
                                quantity = newValue.filter { "0123456789".contains($0) }
                                isChanged = true
                            }
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Требуемое количество", text: $targetQuantity, onEditingChanged: { _ in isChanged = true })
                            .keyboardType(.numberPad)
                            .onChange(of: targetQuantity) { newValue in
                                targetQuantity = newValue.filter { "0123456789".contains($0) }
                                isChanged = true
                            }
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        Picker("Единица измерения", selection: $unit) {
                            ForEach(units, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: unit) { _ in
                            isChanged = true
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.darkBrown)
                        .padding(.horizontal)
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                HStack {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Удалить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.errorRed)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(
                            title: Text("Вы уверены?"),
                            message: Text("Удаление этого продукта нельзя отменить."),
                            primaryButton: .destructive(Text("Да")) {
                                deleteProduct()
                            },
                            secondaryButton: .cancel(Text("Нет"))
                        )
                    }

                    Button(action: {
                        updateProduct()
                    }) {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isChanged ? Color.accentYellow : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isChanged)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)

                Spacer()
            }
        }
    }

    func updateProduct() {
        guard let quantityValue = Int(quantity), quantityValue >= 0 else {
            errorMessage = "Количество должно быть положительным числом."
            return
        }

        guard let targetQuantityValue = Int(targetQuantity), targetQuantityValue >= 0 else {
            errorMessage = "Требуемое количество должно быть положительным числом."
            return
        }

        var parameters: [String: Any] = [:]
        if title != product.title {
            parameters["title"] = title
        }
        if description != product.description {
            parameters["description"] = description
        }
        if quantityValue != product.quantity {
            parameters["quantity"] = quantityValue
        }
        if targetQuantityValue != product.target_quantity {
            parameters["target_quantity"] = targetQuantityValue
        }
        if unit != product.unit {
            parameters["unit"] = unit
        }

        guard !parameters.isEmpty else {
            errorMessage = "Нет изменений для сохранения"
            return
        }

        isSubmitting = true
        errorMessage = nil

        guard let url = URL(string: "http://localhost:8080/api/products/update/\(product.id)/") else {
            errorMessage = "Неверный URL"
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                    var updatedProduct = product
                    updatedProduct.title = title
                    updatedProduct.description = description
                    updatedProduct.quantity = quantityValue
                    updatedProduct.target_quantity = targetQuantityValue
                    updatedProduct.unit = unit

                    onProductUpdated(updatedProduct)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Не удалось обновить продукт. Статус: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

    func deleteProduct() {
        guard let url = URL(string: "http://localhost:8080/api/products/destroy/\(product.id)/") else {
            errorMessage = "Неверный URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                    onProductUpdated(product)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Не удалось удалить продукт. Статус: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

    func getAccessToken() -> String? {
        return KeychainHelper.standard.read(service: "access-token", account: "your-app")
    }
}
