//
//  SplashView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/07.
//

import SwiftUI
import AppVisorSDK

// スプラッシュ画面、標準の機能だと時間の制御が不可だったのでカスタム対応
struct SplashView: View {
    
    @Binding var currentView: AppViewMode
    @State private var VersionCheckState = 0
    @State private var VersionCheckComp = false
    @State private var AutoLoginComp = false
    @State private var StatusCode = 200
    @State private var errorMessage = ""
    @State private var errorCode = ""
    @State private var isSimple = false
    @State private var email:String?
    @State private var token:String?
    
    @State private var isShowingModal = false
    @State private var modalType:ModalType = .update
    
    @State private var APIStep = 0
    
    @State private var StartTime = Date()

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all) // 背景
                
                VStack {
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                if isShowingModal {
                    switch modalType {
                    case .retry:
                        ErrorRetryModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode,isSimple: isSimple, onRetry: {
                            Task{
                                // フローを進行状況に応じて再開
                                await SplashFlow()
                            }
                        })
                    case .close :
                        ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
                    case .session:
                        ErrorSessionModalView(isShowingModal: $isShowingModal,currentView: $currentView,messag: errorMessage,code: errorCode,isSimple: isSimple, onTap: {
                            Task{
                                withAnimation(.none) {
                                    currentView = .login
                                }
                            }
                        })
                    case .update :
                        UpdateModal(isShowingModal: $isShowingModal)
                        
                    case .forceUpdate :
                        ForceUpdateView()
                    
                    default:
                        EmptyView()
                    }
                }
            }
            .onAppear {
                Task {
                    StartTime = Date()
                    await SplashFlow()
                }
            }
        }
    }
    
    func SplashFlow() async{
        
        if(IsByURL)
        {
            // このパターンは別の導線で対処
            return
        }

        print("step1")
        if(APIStep < 1)
        {
            // バージョンチェックAPIを実行
            VersionCheckComp = await GetAppVersionAPI()
            
            // 正常に実行できた場合
            if(VersionCheckComp) {
                //APIStep = 1 // フローの段階を更新
                print("比較結果")
                print(VersionCheckState)
                if VersionCheckState == -1 {
                    isShowingModal = true
                    modalType = .forceUpdate
                    return
                }
                else if VersionCheckState == 1 {
                    isShowingModal = true
                    //TODO:必要なら任意更新のモーダルにする
                    modalType = .forceUpdate
                    return
                }
            }
            else
            {
                // 失敗したらモーダル表示して中断
                isShowingModal = true
                return
            }
        }
        
        print("step2")
        if(APIStep < 2) {
            // トークンとメールアドレスの存在を確認
            token = KeychainHelper.shared.read(key: "token")
            email = KeychainHelper.shared.read(key: "email")
            
            // トークンかメアドが保存されていなければ遷移先をスタート画面にする
            if(token == nil || email == nil)
            {
                print("スタート画面へ")
                if(Server == "Dev")
                {
                    MultiViewURL = BaseURL_Dev + StartDir
                }
                else
                {
                    MultiViewURL = BaseURL_Dis + StartDir
                }
                print("UDID")
                print(Appvisor.appvisorUDID())
            }
            else
            {
                print("ホーム画面へ")
                
                AutoLoginComp = await AutoLoginAPI()
                
                if(AutoLoginComp)
                {
                    // ログインに成功したのでマルチ画面で表示するページを変更する
                    if(Server == "Dev")
                    {
                        MultiViewURL = BaseURL_Dev + HomeDir
                    }
                    else
                    {
                        MultiViewURL = BaseURL_Dis + HomeDir
                    }
                }
                else
                {
                    // 失敗したらモーダル表示して中断
                    isShowingModal = true
                    return
                }
            }
            //APIStep = 2 // フローの段階を更新
        }
        
        print("step3")
        
        let elapsed = Date().timeIntervalSince(StartTime)
        let required = Double(SPLASH_WINDOW_TIME)

        if elapsed < required {
            let wait = required - elapsed
            print("待ち時間")
            print(wait)
            try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
        }
        print("表示から３秒以上経過")
        
        withAnimation(.none) {
            currentView = .web
        }
    }
    
    func GetAppVersionAPI() async -> Bool{
        // バージョン取得API
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/App/get-app-version")
        else
        {
            return false
        }
        
        let os = "iOS"
        
        // 送信データ
        let params = [
            "os":os,
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
            
            // 正常成功時の処理
            if (StatusCode == 200) {
                if let decoded = try? JSONDecoder().decode(GetAppVersionResponse.self, from: data) {
                    await MainActor.run{
                        print(decoded.item.need_version)
                        // ここで比較した結果をもらって反映
                        VersionCheckState = compareVersion(decoded.item.now_version,decoded.item.need_version)
                    }
                    // 比較結果に関わらずAPIの実行結果としては成功
                    return true
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        
                        let jsonString = String(data: data, encoding: .utf8)
                        var code = ""
                        
                        if let jsonData = jsonString!.data(using: .utf8) {
                            do {
                                // JSON オブジェクトに変換
                                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                    
                                    // result_code を取り出す
                                    if let resultCode = jsonObject["result_code"] as? String {
                                        code = String(resultCode.suffix(5))
                                    }
                                }
                            } catch {
                                print("JSONパースエラー: \(error)")
                            }
                        }
                        
                        errorMessage = ERROR_MES_SPLASH
                        errorCode = code
                        isSimple = false
                        modalType = .retry
                    }
                    return false
                }
            }
            else
            {
                // 結果に問題があったのでモーダル表示内容を作成
                errorMessage = ERROR_MES_SPLASH
                isSimple = false
                modalType = .retry
                
                if(StatusCode == 400) {
                    print("400")
                    errorCode = "-400"
                }
                else if(StatusCode == 401)
                {
                    print("401")
                    errorCode = "-401"
                }
                else if(StatusCode == 429) {
                    print("429")
                    errorCode = "-429"
                }
                else if(StatusCode == 500) {
                    print("500")
                    errorCode = "-500"
                }
                else
                {
                    print("999")
                    errorCode = "-999"
                }
                return false
            }
        }
        catch {
            await MainActor.run {
                if error is URLError {
                    // 通信失敗として処理
                    print("通信失敗")
                    errorMessage = ERROR_MES_NET
                    errorCode = ""
                    isSimple = true
                    modalType = .retry
                } else {
                    // 通信以外の実行エラー（予期しない例外）として処理
                    print("想定外のエラー")
                    errorMessage = ERROR_MES_SPLASH
                    errorCode = "-999"
                    isSimple = false
                    modalType = .retry
                }
            }
            return false
        }
    }
    
    func AutoLoginAPI() async ->Bool {
        // ログインAPI
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/Auth/auto-login")
        else
        {
            return false
        }
        
        // 送信データ
        let params = [
            "mail":email!,
            "token":token!,
            "os":"iOS",
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
            
            // 通信に成功していれば
            if StatusCode == 200
            {
                // ログイン成功
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    await MainActor.run{
                        // 結果からユーザー情報を作成
                        SharedUserData.userData = UserData(is_tel_verified: decoded.item.is_tel_verified, is_user_registered: decoded.item.is_user_registered, is_age_verified: decoded.item.is_age_verified)
                    }
                    return true
                }
                else // ログイン失敗
                {
                    // 失敗する情報を削除
                    KeychainHelper.shared.delete(key: "token")
                    KeychainHelper.shared.delete(key: "email")
                    await MainActor.run {
                        print("デコード失敗")
                        
                        let jsonString = String(data: data, encoding: .utf8)
                        var code = ""
                        
                        if let jsonData = jsonString!.data(using: .utf8) {
                            do {
                                // JSON オブジェクトに変換
                                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                    
                                    // result_code を取り出す
                                    if let resultCode = jsonObject["result_code"] as? String {
                                        code = String(resultCode.suffix(5))
                                    }
                                }
                            } catch {
                                print("JSONパースエラー: \(error)")
                            }
                        }
                        
                        errorMessage = ERROR_MES_SESSION
                        errorCode = code
                        isSimple = true
                        modalType = .session
                    }
                    return false
                }
            }
            else
            {
                await MainActor.run {
                    
                    // TODO:失敗する情報を削除
                    //KeychainHelper.shared.delete(key: "token")
                    //KeychainHelper.shared.delete(key: "email")
                    
                    // 結果に問題があったのでモーダル表示内容を作成
                    errorMessage = ERROR_MES_SPLASH
                    isSimple = false
                    modalType = .retry
                    
                    if(StatusCode == 400) {
                        // ログイン失敗
                        print("400")
                        errorCode = "-400"
                    }
                    else if(StatusCode == 401) {
                        errorCode = "-401"
                    }
                    else if(StatusCode == 429) {
                        errorCode = "-429"
                    }
                    else if(StatusCode == 500) {
                        errorCode = "-500"
                    }
                    else
                    {
                        errorCode = "-999"
                    }
                }
                return false
            }
        }
        catch {
            // TODO:失敗する情報を削除
            //KeychainHelper.shared.delete(key: "token")
            //KeychainHelper.shared.delete(key: "email")
            
            await MainActor.run {
                if error is URLError {
                    // 通信失敗として処理
                    print("通信失敗")
                    errorMessage = ERROR_MES_NET
                    errorCode = ""
                    isSimple = true
                    modalType = .retry
                } else {
                    // 通信以外の実行エラー（予期しない例外）として処理
                    errorMessage = ERROR_MES_SPLASH
                    errorCode = "-999"
                    isSimple = false
                    modalType = .retry
                }
            }
            return false
        }
    }
}

#Preview {
    SplashView(currentView: .constant(.splash))
}
