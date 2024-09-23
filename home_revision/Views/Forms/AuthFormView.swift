import SwiftUI

struct AuthFormView: View {
    var title: String
    var actionButtonTitle: String
    var action: (_ phoneNumber: String, _ password: String) -> Void

    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBeige
                    .edgesIgnoringSafeArea([.top, .bottom])

                VStack(spacing: 20) {
                    Spacer()

                    Text(title)
                        .font(.title)
                        .foregroundColor(.darkBrown)
                        .padding(.bottom, 40)

                    TextField("Номер телефона", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .foregroundColor(.darkBrown)
                        .onChange(of: phoneNumber) {
                            phoneNumber = phoneNumber.filter { "+0123456789".contains($0) }
                        }

                    SecureField("Пароль", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .foregroundColor(.darkBrown)
                        .onChange(of: password) {
                            password = password.filter { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&*".contains($0) }
                        } // Фильтрация для английских букв и цифр

                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        if phoneNumber.isEmpty || password.isEmpty {
                            errorMessage = "Пожалуйста, заполните все поля"
                            showError = true
                        } else {
                            action(phoneNumber, password)
                        }
                    }) {
                        Text(actionButtonTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryOrange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .animation(.easeInOut, value: showError)
            }
        }
    }
}
