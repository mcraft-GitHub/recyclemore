//
//  MainView.swift
//  recyclemore
//
//  Created by 貸し出し用 on 2025/10/07.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!!!!!!")
            Button("押す？"){
                print("ポチ")
            }
        }
        .padding()
        .task {
            await checkVersion()
            await TestPostExample()
            DeleteToken()
        }
    }
    
    // 情報の記憶テスト
    func SetToken(){
        KeychainHelper.shared.save("cdefg", key: "token")
        KeychainHelper.shared.save("123@abc",key: "email")
    }
    
    // 情報の削除テスト
    func DeleteToken(){
        KeychainHelper.shared.delete(key: "token")
        KeychainHelper.shared.delete(key: "email")
    }
    
    // GET通信の模擬
    func checkVersion() async {
        // 模擬API
        guard let url = URL(string: "https://dev5.m-craft.com/harada/mc_kadai/laravel/TEST1/server.php/api/LogIn/1") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decoded = try? JSONDecoder().decode(TestResponse.self, from: data) {
                await MainActor.run{
                    print(decoded.access_token)
                }
            }
            else
            {
                await MainActor.run {
                    print("デコード失敗")
                }
            }
        }
        catch {
            await MainActor.run {
                print("通信失敗")
            }
        }
    }
    
    func TestPostExample() async {
        // 模擬API
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        else
        {
            return
        }
        // 送信データ
        let params = [
            "title":"hello",
            "body":"Swiftより",
            "userId":1
        ] as [String:Any]
        
        do {
            //リクエストデータの作成
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("appkication/json", forHTTPHeaderField: "Content-Type")
            
            //ボディにJsonをセット
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            
            //通信を実行
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //ステータスコードの確認
            if let httpResponse = response as? HTTPURLResponse {
                print("ステータスコード", httpResponse.statusCode)
            }
            
            //レスポンスの表示
            if let jsonString = String(data: data, encoding: .utf8){
                await MainActor.run {
                    print(jsonString)
                }
            }
        }
        catch {
            await MainActor.run {
                print("通信失敗")
            }
        }
    }
}

// 仮のレスポンス
struct TestResponse: Codable{
    let access_token: String
}

// 仮POSTのレスポンス
struct TestPostResponse: Codable{
    let title: String
    let body: String
    let userId: Int
    let id: Int
}

#Preview {
    MainView()
}
