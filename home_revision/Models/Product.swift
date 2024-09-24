import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: Int             // Уникальный идентификатор продукта
    let user_id: Int        // Идентификатор пользователя, связанного с продуктом
    var title: String       // Название продукта
    var description: String?// Описание продукта (может быть nil)
    var quantity: Int       // Текущее количество продукта
    var target_quantity: Int// Требуемое количество продукта
    var unit: String        // Единица измерения (например, шт, кг, л и т.д.)
    
    // Конформность к Equatable автоматически синтезируется компилятором Swift,
    // так как все свойства структуры соответствуют протоколу Equatable.
}
