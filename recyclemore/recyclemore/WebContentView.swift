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
    @State private var temp: CGFloat = UIScreen.main.brightness
    @Environment(\.scenePhase) private var scenePhase
    
    // 輝度変更APIが走ったことを示すフラグ
    @State private var IsChangedBrightness = false
    
    var body: some View {
        ZStack {
            if shouldIgnoreKeyboardSafeArea {
                HybridWebView(url: URL(string: MultiViewURL)!,
                              onCustomEvent: { action, params in handleWebEvent(action: action, params: params)
                },
                              UIwebView: $webView
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard)
            }
            else
            {
                HybridWebView(url: URL(string: MultiViewURL)!,
                              onCustomEvent: { action, params in handleWebEvent(action: action, params: params)
                },
                              UIwebView: $webView
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                // バックグラウンド or ロック時(ロックを正確に判断することはできない)
                temp = UIScreen.main.brightness
                UIScreen.main.brightness = original
                IsChangedBrightness = false
                print("離れた")
            }
            else if phase == .active {
                // フォアグラウンド or ロック解除
                if(!IsChangedBrightness)
                {
                    // フォアグラウンドに戻るとフラグが立つので事実上ロック解除時の処理
                    UIScreen.main.brightness = temp
                }
                IsChangedBrightness = false
                print("帰ってきた")
            }
        }
    }
    // 各イベント処理
    func handleWebEvent(action: String, params: [String: Any]?) {
        switch action {
        case "login":
            print("ログイン")
            currentView = .login
            
        case "logout":
            print("ログアウト実行")
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
                    print("sendBrightness 呼び出し成功")
                }
            }
            
        case "changeBrightness":
            print("輝度")
            let brightness = params?["brightness"] as? Float ?? 1.0
            
            IsChangedBrightness = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                IsChangedBrightness = false
            }
            
            print("変更先")
            print(brightness)

            if(brightness == -1.0){
                print("輝度復元")
                UIScreen.main.brightness = original
            }
            else
            {
                print("輝度変更")
                if(brightness == 1.0)
                {
                    // 輝度を最大にする際に元の値を記憶する
                    original = UIScreen.main.brightness
                }
                UIScreen.main.brightness = CGFloat(brightness)
            }
            
        case "openWebsite":
            print("ブラウザオープン")
            let res = params?["url"] as? String ?? ""
            if let url = URL(string: res) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case "network_error":
            // 通信エラー検知
            // web側でモーダルを表示するので表示自体は封印した
            print("通信エラー検知")
            errorCode = ""
            errorMessage = ERROR_MES_NET
            modalType = .close
            isShowingModal = true
            
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
            print("要求")
            print(action)
        }
    }
    
    // iOS 18 系以下は ignore を適用
    var shouldIgnoreKeyboardSafeArea: Bool {
        let version = ProcessInfo().operatingSystemVersion
        return version.majorVersion <= 18
    }
}

#Preview {
    WebContentView(currentView: .constant(.web))
}
