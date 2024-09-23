import SwiftUI
import Foundation

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundBeige
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Добро пожаловать")
                        .font(.largeTitle)
                        .foregroundColor(.darkBrown)
                        .padding(.bottom, 40)
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryOrange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: RegistrationView()) {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentYellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}


#Preview {
    WelcomeView()
}
