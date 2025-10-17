//
//  RootView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//

import SwiftUI

// 画面の切り替わりを制御する、それぞれの画面からcurrentViewを切り替えることで表示が変わる
struct RootView: View {
    @State private var currentView: AppViewMode = .splash
    var body: some View {
        switch currentView {
        case .splash:
            SplashView(currentView: $currentView)
        case .login:
            LoginView(currentView: $currentView)
        case .web:
            WebContentView(currentView: $currentView)
        }
    }
}

#Preview {
    RootView()
}
