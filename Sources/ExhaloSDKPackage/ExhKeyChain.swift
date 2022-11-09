import Foundation
import Security

enum ExhKeyChainKeys: String {
    case userUUID
}

class ExhKeyChain {
    class func save(key: ExhKeyChainKeys, string: String) -> OSStatus {
        guard let data = string.data(using: .utf8) else { return .zero }

        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key.rawValue,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: ExhKeyChainKeys) -> String? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            guard
                let data = dataTypeRef as? Data,
                let string = String(data: data, encoding: .utf8)
            else {
                return nil
            }

            return string
        } else {
            return nil
        }
    }

    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func delete(key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key ] as [String : Any]

        SecItemDelete(query as CFDictionary)
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}



enum GetterSetterKeys: String {
    case hasHealthKitPermission
    case sdkEnv
    
    var key: String { return "getter_setter_key_"  + self.rawValue }
}


class Getter {
    static func bool(_ forkey: GetterSetterKeys) -> Bool {
        return UserDefaults.standard.bool(forKey: forkey.key)
    }
    static func string(_ forKey: GetterSetterKeys) -> String? {
        return UserDefaults.standard.string(forKey: forKey.key)
    }
}

class Setter {
    static func value(_ value: Any?, forKey: GetterSetterKeys) {
        UserDefaults.standard.setValue(value, forKey: forKey.key)
        UserDefaults.standard.synchronize()
    }

    static func delete(for key: GetterSetterKeys) {
        UserDefaults.standard.removeObject(forKey: key.key)
        UserDefaults.standard.synchronize()
    }
}
