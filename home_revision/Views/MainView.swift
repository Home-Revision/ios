import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var productViewModel = ProductViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundBeige
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Заголовок и шестеренка в HStack
                    HStack {
                        Button(action: {
                            // Пока что пустое действие
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.darkBrown)
                        }

                        Spacer()

                        Text("Home Revision")
                            .font(.largeTitle)
                            .foregroundColor(.darkBrown)

                        Spacer()
                        
                        // Добавим отступ справа для симметрии
                        Spacer(minLength: 50)
                    }
                    .padding()

                    Divider()
                        .frame(height: 1) // Толщина линии
                        .background(Color.gray) // Цвет линии
                        .opacity(0.3)

                    // Кнопка "Добавить продукт"
                    Button(action: {
                        // Пока нет функционала
                    }) {
                        Text("Добавить продукт")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentYellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10) // Отступ под кнопкой

                    if let errorMessage = productViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(productViewModel.products) { product in
                                    Button(action: {
                                        // Пока что ничего не делаем, но позже можно добавить переход на страницу редактирования
                                    }) {
                                        HStack {
                                            Text("\(product.title)")
                                                .font(.headline)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Text("\(product.quantity)/\(product.target_quantity) \(product.unit)")
                                                .foregroundColor(product.quantity < product.target_quantity ? Color.errorRed : Color.white)
                                        }
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color.primaryOrange, location: CGFloat(product.quantity) / CGFloat(product.target_quantity)),
                                                    .init(color: Color.primaryOrange.opacity(0.3), location: CGFloat(product.quantity) / CGFloat(product.target_quantity))
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Убираем стандартный стиль кнопки
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .background(Color.backgroundBeige)
                    }

                    Spacer()

                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Выйти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentYellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .onAppear {
                productViewModel.fetchProducts()
            }
        }
    }
}
