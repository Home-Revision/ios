import SwiftUI

extension Color {
    // Основные цвета
    static let backgroundBeige = Color(hex: "#f2e1c9")
    static let primaryOrange = Color(hex: "#f4a261")
    static let accentYellow = Color(hex: "#f6c588")
    static let darkBrown = Color(hex: "#2d2d2d")
    
    // Цвета для баннеров
    static let successGreen = Color(hex: "#2a9d8f")  // Успешное уведомление
    static let errorRed = Color(hex: "#e63946")      // Ошибка
    static let infoBlue = Color(hex: "#85c1e9")      // Информационное уведомление
    
    // Инициализатор для создания цвета из HEX-кода
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        
        let r, g, b, a: Double
        if hex.count == 7 {
            r = Double((hexNumber & 0xFF0000) >> 16) / 255
            g = Double((hexNumber & 0x00FF00) >> 8) / 255
            b = Double(hexNumber & 0x0000FF) / 255
            a = 1.0
        } else {
            r = 1.0
            g = 1.0
            b = 1.0
            a = 1.0
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
