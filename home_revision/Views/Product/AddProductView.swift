import SwiftUI

struct AddProductView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var quantity: String = ""
    @State private var targetQuantity: String = ""
    @State private var unit: String = "шт"
    
    @State private var errorMessage: String? = nil
    @State private var isSubmitting: Bool = false
    @Environment(\.presentationMode) var presentationMode

    let onProductAdded: () -> Void // Замыкание, которое будет вызвано при успешном добавлении продукта

    let units = ["шт", "кг", "гр", "л", "мл"]

    func getAccessToken() -> String? {
        return KeychainHelper.standard.read(service: "access-token", account: "your-app")
    }

    var body: some View {
        ZStack {
            Color.backgroundBeige
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Добавить продукт")
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

                        TextField("Название*", text: $title)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Описание", text: $description)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Количество*", text: $quantity)
                            .keyboardType(.numberPad)
                            .onChange(of: quantity) { newValue in
                                quantity = newValue.filter { "0123456789".contains($0) }
                            }
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.darkBrown)
                            .padding(.horizontal)

                        TextField("Требуемое количество*", text: $targetQuantity)
                            .keyboardType(.numberPad)
                            .onChange(of: targetQuantity) { newValue in
                                targetQuantity = newValue.filter { "0123456789".contains($0) }
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

                Button(action: {
                    addProduct()
                }) {
                    Text("Добавить продукт")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSubmitting ? Color.gray : Color.accentYellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isSubmitting)
                .padding()

                Spacer()
            }
        }
    }

    func addProduct() {
        guard !title.isEmpty else {
            errorMessage = "Пожалуйста, укажите название продукта."
            return
        }

        guard let quantityValue = Int(quantity), quantityValue >= 0 else {
            errorMessage = "Количество должно быть положительным числом."
            return
        }

        guard let targetQuantityValue = Int(targetQuantity), targetQuantityValue >= 0 else {
            errorMessage = "Требуемое количество должно быть положительным числом."
            return
        }

        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "quantity": quantityValue,
            "target_quantity": targetQuantityValue,
            "unit": unit
        ]
        
        isSubmitting = true
        errorMessage = nil

        guard let url = URL(string: "http://localhost:8080/api/products/create/") else {
            errorMessage = "Неверный URL"
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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

                if httpResponse.statusCode == 201 {
                    // Успешное добавление, закрываем экран и обновляем главный экран
                    onProductAdded()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Не удалось добавить продукт. Статус: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
}
