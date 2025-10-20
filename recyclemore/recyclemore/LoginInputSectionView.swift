//
//  LoginInputSectionView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//

import SwiftUI

// ログイン画面の情報入力ブロック
struct LoginInputSectionView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var currentView: AppViewMode
    var emailError: String?
    var passwordError: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing:24) {
                // メールアドレス入力ブロック
                InputFieldBlock(label: "メールアドレス", text: $email, errorMessage: emailError, isSecure: false)
                
                // パスワード入力ブロック
                InputFieldBlock(label: "パスワード", text: $password, errorMessage: passwordError,isSecure: true)
                
                // テキスト+アイコン
                HStack(spacing : 8) {
                    Text("パスワードを忘れた方")
                        .font(.system(size: 14))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14,weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    print("パスワードを忘れた方がタップされた")
                    // TODO:パスワード再設置画面のURLを設定する
                    MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest3.php"
                    currentView = .web
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    LoginInputSectionView(email: .constant("アドレス"), password: .constant("password"),currentView: .constant(.login))
}
