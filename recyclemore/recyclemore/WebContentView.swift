//
//  WebContentView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/08.
//

import SwiftUI
import WebKit

// 実質的な本体機能はここ(WebViewの中)、URLを指定しwebページを表示する
struct WebContentView: View {
    
    @Binding var currentView: AppViewMode
    @State private var webView: WKWebView? = nil  // ← WebViewを保持
    
    var body: some View {
        HybridWebView(url: URL(string: MultiViewURL)!,
                      onCustomEvent: { action, params in handleWebEvent(action: action, params: params)
        },
                      UIwebView: $webView
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest.php
        
        
        /*
         WebView(url: URL(string: "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest.php")!) {
         action in
         print("アクション")
         print(action)
         }
         */
        /*
         WebView(url: URL(string: "https://www.apple.com")!) {
         action in
         print("アクション")
         print(action)
         }
         */
        
        //ContentWebView()
    }
    // 各イベント処理
    func handleWebEvent(action: String, params: [String: Any]?) {
        switch action {
        case "login":
            print("ログイン")
            currentView = .login
            
        case "logout":
            print("ログアウト")
            // 参照用ユーザー情報を削除
            SharedUserData.userData = nil
            // 端末に保存しているログイン情報を削除
            KeychainHelper.shared.delete(key: "token")
            KeychainHelper.shared.delete(key: "email")
            
        case "regist":
            print("新規登録")
            // TODO:パラメーターを使って初回ログインAPIを実行する
            
        case "member":
            print("輝度")
            
        case "first":
            print("JS")
            // ここでページ内のJSを呼び出す
            let token = "abc123"
            let email = "test@example.com"
            
            // 関数名やら引数やらを指定
            let jsCode = "window.setDeviceInfo('\(token)', '\(email)', '\(APP_VERSION)')"
                webView?.evaluateJavaScript(jsCode) { result, error in
                    if let error = error {
                        print("JS 実行エラー: \(error)")
                    } else {
                        print("setDeviceInfo 呼び出し成功")
                    }
                }
        default:
            print("なんかされた")
        }
    }
}

#Preview {
    WebContentView(currentView: .constant(.web))
}
