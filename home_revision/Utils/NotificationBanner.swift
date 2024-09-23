import SwiftUI
import UIKit

enum NotificationType {
    case success
    case error
    case info
}

struct NotificationBanner: View {
    var message: String
    var type: NotificationType
    var shouldVibrate: Bool
    var onDismiss: (() -> Void)?
    
    @State private var isVisible = false
    
    var bannerColor: Color {
        switch type {
        case .error:
            return .red
        case .success:
            return .green
        case .info:
            return .blue
        }
    }
    
    var iconName: String {
        switch type {
        case .error:
            return "exclamationmark.triangle"
        case .success:
            return "checkmark.circle"
        case .info:
            return "info.circle"
        }
    }
    
    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                    
                    Text(message)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isVisible = false
                        }
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(bannerColor)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    if shouldVibrate {
                        vibrate()
                    }
                    // Автоматически скрыть через 3 секунды
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isVisible = false
                        }
                        onDismiss?()
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
    
    func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        switch type {
        case .error:
            generator.notificationOccurred(.error)
        case .success:
            generator.notificationOccurred(.success)
        case .info:
            generator.notificationOccurred(.warning)
        }
    }
}

class NotificationManager: ObservableObject {
    @Published var message: String = ""
    @Published var type: NotificationType = .info
    @Published var shouldVibrate: Bool = false
    @Published var showBanner: Bool = false
    
    static let shared = NotificationManager() // Singleton для удобного доступа

    private init() {}

    // Метод для отображения уведомления
    func showNotification(message: String, type: NotificationType = .info, shouldVibrate: Bool = false) {
        self.message = message
        self.type = type
        self.shouldVibrate = shouldVibrate
        self.showBanner = true
        
        // Автоматически скрываем уведомление через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showBanner = false
            }
        }
    }
}

struct NotificationBannerModifier: ViewModifier {
    @ObservedObject var notificationManager: NotificationManager
    
    func body(content: Content) -> some View {
        ZStack {
            content

            if notificationManager.showBanner {
                VStack {
                    NotificationBanner(
                        message: notificationManager.message,
                        type: notificationManager.type,
                        shouldVibrate: notificationManager.shouldVibrate
                    )
                    .padding(.top, 50) // Отступ для безопасной зоны
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: notificationManager.showBanner)
            }
        }
    }
}

extension View {
    func notificationBanner(notificationManager: NotificationManager) -> some View {
        self.modifier(NotificationBannerModifier(notificationManager: notificationManager))
    }
}
