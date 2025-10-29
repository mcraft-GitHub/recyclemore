//
//  recyclemoreApp.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/07.
//

import SwiftUI

// アプリ本体、RootViewで画面を切り替えて表示内容を変える構造をしている
@main
struct recyclemoreApp: App {
    @StateObject private var appState = AppState()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    print("SceneレベルでURL受信: \(url)")
                    
                    // ベースとなるWebのドメイン
                    let baseDomain = "https://example.com/viewer" // 好きなURLに置き換え
                    
                    // URLのパス部分
                    let host = url.host ?? ""
                    let path = url.path // 例: /multi
                    
                    // host+pathを合わせた「パス扱い」にする
                    let fullPath: String
                    if !host.isEmpty && path.isEmpty {
                        fullPath = "\(host)"
                    } else {
                        fullPath = path
                    }
                    
                    // クエリパラメータを辞書に変換
                    var queryDict: [String: String] = [:]
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let items = components.queryItems {
                        for item in items {
                            queryDict[item.name] = item.value ?? ""
                        }
                    }
                    
                    // Web用のURLを組み立てる
                    var finalURL = "\(baseDomain)"
                    for (key, value) in queryDict {
                        if(key == "dir")
                        {
                            finalURL += "/\(value)"
                        }
                    }
                    
                    finalURL += "?"
                    
                    var count = 0
                    
                    for (key, value) in queryDict {
                        if(key != "dir")
                        {
                            if(count != 0)
                            {
                                finalURL += "&"
                            }
                            finalURL += "\(key)=\(value)"
                            count += 1
                        }
                    }
                    // あくまで機能確認用の動作
                    // TODO:finalURLをwebViewで開くなり、fullPathの値でアプリ側の画面を制御する
                    MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest.php?Z=\(finalURL)&path=\(fullPath)"
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    
    init(){
        // 起動時にkeychainを確認する
        let token = KeychainHelper.shared.read(key: "token")
        let email = KeychainHelper.shared.read(key: "email")
        
        if(token != nil && email != nil)
        {
            //どちらも記録されていれば自動ログインを実行する
            print(token!)
            print(email!)
            print("自動ログインを実行")
        }
        else
        {
            print("ログイン情報無し")
        }
    }
}
