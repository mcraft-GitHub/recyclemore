//
//  RootView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//

import SwiftUI

// 画面の切り替わりを制御する、それぞれの画面からcurrentViewを切り替えることで表示が変わる
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        switch appState.currentView {
        case .splash:
            SplashView()
        case .login:
            LoginView()
        case .web:
            WebContentView()
        case .blank:
            EmptyView()
        }
    }
}

#Preview {
    RootView()
}
