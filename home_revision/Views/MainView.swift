import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var productViewModel = ProductViewModel()
    @State private var isShowingAddProductView = false
    @State private var isShowingSettingsView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundBeige
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Заголовок и шестеренка в HStack
                    HStack {
                        Button(action: {
                            isShowingSettingsView = true // Открываем экран настроек
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.darkBrown)
                        }
                        .sheet(isPresented: $isShowingSettingsView) {
                            SettingsView() // Переход на экран настроек
                        }

                        Spacer()

                        Text("Home Revision")
                            .font(.largeTitle)
                            .foregroundColor(.darkBrown)

                        Spacer()

                        // Пустое место для выравнивания
                        Spacer()
                            .frame(width: 24) // Ширина иконки настроек для симметрии
                    }
                    .padding()

                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .opacity(0.3)

                    // Кнопка "Добавить продукт"
                    Button(action: {
                        isShowingAddProductView = true
                    }) {
                        Text("Добавить продукт")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentYellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .sheet(isPresented: $isShowingAddProductView) {
                        AddProductView(onProductAdded: {
                            productViewModel.fetchProducts()
                        })
                    }

                    if let errorMessage = productViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(productViewModel.products) { product in
                                    ProductRowView(
                                        product: product,
                                        onUpdate: { updatedProduct in
                                            // Обновляем продукт в массиве
                                            if let index = productViewModel.products.firstIndex(where: { $0.id == updatedProduct.id }) {
                                                productViewModel.products[index] = updatedProduct
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.top, 10)
                        }
                        .background(Color.backgroundBeige)
                    }

                    Spacer()
                }
            }
            .onAppear {
                productViewModel.fetchProducts()
            }
            .navigationBarHidden(true)
        }
    }
}
