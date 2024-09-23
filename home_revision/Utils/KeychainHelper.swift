import Foundation
import Security

class KeychainHelper {
    static let standard = KeychainHelper() // Singleton
    private init() {}

    // Метод для сохранения данных в Keychain
    func save(_ data: String, service: String, account: String) {
        guard let data = data.data(using: .utf8) else { return }

        // Запрос для сохранения
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Удаляем старые данные, если они есть
        SecItemDelete(query as CFDictionary)
        // Добавляем новые данные
        SecItemAdd(query as CFDictionary, nil)
    }

    // Метод для чтения данных из Keychain
    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data, let result = String(data: data, encoding: .utf8) {
            return result
        }
        return nil
    }

    // Метод для удаления данных из Keychain
    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
