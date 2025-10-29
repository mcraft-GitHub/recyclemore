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
    //var notificationDetails = notificationDetails()
    // 最初に呼ばれる関数
    func application(_ applications: UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil)-> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String:Any]
        
        let AppvisorAppID = "08207eeda3f64a280c17fb1a3a5f28653a21b31510474c60fcae1f519856fc7aa5b9234baaab710bb9d7a67c482cce48bb369730bfb6bd93562ffce87dcfe096"
        Appvisor.sharedInstance.enablePush(with:AppvisorAppID, isDebug: true)
        Appvisor.sharedInstance.trackPush(with: userInfo)
        
        return true
    }

    // アプリがフォアグラウンドに来た
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appvisor.sharedInstance.clearBadgeNumber()
        print("戻った")
    }
    
    // デバイストークン登録成功
    func application(_ application:UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data) {
        print("成功")
        Appvisor.sharedInstance.registerToken(with: deviceToken, completion: {_ in})
    }
    
    // デバイストークン取登録失敗
    func application(_ application:UIApplication, didfailToRemoteNotificationWithError error:Error) {
        print("エラー")
    }
    
    func userNotificationCenter(_ center:UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.banner,.list]);
        // ここでフォアグラウンドプレゼンテーションのためのアクションを処理する
    }
    
    func userNotificationCenter(_ center:UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping() -> Void) {
        // #if !TARGET_IPHONE_SIMULATOR
        let notification = response.notification
        //notificationDetails.notification = notification
        
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
        // #endif
    }
}
