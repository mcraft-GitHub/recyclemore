//
//  LoginView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//

import AppVisorSDK
import SwiftUI

// ログイン画面
struct LoginView: View {
    
    @Binding var currentView: AppViewMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var emailErrorMessage: String? = nil
    @State private var passwordErrorMessage: String? = nil
    
    @State private var isLoading = false
    @State private var isShowingModal = false
    @State private var errorMessage = ""
    @State private var errorCode = ""
    @State private var modalType:ModalType = .close
    
    @State private var topPadding: CGFloat = 120 // メインコンテンツパディング高
    @State private var topPaddingOffset: CGFloat = 0 // パディング調整値
    
    var body: some View {
        if isLoading {
            LoadingView()
        }
        else
        {
            // ヘッダー部
            VStack(spacing: 0) {
                // ヘッダー部分(位置固定)
                ZStack {
                    Color.white
                    
                    Image("HeaderLogo")
                        .resizable()
                    //.scaledToFit()
                        .frame(
                            width: 177.5,
                            height: 30)
                    
                }
                .frame(height: 60)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray),
                    alignment: .bottom
                )
            }
            .background(Color(UIColor.systemBackground))
            ZStack {
                // メインコンテンツ
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 32) {
                            // アイコンとテキスト領域
                            HStack(spacing:12) {
                                Image("LoginIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                
                                Text("ログイン")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            
                            // フォーム領域
                            VStack{
                                LoginInputSectionView(email: $email, password: $password,currentView: $currentView,emailError: emailErrorMessage,passwordError: passwordErrorMessage
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            .padding(.bottom)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                            // ボタン領域
                            HStack(spacing:20) {
                                Button(action: {
                                    print("戻るボタン")
                                    // 前の画面に戻る
                                    currentView = .web
                                }) {
                                    Text("戻る")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    Task {
                                        topPaddingOffset = 0
                                        if email != "" {
                                            emailErrorMessage = nil
                                        }
                                        else
                                        {
                                            emailErrorMessage = "未入力"
                                            topPaddingOffset += 10
                                        }
                                        
                                        if password != "" {
                                            passwordErrorMessage = nil
                                        }
                                        else
                                        {
                                            passwordErrorMessage = "未入力"
                                            topPaddingOffset += 10
                                        }
                                        
                                        // 両方入力されていればログインAPIを実行
                                        if (email != "" && password != "") {
                                            // ログインAPIを実行
                                            isLoading = true
                                            await LoginAPI()
                                            isLoading = false
                                        }
                                        else
                                        {
                                            return // 未入力があれば進ませない
                                        }
                                    }
                                }) {
                                    Text("ログイン")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 40)
                        .padding(.top,topPadding-topPaddingOffset)
                        .frame(maxWidth: .infinity)
                    }
                }
                if isShowingModal {
                    switch modalType {
                    case .close :
                        ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
                    case .retry:
                        ErrorRetryModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode,onRetry: {
                            Task{
                                isLoading = true
                                await LoginAPI()
                                isLoading = false
                            }
                        })
                    case .back:
                        ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    func LoginAPI() async {
        // ログインAPI
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/Auth/login")
        else
        {
            return
        }
        
        // 送信データ
        let params = [
            "mail":email,
            "password":password,
            "token":Appvisor.appvisorUDID(),
            "OS":"iOS",
        ] as [String:Any]
        
        do {
            //リクエストデータの作成
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(API_KEY, forHTTPHeaderField: "x-recyclemore-api-key")
            
            //ボディにJsonをセット
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            
            //通信を実行
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //ステータスコードの確認
            guard let httpResponse = response as? HTTPURLResponse else {
                print("HTTPレスポンスじゃないので中断")
                return
            }
            
            print("ステータスコード", httpResponse.statusCode)
            
            //レスポンスの表示
            if let jsonString = String(data: data, encoding: .utf8){
                await MainActor.run {
                    print(jsonString)
                }
            }
            
            // ログインに成功していれば
            if httpResponse.statusCode == 200
            {
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    await MainActor.run{
                        // 結果からユーザー情報を作成
                        SharedUserData.userData = UserData(is_tel_verified: decoded.item.is_tel_verified, is_user_registered: decoded.item.is_user_registered, is_age_verified: decoded.item.is_age_verified)
                        
                        // ログインに成功した情報を端末に保存する
                        KeychainHelper.shared.save(Appvisor.appvisorUDID(), key: "token")
                        KeychainHelper.shared.save(email, key: "email")
                        
                        // 表示する画面を切り替える
                        currentView = .web
                    }
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        // TODO:エラーモーダルを表示する
                        isShowingModal = true;
                    }
                }
            }
            else
            {
                await MainActor.run {
                    print("ログイン失敗")
                    // TODO:エラーコードに応じてエラーモーダルを分岐する
                    errorMessage = "ログインに失敗しました\nメールアドレスとパスワードをお確かめください"
                    errorCode = "エラーコード：001"
                    modalType = .close
                    isShowingModal = true
                    /*
                    print("仮成功模擬")
                    MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest2.php"
                    currentView = .web
                    */
                }
            }
        }
        catch {
            await MainActor.run {
                print("通信自体失敗")
                // TODO:エラーモーダルを表示する
                isShowingModal = true
            }
        }
    }
    
    func InitialLoginAPI() async {
        // 初回ログインAPI
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/Auth/initial-login")
        else
        {
            return
        }
        
        // 送信データ
        let params = [
            "mail":initial_email,
            "initial_token":initial_token,
            "token":Appvisor.appvisorUDID(),
            "OS":"iOS",
        ] as [String:Any]
        
        do {
            //リクエストデータの作成
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(API_KEY, forHTTPHeaderField: "x-recyclemore-api-key")
            
            //ボディにJsonをセット
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            
            //通信を実行
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //ステータスコードの確認
            guard let httpResponse = response as? HTTPURLResponse else {
                print("HTTPレスポンスじゃないので中断")
                return
            }
            
            print("ステータスコード", httpResponse.statusCode)
            
            //レスポンスの表示
            if let jsonString = String(data: data, encoding: .utf8){
                await MainActor.run {
                    print(jsonString)
                }
            }
            
            // ログインに成功していれば
            if httpResponse.statusCode == 200
            {
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    await MainActor.run{
                        // 結果からユーザー情報は作れない
                        // ログインに成功した情報を端末に保存する
                        KeychainHelper.shared.save(Appvisor.appvisorUDID(), key: "token")
                        KeychainHelper.shared.save(initial_email, key: "email")
                        
                        // 表示する画面を切り替える
                        // TODO:URLも切り替える
                        currentView = .web
                    }
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        // TODO:エラーモーダルを表示する
                        isShowingModal = true;
                    }
                }
            }
            else
            {
                await MainActor.run {
                    print("ログイン失敗")
                    // TODO:エラーコードに応じてエラーモーダルを分岐する
                    errorMessage = "ログインに失敗しました\nメールアドレスとパスワードをお確かめください"
                    errorCode = "エラーコード：001"
                    modalType = .close
                    isShowingModal = true
                    /*
                    print("仮成功模擬")
                    MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest2.php"
                    currentView = .web
                    */
                }
            }
        }
        catch {
            await MainActor.run {
                print("通信自体失敗")
                // TODO:エラーモーダルを表示する
                isShowingModal = true
            }
        }
    }
}

#Preview {
    LoginView(currentView: .constant(.login))
}
