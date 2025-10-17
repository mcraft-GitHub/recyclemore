//
//  WebContentView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/08.
//

import SwiftUI

// 実質的な本体機能はここ(WebViewの中)、URLを指定しwebページを表示する
struct WebContentView: View {
    
    @Binding var currentView: AppViewMode
    
    var body: some View {
        HybridWebView(url: URL(string: MultiViewURL)!,
                      onCustomEvent: { action, params in handleWebEvent(action: action, params: params)
        }
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
            
        case "member":
            print("輝度")
        default:
            print("なんかされた")
        }
    }
}

#Preview {
    WebContentView(currentView: .constant(.web))
}
