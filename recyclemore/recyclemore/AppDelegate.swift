//
//  AppDelegate.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/14.
//

import AppVisorSDK
import UIKit

// デリゲート、OSが都合よく呼んでくれる子達
class AppDelegate: NSObject,UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    // 最初に呼ばれる関数
    func application(_ applications: UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil)-> Bool {

        UNUserNotificationCenter.current().delegate = self
        
        let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String:Any]
        
        // 資料がAppvisorAppID = <APP_VISOR_API_KEY>となってるが変数名から正解を推察した
        let AppvisorAppKey = "e59c36571a"
        
        // 実質的にSDKの初期化（内部でOSへの許可取りやトークンの設定まで行われる）
        Appvisor.sharedInstance.enablePush(with:AppvisorAppKey, isDebug: true)
        Appvisor.sharedInstance.trackPush(with: userInfo)
        
        return true
    }

    // アプリがフォアグラウンドに来た
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appvisor.sharedInstance.clearBadgeNumber()
        print("戻った")
    }
    
    // デバイストークン登録処理
    // APNsのデバイストークンが取得できた際に呼ばれる
    func application(_ application:UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data) {
        Appvisor.sharedInstance.registerToken(with: deviceToken) { result in
            if !result.isSuccess {
                print("デバイストークンの登録成功失敗")
                debugPrint("code:\(result.error?.code) message:\(result.error?.message)")
            }
            else
            {
                print("デバイストークンの登録成功")
            }
        }
    }
    
    // デバイストークン取得失敗
    func application(_ application:UIApplication, didFailToRegisterForRemoteNotificationsWithError error:Error) {
        print("デバイストークンの取得に失敗")
    }
    
    func userNotificationCenter(_ center:UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.banner,.list]);
        // 必要ならここでフォアグラウンドプレゼンテーションのためのアクションを処理する
    }
    
    // 通知がタップされた際の処理
    func userNotificationCenter(_ center:UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping() -> Void) {
        let notification = response.notification
        
        // 通知からのデータ抽出
        let title = notification.request.content.title
        let body = notification.request.content.body
        let userInfo = notification.request.content.userInfo // This is already a dictionary
        
        // トラッキングの為の辞書の準備
        var trackingInfo:[String: Any] = userInfo.reduce(into: [:]) {
            (result, element) in
            if let key = element.key as? String {
                result[key] = element.value
            }
        }
        
        trackingInfo["title"] = title
        trackingInfo["body"] = body
        
        // バッジをアプリアイコンの右上に反映する
        let badge = userInfo["badge"] as? NSInteger
        
        // サウンドの再生(下記のサウンドのファイル名を取得しています。再生はお好みの方法で実装してください)
        let soundName = userInfo["sound"] as? String
        
        // プッシュの追跡
        Appvisor.sharedInstance.trackPush(with: trackingInfo)
        
        // 他の仕事を続ける
        completionHandler()
    }
}
