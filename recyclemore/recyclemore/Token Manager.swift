//
//  Token Manager.swift
//  recyclemore
//
//  Created by 貸し出し用 on 2025/10/15.
//

import Foundation
import UIKit

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var deviceTokenString: String = "未取得"
    @Published var deviceUUID: String = UIDevice.current.identifierForVendor?.uuidString ?? "不明"
    
    private init() {}
    
    func updateDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        DispatchQueue.main.async {
            self.deviceTokenString = tokenString
        }
    }
    
    /// 🔄 UUIDを更新（手動でも起動時でも呼べる）
    func refreshUUID() {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "不明"
        DispatchQueue.main.async {
            self.deviceUUID = uuid
        }
    }
}
