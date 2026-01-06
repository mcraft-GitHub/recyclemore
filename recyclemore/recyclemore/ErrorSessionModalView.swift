//
//  ErrorBackModalView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/17.
//

import SwiftUI

// 閉じるボタンでログイン画面に遷移するモーダル
struct ErrorSessionModalView: View {
    @Binding var isShowingModal: Bool
    @Binding var currentView: AppViewMode
    
    @State var messag = "左詰め自動改行"
    @State var code = "エラーコード"
    @State var isSimple = false
    
    let onTap: () -> Void // ← コールバック受け取る！

    var body: some View {
        ZStack {
            // モーダル（背景が少し暗くなる）
            Color.black.opacity(0.4) // 背景暗く
                .ignoresSafeArea()
           
            if(!isSimple)
            {
                VStack() {
                    Text("セッションタイムアウト")
                        .frame(width: 260,height: 23)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.top,30)
                        .padding(.bottom,17)
                    
                    Text(messag)
                        .frame(width: 260, alignment: .leading)
                        .font(.system(size: 15))
                        .padding(.bottom,15)
                        .padding(.horizontal,20)
                    
                    Text("【エラーコード: \(code)】")
                        .frame(width: 260, alignment: .leading)
                        .font(.system(size: 15))
                        .padding(.bottom,17)
                    
                    Button("ログイン画面へ") {
                        isShowingModal = false
                        onTap()
                    }
                    .frame(width: 124,height: 32)
                    .font(.system(size: 12, weight: .bold))
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                    .padding(.top,20)
                    .padding(.bottom,30)
                }
                .background(Color.white)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.25), radius: 5, x: 5, y: 5)
                .frame(maxWidth: 300)
            }
            else
            {
                VStack() {
                    Text("セッションタイムアウト")
                        .frame(width: 260,height: 23)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.top,30)
                        .padding(.bottom,17)
                    
                    Text(messag)
                        .frame(width: 260, alignment: .leading)
                        .font(.system(size: 15))
                        .padding(.bottom,15)
                        .padding(.horizontal,20)

                    Button("ログイン画面へ") {
                        isShowingModal = false
                        onTap()
                    }
                    .frame(width: 124,height: 32)
                    .font(.system(size: 12, weight: .bold))
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                    .padding(.top,20)
                    .padding(.bottom,30)
                }
                .background(Color.white)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.25), radius: 5, x: 5, y: 5)
                .frame(maxWidth: 300)
            }
        }
    }
}

#Preview {
    ErrorBackModalView(isShowingModal: .constant(true),currentView: .constant(.web))
}
