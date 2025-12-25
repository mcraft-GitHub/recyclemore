//
//  InputFieldBlockHelper.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//

import SwiftUI

// 入力フォームの部分だけをまとめたもの
struct InputFieldBlock: View {
    let label: String           //入力欄名称
    @Binding var text:String    //入力値
    let errorMessage: String?   //エラーメッセージ
    var isSecure:Bool = false   //秘匿性の有無
    @State private var isHidden: Bool = true    // パスワードのチラ見せ用
    // 親ビューの FocusState の Binding を受け取る
    @FocusState.Binding var focusedField: LoginView.Field?
    let fieldType: LoginView.Field
    
    // エラーメッセージの存在をチェック
    var hasError: Bool {
        return errorMessage != nil && !errorMessage!.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 15,weight: .bold))
                .frame(height: 20)
            
            // 枠線の設定(エラーがある時は赤くなる)
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .stroke(hasError ? Color.red : Color.gray.opacity(0.4),lineWidth: 2)
                    .frame(height: 40)
                
                // 隠す必要があるデータの場合は黒丸表示になる入力欄を使用する
                if(isSecure) {
                    HStack {
                        Group {
                            if isHidden {
                                SecureField("", text: $text)
                                    .frame(height: 40)
                                    .background(RoundedRectangle(cornerRadius: 0).fill(hasError ? Color(hex: "#FFF3F3") : Color.white))
                                    .keyboardType(.asciiCapable)
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: fieldType)
                            } else {
                                TextField("", text: $text)
                                    .frame(height: 40)
                                    .background(RoundedRectangle(cornerRadius: 0).fill(hasError ? Color(hex: "#FFF3F3") : Color.white))
                                    .keyboardType(.asciiCapable)
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: fieldType)
                            }
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        // トグルで変えるならこっち
                        Button(action: {
                            isHidden.toggle()
                        }) {
                            if(isHidden)
                            {
                                Image("passeye_c")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                            }
                            else
                            {
                                Image("passeye")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        
                        // 押してる間だけ見えるならこっち
                        /*
                        Image(systemName: "eye")
                                .foregroundColor(.gray)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if isHidden {
                                                isHidden = false
                                            }
                                        }
                                        .onEnded { _ in
                                            isHidden = true
                                        }
                                )
                         */
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 40)
                    .background(hasError ? Color(hex: "#FFF3F3") : Color.white)
                }
                else
                {
                    TextField("",text:$text)
                        .frame(height: 40)
                        .padding(.horizontal, 10)
                        .background(RoundedRectangle(cornerRadius: 0).fill(hasError ? Color(hex: "#FFF3F3") : Color.white))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            print("メールサブミット")
                            focusedField = .password
                        }
                }
            }
            
            // エラーがある時だけ表示されるメッセージ
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .frame(height: 16)
                    .foregroundColor(.red)
            }
        }
    }
}

// プレビューする時に渡される状態を定義
#Preview {
    @FocusState var focusedField: LoginView.Field?
    
    InputFieldBlock(
        label: "ラベル",
        text: .constant(""),
        errorMessage: "エラー",
        isSecure: false,
        focusedField: $focusedField,
        fieldType: LoginView.Field.email
    )
}
