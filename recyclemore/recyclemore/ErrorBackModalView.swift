//
//  ErrorBackModalView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/17.
//

import SwiftUI

// 閉じるボタンでログイン画面に遷移するモーダル
struct ErrorBackModalView: View {
    @Binding var isShowingModal: Bool
    @Binding var currentView: AppViewMode
    
    @State var messag = "左詰め自動改行"
    @State var code = "エラーコード"

    var body: some View {
        ZStack {
            // モーダル（背景が少し暗くなる）
            Color.black.opacity(0.4) // 背景暗く
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("エラー")
                    .bold()
                    .frame(width: 260,height: 23)
                
                Text(messag)
                    .frame(width: 260, alignment: .leading)
                
                Text(code)
                    .frame(width: 260, alignment: .leading)
                
                Button("ログイン画面へ") {
                    isShowingModal = false
                }
                .frame(width: 126,height: 32)
                .background(.black)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 8)
            .frame(maxWidth: 300)
        }
    }
}

#Preview {
    ErrorBackModalView(isShowingModal: .constant(true),currentView: .constant(.web))
}
