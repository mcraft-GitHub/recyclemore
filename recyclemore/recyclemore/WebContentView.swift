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
    @State private var original: CGFloat = UIScreen.main.brightness
    
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
        .onChange(of: isShowingModal) { newValue in
            if newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let webView = webView,
                       let url = webView.url ?? URL(string: MultiViewURL) {
                        var request = URLRequest(url: url)
                            request.cachePolicy = .reloadIgnoringLocalCacheData
                        webView.load(URLRequest(url: url))
                    }
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
            print("ログアウト実行")
            // TODO:遷移図的には多分ログアウトAPIを実行する必要がある気がする
            // 参照用ユーザー情報を削除
            SharedUserData.userData = nil
            // 端末に保存しているログイン情報を削除
            KeychainHelper.shared.delete(key: "token")
            KeychainHelper.shared.delete(key: "email")
            
        case "sendBrightness":
            print("輝度送信")
            let bright = UIScreen.main.brightness
            
            // 関数名やら引数やらを指定
            let jsCode = "window.getBrightness('\(bright)')"
            webView?.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("JS 実行エラー: \(error)")
                } else {
                    print("setDeviceInfo 呼び出し成功")
                }
            }
            
        case "changeBrightness":
            print("輝度")
            let brightness = params?["brightness"] as? Float ?? 1.0
            
            if(brightness == -1.0){
                print("輝度復元")
                UIScreen.main.brightness = original
            }
            else
            {
                print("輝度変更")
                original = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(brightness)
            }
            
        case "openWebsite":
            print("ブラウザオープン")
            let res = params?["url"] as? String ?? ""
            if let url = URL(string: res) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            /*
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
             */
        case "network_error":
            print("通信エラーですよ")
            errorCode = ""
            errorMessage = ERROR_MES_NET
            modalType = .close
            isShowingModal = true
            
            // TODO:エラー出しても現状進行不能なのでその後どうするかは要確認
            
        case "goToLogin":
            print("ログイン画面へ")
            let mail = params?["mail"] as? String ?? ""
            let token = params?["token"] as? String ?? ""
            if(mail != "" && token != "")
            {
                print("初回ログイン")
                initial_email = mail
                initial_token = token
            }
            currentView = .login
            
        case "sendLoginInfo":
            print("JS")
            // ここでページ内のJSを呼び出す
            var token = KeychainHelper.shared.read(key: "token")
            var email = KeychainHelper.shared.read(key: "email")
            
            if(token == nil || email == nil)
            {
                token = ""
                email = ""
            }
            
            print(token!)
            print(email!)
            
            // 関数名やら引数やらを指定
            let jsCode = "window.getDeviceData('\(token!)', '\(email!)', '\(APP_VERSION)')"
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
