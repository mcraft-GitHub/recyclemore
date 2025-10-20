//
//  UpdateModal.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/20.
//

import SwiftUI

struct UpdateModal: View {
    @Binding var isShowingModal: Bool

    var body: some View {
        ZStack {
            // モーダル（背景が少し暗くなる）
            Color.black.opacity(0.4) // 背景暗く
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("アップデートのお知らせ")
                    .bold()
                    .frame(width: 260,height: 23)
                
                Text("アプリを更新しました。\n最新版アプリへのアップデートをお願いします")
                    .frame(width: 260, alignment: .leading)
                
                HStack{
                    Button("アップデート") {
                        // App Storeへ
                        print("App Storeへ")
                        // TODO:正しいStoreIdを入れること
                        /*
                        if let url = URL(string: "https://apps.apple.com/jp/app/id1234567890") {
                            UIApplication.shared.open(url)
                        }
                         */
                    }
                    .frame(width: 112,height: 32)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("閉じる") {
                        isShowingModal = false
                    }
                    .frame(width: 112,height: 32)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 8)
            .frame(maxWidth: 320)
        }
    }
}

#Preview {
    UpdateModal(isShowingModal: .constant(true))
}
