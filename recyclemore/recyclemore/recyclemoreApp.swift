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
                .environmentObject(appState)
                .onOpenURL { url in
                    print("SceneレベルでURL受信: \(url)")
                    
                    // URLのパス部分(資料上はdir)
                    let host = url.host ?? ""

                    // クエリパラメータを辞書に変換
                    var queryDict: [String: String] = [:]
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let items = components.queryItems {
                        for item in items {
                            queryDict[item.name] = item.value ?? ""
                        }
                    }
                    
                    // Web用のURLを組み立てる
                    var finalURL = ""
                    
                    if(Server == "Dev")
                    {
                        finalURL = "\(BaseURL_Dev)"
                    }
                    else
                    {
                        finalURL = "\(BaseURL_Dis)"
                    }
                    
                    for (key, value) in queryDict {
                        if(key == "dir")
                        {
                            // エンコードされてるらしいのでデコードする
                            let decodedValue = value.removingPercentEncoding ?? value
                                    finalURL += "\(decodedValue)"
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
                    
                    print("これが遷移先")
                    print(finalURL)
                    
                    // ログイン画面orWebViewの特定画面に遷移
                    if(host == "multi")
                    {
                        print("WebViewに遷移！")
                        MultiViewURL = finalURL
                        // WebView TO WebView だとURLの変化を検知してくれないのでブランクを中継して確実に再描画されるようにする
                        appState.currentView = .blank
                        DispatchQueue.main.async {
                            appState.currentView = .web
                        }
                    }
                    else
                    {
                        print("ログイン画面に遷移！")
                        appState.currentView = .login
                    }
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentView: AppViewMode = .splash
    
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
