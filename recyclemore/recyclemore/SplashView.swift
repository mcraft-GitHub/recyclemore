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
    @State private var StatusCode = 200
    @State private var isError = false
    @State private var errorMessage = ""
    @State private var errorCode = ""
    @State private var GoWeb = true
    @State private var email:String?
    @State private var token:String?
    
    @State private var isShowingModal = false
    @State private var modalType:ModalType = .update
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all) // 背景
                
                VStack {
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        // 基準サイズ390x844を元に比率を出してスケーリング
                        .frame(
                            width: geometry.size.width * (156 /  CGFloat(BASE_SCREEN_WIDTH)),
                            height: geometry.size.height * (242 / CGFloat(BASE_SCREEN_HEIGHT))
                        )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                if isShowingModal {
                    switch modalType {
                    case .close :
                        ErrorModalView(isShowingModal: $isShowingModal,messag: errorMessage,code: errorCode)
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
                    var NeedUpdate = false
                    
                    // 3秒後にViewを切り替え
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(SPLASH_WINDOW_TIME)) {
                        print("3秒")
                        withAnimation(.none) {
                            //アプデが必要なら画面遷移どころでは無い
                            if(!NeedUpdate && !isError){
                                if(GoWeb)
                                {
                                    currentView = .web
                                }
                                else
                                {
                                    currentView = .web
                                }
                            }
                        }
                    }
                    
                    // バージョンチェックAPIを実行
                    await GetAppVersionAPI()
                    
                    // 正常に実行できた場合
                    if(VersionCheckComp) {
                        print("比較結果")
                        print(VersionCheckState)
                        // TODO:更新があれば誘導用のモーダルを表示する
                        if VersionCheckState == -1 {
                            NeedUpdate = true
                            isShowingModal = true
                            modalType = .forceUpdate
                            return
                        }
                        else if VersionCheckState == 1 {
                            NeedUpdate = true
                            isShowingModal = true
                            modalType = .update
                            return
                        }
                    }
                    else
                    {
                        // 失敗したらモーダル表示して中断
                        isShowingModal = true
                        return
                    }
                    
                    // トークンとメールアドレスの存在を確認
                    token = KeychainHelper.shared.read(key: "token")
                    email = KeychainHelper.shared.read(key: "email")
                    
                    // トークンかメアドが保存されていなければ遷移先をログイン画面にする
                    if(token == nil || email == nil)
                    {
                        GoWeb = false
                        print("UDID")
                        print(Appvisor.appvisorUDID())
                    }
                    else
                    {
                        token = "aa"
                        email = "aa"
                        // TODO:トークンとメアドの情報で自動ログインAPIを実行する
                        await AutoLoginAPI()
                        // 成功→特に何もしない(認証データを受け取る可能性あり)
                        // 失敗→遷移先をログイン画面にする
                    }
                }
            }
        }
    }
    
    func GetAppVersionAPI() async {
        // バージョン取得API
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/App/get-app-version")
        else
        {
            return
        }
        
        // 送信データ
        let params = [
            "OS":"iOS",
        ] as [String:Any]
        
        do {
            // テスト用の鉄砲玉
            /*
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "雑エラー"])
             */
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
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        isError = true
                        errorMessage = ERROR_MES_EXC
                        errorCode = "[エラーコード : 999]"
                        modalType = .close
                    }
                }
            }
            else
            {
                // エラー発生を記憶
                isError = true
                // 結果に問題があったのでステータスに応じたモーダルを表示
                if(StatusCode == 400 || StatusCode == 401) {
                    errorMessage = ERROR_MES_DEF
                    errorCode = ""
                    modalType = .close
                }
                else if(StatusCode == 429) {
                    errorMessage = ERROR_MES_429
                    errorCode = ""
                    modalType = .close
                }
                else if(StatusCode == 500) {
                    errorMessage = ERROR_MES_500
                    errorCode = ""
                    modalType = .close
                }
                else
                {
                    errorMessage = ERROR_MES_EXC
                    errorCode = ""
                    modalType = .close
                }
            }
        }
        catch {
            await MainActor.run {
                if error is URLError {
                    // 通信失敗として処理
                    print("通信失敗")
                    isError = true
                    errorMessage = ERROR_MES_NET
                    errorCode = "[エラーコード : 000]"
                    modalType = .close
                } else {
                    // 通信以外の実行エラー（予期しない例外）として処理
                    isError = true
                    errorMessage = ERROR_MES_EXC
                    errorCode = "[エラーコード : 999]"
                    modalType = .close
                }
            }
        }
    }
    
    func AutoLoginAPI() async {
        // ログインAPI
        guard let url = URL(string: "https://api-recyclemore-cafzh7ewbngsdreu.japaneast-01.azurewebsites.net/v1/Auth/auto-login")
        else
        {
            return
        }
        
        // 送信データ
        let params = [
            "mail":email!,
            "token":token!,
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
                // ログインには失敗しているので遷移先を変更
                GoWeb = false
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
                        
                        // ログインに成功したのでマルチ画面で表示するページを変更する
                        //TODO:MultiViewURLを書き換えること
                    }
                }
                else
                {
                    await MainActor.run {
                        print("デコード失敗")
                        // ログインに失敗しているので遷移先を変更
                        GoWeb = false
                    }
                }
            }
            else
            {
                await MainActor.run {
                    print("ログイン失敗")
                    // ログインに失敗しているので遷移先を変更
                    GoWeb = false
                }
            }
        }
        catch {
            await MainActor.run {
                print("通信自体失敗")
                // ログインに失敗しているので遷移先を変更
                GoWeb = false
            }
        }
    }
}



#Preview {
    SplashView(currentView: .constant(.splash))
}
