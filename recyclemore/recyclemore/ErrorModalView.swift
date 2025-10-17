//
//  ErrorModalView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/16.
//

import SwiftUI

// 閉じるボタンでモーダルが閉じるだけの基本的なモーダル
struct ErrorModalView: View {
    @Binding var isShowingModal: Bool
    
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
                
                Button("閉じる") {
                    isShowingModal = false
                }
                .frame(width: 100,height: 32)
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
    ErrorModalView(isShowingModal: .constant(true))
}
