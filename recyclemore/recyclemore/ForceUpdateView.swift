//
//  ForceUpdateView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/20.
//

import SwiftUI

struct ForceUpdateView: View {
    var body: some View {
        ZStack {
            // モーダル（背景が少し暗くなる）
            Color.black.opacity(0.4) // 背景暗く
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("アップデートのお知らせ")
                    .frame(width: 260,height: 23)
                    .font(.system(size: 17, weight: .bold))
                    .padding(.top,30)
                    .padding(.bottom,17)
                
                Text("アプリを更新しました。\n最新版アプリへのアップデートをお願いします")
                    .frame(width: 260, alignment: .leading)
                    .font(.system(size: 15))
                    .padding(.bottom,17)

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
                .font(.system(size: 12, weight: .bold))
                .background(.black)
                .foregroundColor(.white)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                .padding(.top,20)
                .padding(.bottom,30)
            }
            .padding(.horizontal,20)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.25), radius: 5, x: 5, y: 5)
            .frame(maxWidth: 300)
        }
    }
}

#Preview {
    ForceUpdateView()
}
