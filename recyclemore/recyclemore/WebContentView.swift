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
    
    @State private var errorMessage = ""
    @State private var errorCode = ""
    @State private var isShowingModal = false
    @State private var modalType:ModalType = .close
    
    var body: some View {
        ZStack {
            HybridWebView(url: URL(string: MultiViewURL)!,
                          onCustomEvent: { action, params in handleWebEvent(action: action, params: params)
            },
                          UIwebView: $webView
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if isShowingModal {
                switch modalType {
                case .close :
                    ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
                default:
                    EmptyView()
                }
            }
        }
        
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
        
        case "browser":
            print("ブラウザ")
            if let url = URL(string: "https://www.apple.com") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
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
        case "network_error":
            print("通信エラーですよ")
            errorCode = ""
            errorMessage = ERROR_MES_NET
            modalType = .close
            isShowingModal = true
            
            // TODO:エラー出しても現状進行不能なのでその後どうするかは要確認
            
        default:
            print("なんかされた")
        }
    }
}

#Preview {
    WebContentView(currentView: .constant(.web))
}
