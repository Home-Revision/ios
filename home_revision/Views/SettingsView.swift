import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Устанавливаем фон такой же, как на главной странице
            Color.backgroundBeige
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Контент в настройках (пока пусто)
                Text("Настройки")
                    .font(.largeTitle)
                    .foregroundColor(.darkBrown)
                    .padding(.top, 50)

                Spacer() // Разделитель для выравнивания кнопки "Выйти" внизу

                // Кнопка "Выйти"
                Button(action: {
                    authViewModel.logout()
                    presentationMode.wrappedValue.dismiss() // Закрываем экран настроек
                }) {
                    Text("Выйти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentYellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // Отступ снизу
            }
        }
        .navigationBarTitle("Настройки", displayMode: .inline) // Заголовок в верхней части экрана
    }
}
