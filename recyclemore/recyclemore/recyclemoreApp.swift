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
    @State private var isActive = false
    @StateObject private var appState = AppState()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            /*
            if isActive {
                //MainView()
                //WebContentView(currentView:  .constant(.web))
                //BrightnessView()
            }
            else{
                //SplashView(currentView: .constant(.splash))
            }
            */
            RootView()
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
