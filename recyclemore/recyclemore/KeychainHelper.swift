//
//  KeychainHelper.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/08.
//

import Foundation
import Security

// 端末へのデータ保存と読み取り、削除の補助クラス
class KeychainHelper {
    static let shared = KeychainHelper()
    private init(){}
    
    // データの保存
    func save(_ value: String, key: String){
        let data = Data(value.utf8)
        
        //既に同じキーがあれば削除してから作成する＝実質上書き
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary
        SecItemDelete(query)
        
        // 新規登録
        let attribute = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key, kSecValueData: data] as CFDictionary
        SecItemAdd(attribute, nil)
    }
    
    // データの読み取り
    func read(key: String) -> String?{
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key, kSecReturnData: true, kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    // データの削除
    func delete(key: String) {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary
        SecItemDelete(query)
    }
}
