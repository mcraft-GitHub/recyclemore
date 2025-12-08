//
//  WebViewHelper.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/08.
//

import SwiftUI
import WebKit

// WebViewはそのまま使えないのでラッパーを作成
struct WebView: UIViewRepresentable {
    @Binding var url: URL
    let onAction: (String) -> Void  // JSから情報を受け取るクロージャー
    
    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "appHandler")  // JSからの呼び出し用
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onAction: onAction)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onAction: (String) -> Void
        init(onAction: @escaping (String) -> Void) {
            self.onAction = onAction
        }
        
        func userContentController (_ userContentController: WKUserContentController,
                                    didReceive message: WKScriptMessage) {
            if let msg = message.body as? String {
                onAction(msg)
            }
        }
    }
}

// WebViewの中の出来事を拾えるように機能を追加したもの
struct HybridWebView: UIViewRepresentable {
    let url: URL
    let onCustomEvent: (String, [String: Any]?) -> Void  // イベント通知用
    @Binding var UIwebView: WKWebView?  // ← SwiftUI 側でwebViewに触れるように引き渡す
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        let preferences = WKWebpagePreferences()
        
        if #available(iOS 15.0, *) {
            preferences.preferredContentMode = .mobile
        }
        config.defaultWebpagePreferences = preferences
        
        // PostMessage機構用のハンドラー登録
        // web側で：window.webkit.messageHandlers.〇〇.postMessage("メッセージ") の〇〇部分が　name:　に入る
        // 複数のパターンがあるので言われるがままに登録していく
        config.userContentController.add(context.coordinator, name: "appHandler")
        config.userContentController.add(context.coordinator, name: "sendBrightness")
        config.userContentController.add(context.coordinator, name: "changeBrightness")
        config.userContentController.add(context.coordinator, name: "logout")
        config.userContentController.add(context.coordinator, name: "goToLogin")
        config.userContentController.add(context.coordinator, name: "sendLoginInfo")
        config.userContentController.add(context.coordinator, name: "openWebsite")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        // Binding の更新は非同期で行う
        DispatchQueue.main.async {
            self.UIwebView = webView
        }
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    class Coordinator: NSObject, WKNavigationDelegate,WKScriptMessageHandler {
        var parent: HybridWebView
        
        init(_ parent: HybridWebView) {
            self.parent = parent
        }
        
        // PostMessageの受信処理
        func userContentController(_ userContentContoroller: WKUserContentController, didReceive message: WKScriptMessage) {
            print("受信")
            // 基本サンプル
            if message.name == "appHandler" {
                // メッセージが文字列だけの場合
                if let actionString = message.body as? String {
                    //parent.onCustomEvent(actionString,["action": actionString])
                    return
                }
                
                // メッセージが辞書型の場合
                if let dict = message.body as? [String: Any],
                   let action = dict["action"] as? String {
                    //parent.onCustomEvent(action, dict)
                }
            }
            
            // ログイン画面への遷移要求
            if message.name == "goToLogin" {
                print("goToLogin")
                if let dict = message.body as? [String: Any] {
                    // 来るであろう情報を抜き出す
                    let mail = dict["mail"] as? String ?? ""
                    let token = dict["token"] as? String ?? ""
                    print("ログインボタンが押された → mail=\(mail), token=\(token)")
                    
                    // イベント通知
                    parent.onCustomEvent("goToLogin", ["mail": mail, "token": token])
                } else {
                    // オブジェクトではなく文字列が来たとき用の保険(多分来ない)
                    print("形式がおかしい")
                }
            }
            
            // ログイン情報送信要求
            if message.name == "sendLoginInfo" {
                print("sendLoginInfo")
                // イベント通知
                parent.onCustomEvent("sendLoginInfo", nil)
            }
            
            // ログアウト要求
            if message.name == "logout" {
                print("logout")
                // イベント通知
                parent.onCustomEvent("logout", nil)
            }
            
            // 輝度送信要求
            if message.name == "sendBrightness" {
                print("sendBrightness")
                // イベント通知
                parent.onCustomEvent("sendBrightness", nil)
            }
            
            // 輝度変更要求
            if message.name == "changeBrightness" {
                print("changeBrightness")
                if let dict = message.body as? [String: Any] {
                    // 来るであろう情報を抜き出す
                    let brightness = dict["brightness"] as? Float ?? 1.0
                    
                    // イベント通知
                    parent.onCustomEvent("changeBrightness", ["brightness": brightness])
                } else {
                    // オブジェクトではなく文字列が来たとき用の保険(多分来ない)
                    print("形式がおかしい")
                }
            }
            
            // ブラウザ起動要求
            if message.name == "openWebsite" {
                print("openWebsite")
                if let dict = message.body as? [String: Any] {
                    // 来るであろう情報を抜き出す
                    let url = dict["url"] as? String ?? ""
                    // イベント通知
                    parent.onCustomEvent("openWebsite", ["url": url])
                } else {
                    // オブジェクトではなく文字列が来たとき用の保険(多分来ない)
                    print("形式がおかしい")
                }
            }
        }
        
        // URL遷移の検出処理
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("url変更！")
            if let url = navigationAction.request.url,
               url.scheme == "myapp" {
                let action = url.host ?? "unknown"  // パスの終端を取得(例：myapp://test/login なら　loginが取れる)
                // GETパラメータの値を分解して取得
                let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                    .queryItems?
                    .reduce(into: [String: Any]()) {
                        $0[$1.name] = $1.value
                    }
                parent.onCustomEvent(action, params)    // アプリ側にイベントを通知
                decisionHandler(.cancel)    // WebView側の遷移を止める
                return
            }
            decisionHandler(.allow)
        }
        
        // webView内のページの読み込みが完了したタイミングで実行される
        // 特定の画面のみなんらかの処理を行いたい場合はここに仕込めば実現可能
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            //開いているURLを確認
            guard let currentURL = webView.url?.absoluteString else {
                    print("URLが取れなかった") // そんなことがあるかは知らぬ
                    return
                }
            
            let targetURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest.php"
            
            // 特定のURLだった場合はページ内のJSを実行する処理を呼ぶ
            if(currentURL == targetURL)
            {
                //例、必要に応じてContentViewにも対応する処理を書くこと
                //parent.onCustomEvent("first",nil)
            }
        }
        
        // ページ読み込み失敗時
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleWebError(error)
        }

        // ページ読み込み開始時に失敗した場合（通信OFFなど）
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleWebError(error)
        }

        // 共通のエラーハンドラ
        private func handleWebError(_ error: Error) {
            if let urlError = error as? URLError {
                print("WKWebView error:", urlError.code.rawValue, urlError.localizedDescription)
                switch urlError.code {
                case .notConnectedToInternet:
                    parent.onCustomEvent("network_error", nil)
                case .timedOut:
                    parent.onCustomEvent("network_timeout", ["message": "通信がタイムアウトしました"])
                default:
                    parent.onCustomEvent("network_other", ["message": urlError.localizedDescription])
                }
            } else {
                parent.onCustomEvent("web_error", ["message": error.localizedDescription])
            }
        }
    }
}

//旧情報
/*
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct ContentWebView: View {
    var body: some View{
        VStack(spacing: 20){
            Text("上のコンテンツ")
                .font(.title)
                .padding()
            
            // 画面の一部だけにwebviewを配置
            WebView(url: URL(string: "https://www.apple.com")!)
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding()
            
            Text("下のコンテンツ")
                .foregroundColor(.red)
        }
        .padding()
    }
}
*/
