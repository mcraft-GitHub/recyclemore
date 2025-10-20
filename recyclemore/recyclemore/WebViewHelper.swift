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
        
        // PostMessage機構用のハンドラー登録
        // web側で：window.webkit.messageHandlers.〇〇.postMessage("メッセージ") の〇〇部分が　name:　に入る
        config.userContentController.add(context.coordinator, name: "appHandler")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        // ✅ Binding の更新は非同期で行う
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
            if message.name == "appHandler" {
                // メッセージが文字列だけの場合
                if let actionString = message.body as? String {
                    parent.onCustomEvent(actionString,["action": actionString])
                    return
                }
                
                // メッセージが辞書型の場合
                if let dict = message.body as? [String: Any],
                   let action = dict["action"] as? String {
                    parent.onCustomEvent(action, dict)
                }
            }
        }
        
        // URL遷移の検出処理
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
                parent.onCustomEvent("first",nil)
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
