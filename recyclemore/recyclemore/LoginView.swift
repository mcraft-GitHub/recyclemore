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
    @State private var StatusCode = 200
    
    @State private var isLoading = false
    @State private var isShowingModal = false
    @State private var errorMessage = ""
    @State private var errorCode = ""
    @State private var modalType:ModalType = .close
    @State private var oneShot = true
    
    @State private var lastAPI = "Login"
    
    @State private var topPadding: CGFloat = 120 // メインコンテンツパディング高
    @State private var topPaddingOffset: CGFloat = 0 // パディング調整値
    
    var body: some View {
        if isLoading {
            LoadingView()
        }
        else
        {
            ZStack {
                // 背景色
                Color(UIColor.systemBackground).ignoresSafeArea()
                // ヘッダー部
                VStack(spacing: 0) {
                    // ヘッダー部分(位置固定)
                    ZStack {
                        Color.white
                        
                        Image("HeaderLogo")
                            .resizable()
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
                    
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
                ZStack {
                    // メインコンテンツ
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
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
                            .padding(.bottom, 40)
                            
                            // フォーム領域
                            VStack{
                                LoginInputSectionView(email: $email, password: $password,currentView: $currentView,emailError: emailErrorMessage,passwordError: passwordErrorMessage
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            .padding(.bottom)
                            .background(Color(hex: "#F7F8F8"))
                            .cornerRadius(6)
                            .shadow(
                                color: Color.black.opacity(0.2),
                                radius: 6,
                                x: 0,
                                y: 1
                            )
                            
                            // ボタン領域
                            HStack(spacing:10) {
                                Button(action: {
                                    print("戻るボタン")
                                    // スタート画面に戻る
                                    if(Server == "Dev")
                                    {
                                        MultiViewURL = BaseURL_Dev + StartDir
                                    }
                                    else
                                    {
                                        MultiViewURL = BaseURL_Dis + StartDir
                                    }
                                    currentView = .web
                                }) {
                                    Text("戻る")
                                        .frame(maxWidth: .infinity,minHeight: 20, maxHeight: 40)
                                        .fontWeight(.bold)
                                        .background(Color(hex: "#9FA0A0"))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                .frame(height: 40)
                                .shadow(
                                    color: Color.black.opacity(0.3),
                                    radius: 6,
                                    x: 0,
                                    y: 1
                                )
                                
                                Button(action: {
                                    Task {
                                        var email_OK = false
                                        var pass_OK = false
                                        topPaddingOffset = 0
                                        if email != "" {
                                            if(isValidEmail(email)) {
                                                emailErrorMessage = nil
                                                email_OK = true
                                            }
                                            else
                                            {
                                                emailErrorMessage = "メールアドレスが正しくありません"
                                                topPaddingOffset += 21
                                            }
                                        }
                                        else
                                        {
                                            emailErrorMessage = "メールアドレスが未入力です"
                                            topPaddingOffset += 21
                                        }
                                        
                                        if password != "" {
                                            if(isValidPassword(password)) {
                                                passwordErrorMessage = nil
                                                pass_OK = true
                                            }
                                            else
                                            {
                                                passwordErrorMessage = "パスワードが正しくありません"
                                                topPaddingOffset += 21
                                            }
                                        }
                                        else
                                        {
                                            passwordErrorMessage = "パスワードが未入力です"
                                            topPaddingOffset += 21
                                        }
                                        
                                        // 両方正しく入力されていればログインAPIを実行
                                        if (email_OK && pass_OK) {
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
                                })                                {
                                    Text("ログイン")
                                        .frame(maxWidth: .infinity,minHeight: 20, maxHeight: 40)
                                        .fontWeight(.bold)
                                        .background(Color(hex: "#0099D9"))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                .frame(height: 40)
                                .shadow(
                                    color: Color.black.opacity(0.3),
                                    radius: 6,
                                    x: 0,
                                    y: 1
                                )
                            }
                            .padding(.top,30)
                            .padding(.horizontal,10)
                        }
                        .frame(maxHeight: 370 + topPaddingOffset)
                    }
                    .padding(.horizontal, 20)
                    //.padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    if isShowingModal {
                        switch modalType {
                        case .close :
                            ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
                        case .retry:
                            ErrorRetryModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode,onRetry: {
                                Task{
                                    isLoading = true
                                    // リトライする内容を分岐
                                    if(lastAPI == "Login")
                                    {
                                        await LoginAPI()
                                    }
                                    else
                                    {
                                        await InitialLoginAPI()
                                    }
                                    isLoading = false
                                }
                            })
                        case .back:
                            ErrorBackModalView(isShowingModal: $isShowingModal,currentView: $currentView,messag: errorMessage,code: errorCode)
                        default:
                            EmptyView()
                        }
                    }
                }
                .onAppear {
                    // 一回だけね
                    if(oneShot)
                    {
                        oneShot = false
                        Task {
                            print("初回起動")
                            if(initial_email != "" && initial_token != "")
                            {
                                print("初回ログイン実行")
                                isLoading = true
                                await InitialLoginAPI()
                                isLoading = false
                            }
                        }
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
        
        var sendtoken = Appvisor.appvisorUDID()
        
        if(Server == "Dev")
        {
            sendtoken = "Success"
        }
        
        // 送信データ
        let params = [
            "mail":email,
            "password":password,
            "token":sendtoken,
            "os":"iOS",
        ] as [String:Any]
        
        print(params)
        
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
            if let httpResponse = response as? HTTPURLResponse {
                StatusCode = httpResponse.statusCode
                print("ステータスコード", StatusCode)
            }
            
            //レスポンスの表示
            if let jsonString = String(data: data, encoding: .utf8){
                await MainActor.run {
                    print(jsonString)
                }
            }
            
            // ログインに成功していれば
            if StatusCode == 200
            {
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    await MainActor.run{
                        // 結果からユーザー情報を作成
                        SharedUserData.userData = UserData(is_tel_verified: decoded.item.is_tel_verified, is_user_registered: decoded.item.is_user_registered, is_age_verified: decoded.item.is_age_verified)
                        
                        // ログインに成功した情報を端末に保存する
                        KeychainHelper.shared.save(sendtoken, key: "token")
                        KeychainHelper.shared.save(email, key: "email")
                        
                        // 表示する画面を切り替える
                        print("ホーム画面へ")
                        if(Server == "Dev")
                        {
                            MultiViewURL = BaseURL_Dev + HomeDir
                        }
                        else
                        {
                            MultiViewURL = BaseURL_Dis + HomeDir
                        }
                        currentView = .web
                    }
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = "[エラーコード : 999]"
                        modalType = .back
                        isShowingModal = true
                    }
                }
            }
            else
            {
                await MainActor.run {
                    // 結果に問題があったのでステータスに応じたモーダルを表示
                    if(StatusCode == 400) {
                        print("正しくログイン失敗")
                        errorMessage = ERROR_MES_LOGIN
                        errorCode = ""
                        modalType = .close
                        isShowingModal = true
                        
                        /*
                         print("仮成功模擬")
                         MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest2.php"
                         currentView = .web
                         */
                    }
                    else if(StatusCode == 401){
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = ""
                        modalType = .back
                        isShowingModal = true
                        
                    }
                    else if(StatusCode == 429) {
                        errorMessage = ERROR_MES_429
                        errorCode = ""
                        lastAPI = "Login"
                        modalType = .retry
                        isShowingModal = true
                    }
                    else if(StatusCode == 500) {
                        errorMessage = ERROR_MES_500
                        errorCode = ""
                        lastAPI = "Login"
                        modalType = .retry
                        isShowingModal = true
                    }
                    else
                    {
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = ""
                        modalType = .back
                        isShowingModal = true
                    }
                }
            }
        }
        catch {
            await MainActor.run {
                if error is URLError {
                    // 通信失敗として処理
                    print("通信失敗")
                    errorMessage = ERROR_MES_NET
                    errorCode = "[エラーコード : 000]"
                    lastAPI = "Login"
                    modalType = .retry
                    isShowingModal = true
                } else {
                    // 通信以外の実行エラー（予期しない例外）として処理
                    errorMessage = ERROR_MES_LOGIN_HEAVY
                    errorCode = "[エラーコード : 999]"
                    modalType = .back
                    isShowingModal = true
                }
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
        
        var sendtoken = Appvisor.appvisorUDID()
        
        if(Server == "Dev")
        {
            sendtoken = "Success"
        }
        
        // 送信データ
        let params = [
            "mail":initial_email,
            "initial_token":initial_token,
            "token":sendtoken,
            "os":"iOS",
        ] as [String:Any]
        
        print(params)
        
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
                if let decoded = try? JSONDecoder().decode(InitialLoginResponse.self, from: data) {
                    await MainActor.run{
                        // 結果からユーザー情報は作れない
                        // ログインに成功した情報を端末に保存する
                        KeychainHelper.shared.save(sendtoken, key: "token")
                        KeychainHelper.shared.save(initial_email, key: "email")
                        
                        // 使い終わった初回用データは消してしまう
                        initial_email = ""
                        initial_token = ""
                        
                        // 表示する画面を切り替える
                        if(Server == "Dev")
                        {
                            MultiViewURL = BaseURL_Dev + CreateDir
                        }
                        else
                        {
                            MultiViewURL = BaseURL_Dis + CreateDir
                        }
                        currentView = .web
                    }
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        
                        // 使い終わった初回用データは消してしまう
                        initial_email = ""
                        initial_token = ""
                        
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = "[エラーコード : 999]"
                        modalType = .back
                        isShowingModal = true
                    }
                }
            }
            else
            {
                // 使い終わった初回用データは消してしまう
                initial_email = ""
                initial_token = ""
                
                await MainActor.run {
                    // 結果に問題があったのでステータスに応じたモーダルを表示
                    if(StatusCode == 400) {
                        print("正しくログイン失敗")
                        errorMessage = ERROR_MES_LOGIN
                        errorCode = ""
                        modalType = .close
                        isShowingModal = true
                        
                        /*
                         print("仮成功模擬")
                         MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest2.php"
                         currentView = .web
                         */
                    }
                    else if(StatusCode == 401){
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = ""
                        modalType = .back
                        isShowingModal = true
                        
                    }
                    else if(StatusCode == 429) {
                        errorMessage = ERROR_MES_429
                        errorCode = ""
                        lastAPI = "InitialLogin"
                        modalType = .retry
                        isShowingModal = true
                    }
                    else if(StatusCode == 500) {
                        errorMessage = ERROR_MES_500
                        errorCode = ""
                        lastAPI = "InitialLogin"
                        modalType = .retry
                        isShowingModal = true
                    }
                    else
                    {
                        errorMessage = ERROR_MES_LOGIN_HEAVY
                        errorCode = ""
                        modalType = .back
                        isShowingModal = true
                    }
                }
            }
        }
        catch {
            // 使い終わった初回用データは消してしまう
            initial_email = ""
            initial_token = ""
            
            await MainActor.run {
                if error is URLError {
                    // 通信失敗として処理
                    print("通信失敗")
                    errorMessage = ERROR_MES_NET
                    errorCode = "[エラーコード : 000]"
                    lastAPI = "InitialLogin"
                    modalType = .retry
                    isShowingModal = true
                } else {
                    // 通信以外の実行エラー（予期しない例外）として処理
                    errorMessage = ERROR_MES_LOGIN_HEAVY
                    errorCode = "[エラーコード : 999]"
                    modalType = .back
                    isShowingModal = true
                }
            }
        }
    }
    
    // メアド用バリデーションチェック
    func isValidEmail(_ email: String) -> Bool {
        // 〇〇＠〇〇.〇〇のような構造
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    // パスワード用バリデーションチェック
    func isValidPassword(_ password: String) -> Bool {
        // 文字数不足は即アウト
        guard password.count >= 8 else {
            return false
        }
        
        var hasUppercase = false    //大文字
        var hasLowercase = false    //小文字
        var hasNumber = false       //数字
        var hasSymbol = false       //記号

        for char in password {
            if char.isUppercase {
                hasUppercase = true
            } else if char.isLowercase {
                hasLowercase = true
            } else if char.isNumber {
                hasNumber = true
            } else {
                hasSymbol = true
            }
        }
        
        // 4種盛りの完成を確認
        let typeCount = [hasNumber, hasUppercase, hasLowercase, hasSymbol].filter { $0 }.count
        return typeCount >= 3
    }
}

#Preview {
    LoginView(currentView: .constant(.login))
}
