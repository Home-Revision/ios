import Foundation
import Security

func deleteTokenFromKeychain() {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "authToken"
    ]
    SecItemDelete(query as CFDictionary)
}

func saveTokenToKeychain(token: String) {
    let tokenData = token.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "authToken",
        kSecValueData as String: tokenData
    ]
    SecItemAdd(query as CFDictionary, nil)
}

func getTokenFromKeychain() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "authToken",
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var dataTypeRef: AnyObject? = nil
    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    if status == noErr, let retrievedData = dataTypeRef as? Data {
        let token = String(data: retrievedData, encoding: .utf8)
        return token
    } else {
        return nil
    }
}
