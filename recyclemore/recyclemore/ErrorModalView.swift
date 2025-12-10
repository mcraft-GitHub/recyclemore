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
    @State var isSimple = false

    var body: some View {
        ZStack {
            // モーダル（背景が少し暗くなる）
            Color.black.opacity(0.4) // 背景暗く
                .ignoresSafeArea()
            
            if(!isSimple)
            {
                VStack() {
                    Text("エラー")
                        .bold()
                        .frame(width: 260,height: 23)
                        .font(.custom("NotoSansJP-Regular", size: 17))
                        .padding(.top,30)
                        .padding(.bottom,17)
                    
                    Text(messag)
                        .frame(width: 260, alignment: .leading)
                        .font(.custom("NotoSansJP-Regular", size: 15))
                        .padding(.bottom,15)
                        .padding(.horizontal,20)
                    
                    Text("エラーコード: \(code)")
                        .frame(width: 260, alignment: .leading)
                        .font(.custom("NotoSansJP-Regular", size: 15))
                        .padding(.bottom,17)
                    
                    Button("閉じる") {
                        isShowingModal = false
                    }
                    .frame(width: 124,height: 32)
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .bold()
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
                VStack(spacing: 16) {
                    Text("エラー")
                        .bold()
                        .frame(width: 260,height: 23)
                        .font(.custom("NotoSansJP-Regular", size: 17))
                    
                    Text(messag)
                        .frame(width: 260, alignment: .leading)
                        .font(.custom("NotoSansJP-Regular", size: 15))
                    
                    Button("閉じる") {
                        isShowingModal = false
                    }
                    .frame(width: 124,height: 32)
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 1)
                    .padding(.top,20)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.25), radius: 5, x: 5, y: 5)
                .frame(maxWidth: 300)
            }
        }
    }
}

#Preview {
    ErrorModalView(isShowingModal: .constant(true))
}
