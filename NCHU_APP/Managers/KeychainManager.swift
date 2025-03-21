import Foundation
import Security

class KeychainManager {
    static let standard = KeychainManager()
    private init() {}
    
    enum KeychainError: LocalizedError {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .duplicateEntry:
                return "項目已存在"
            case .unknown(let status):
                return "未知錯誤：\(status)"
            case .itemNotFound:
                return "找不到項目"
            case .invalidData:
                return "無效的資料"
            }
        }
    }
    
    private enum KeychainKey {
        static let username = "tw.edu.nchu.app.ilearning.username"
        static let password = "tw.edu.nchu.app.ilearning.password"
        
        static let service = "tw.edu.nchu.app.ilearning"
    }
    
    // 基本的 Keychain 查詢屬性
    private var baseQuery: [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKey.service,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
    }
    
    func saveCredentials(username: String, password: String) throws {
        // 先刪除現有的憑證
        try? deleteCredentials()
        
        // 儲存用戶名
        try saveItem(username, for: .username)
        
        // 儲存密碼
        try saveItem(password, for: .password)
    }
    
    private func saveItem(_ value: String, for type: CredentialType) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        var query = baseQuery
        query[kSecAttrAccount as String] = type.rawValue
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    private func updateCredential(_ value: String, for type: CredentialType) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        var query = baseQuery
        query[kSecAttrAccount as String] = type.rawValue
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    func getCredentials() throws -> (username: String, password: String) {
        // 讀取用戶名
        let username = try getCredential(for: .username)
        
        // 讀取密碼
        let password = try getCredential(for: .password)
        
        return (username, password)
    }
    
    private func getCredential(for type: CredentialType) throws -> String {
        var query = baseQuery
        query[kSecAttrAccount as String] = type.rawValue
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return string
    }
    
    func deleteCredentials() throws {
        let query = baseQuery
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    private enum CredentialType: String {
        case username = "username"
        case password = "password"
    }
} 
