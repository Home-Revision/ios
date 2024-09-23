import Foundation

struct Product: Identifiable, Decodable {
    var id: Int
    var user_id: Int
    var title: String
    var description: String
    var quantity: Int
    var target_quantity: Int
    var unit: String
}
