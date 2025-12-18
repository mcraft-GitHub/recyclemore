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
    @FocusState.Binding var focusedField: LoginView.Field?
    
    var body: some View {
        VStack(spacing:20) {
            // メールアドレス入力ブロック
            InputFieldBlock(label: "メールアドレス", text: $email, errorMessage: emailError, isSecure: false,focusedField: $focusedField, fieldType: LoginView.Field.email)
            
            // パスワード入力ブロック
            InputFieldBlock(label: "パスワード", text: $password, errorMessage: passwordError,isSecure: true,focusedField: $focusedField, fieldType: LoginView.Field.password)
            
            // テキスト+アイコン
            HStack(spacing : 8) {
                Text("パスワードを忘れた方")
                    .lineSpacing(0)
                    .frame(height: 20)
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 6, height: 10)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                if(Server == "Dev")
                {
                    MultiViewURL = BaseURL_Dev + ForgetDir
                }
                else
                {
                    MultiViewURL = BaseURL_Dis + ForgetDir
                }
                
                currentView = .web
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    @FocusState var focusedField: LoginView.Field?
    
    LoginInputSectionView(email: .constant("アドレス"), password: .constant("password"),currentView: .constant(.login),focusedField: $focusedField)
}
