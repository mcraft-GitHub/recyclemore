//
//  common.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/09.
//
// 諸々の共通データとかをまとめたもの

import SwiftUI

//アプリバージョン
let APP_VERSION = "1.0.3"

// ユーザー情報構造体
struct UserData: Codable{
    var is_tel_verified: String
    var is_user_registered: String
    var is_age_verified: String
}

// 共通で利用するユーザーデータクラス
class SharedUserData {
    static var userData: UserData? = nil
}

// enum群

// 表示画面種別
enum AppViewMode {
    case splash
    case login
    case web
}

// モーダル種別 1:閉じる　2:リトライ 3:ログイン画面へ 4:アップデート 5:強制アップデート
enum ModalType {
    case close
    case retry
    case back
    case update
    case forceUpdate
}

// 定数
let BASE_SCREEN_WIDTH = 390     // 基準画面幅
let BASE_SCREEN_HEIGHT = 844    // 基準画面高さ
let SPLASH_WINDOW_TIME = 3      // スプラッシュ画面の表示時間

// 汎用エラーメッセージ定型分
let ERROR_MES_DEF = "通信に問題が発生しました。しばらくしてから再度お試しください。"
let ERROR_MES_EXC = "予期しないエラーが発生しました。時間をおいて再度お試しください。"
let ERROR_MES_NET = "通信エラーが発生しました。ネットワーク環境をご確認ください。"
let ERROR_MES_LOGIN = "メールアドレスまたはパスワードが正しくありません。"
let ERROR_MES_LOGIN_HEAVY = "ログインに失敗しました。\nお手数ですが再度ログインをお試しください。\n何度も失敗する場合はお手数ですが\n【TEL:0000-00-0000】までお問い合わせください。"
let ERROR_MES_429 = "アクセスが集中しています。しばらくしてから再度お試しください。"
let ERROR_MES_500 = "サーバーで問題が発生しました。しばらくしてから再度お試しください。"

// 共通の変数
// マルチ画面で表示するURL情報
var MultiViewURL = "https://dev5.m-craft.com/harada/mc_kadai/SwiftTEST/WebViewtest.php"

// API実行時の認証キー
let API_KEY = "T9xLmQ2vZ8KfJr7NpYdHsAeRuC3WqV1B"    // TODO:隠さなくていい？

// 初回ログイン用の情報
var initial_token: String = ""
var initial_email: String = ""

// Colorクラスで色をHEXで指定できる様に機能を拡張
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// バージョン確認のレスポンス
struct VersionItemResponse: Codable{
    let now_version: String
    let need_version: String
}

struct GetAppVersionResponse: Codable {
    let result_code: String
    let item: VersionItemResponse
}

// ログイン通信のレスポンスデータ
struct LoginItemResponse: Codable{
    let is_tel_verified: String
    let is_user_registered: String
    let is_age_verified: String
}

struct LoginResponse: Codable {
    let result_code: String
    let item: LoginItemResponse
}

// セマンティックを考慮したバージョン比較関数
func compareVersion(_ now: String, _ need: String) -> Int {
    
    let NowVersion = now.split(separator: ".").map { Int($0) ?? 0 }
    let NeedVersion = need.split(separator: ".").map { Int($0) ?? 0 }
    let MyVersion = APP_VERSION.split(separator: ".").map { Int($0) ?? 0 }
    
    // 基本同じだと思うが一応項目数を確認しておく
    let maxLength = max(NowVersion.count, NeedVersion.count,MyVersion.count)
    
    for i in 0..<maxLength {
        // セマンティック毎の値を取得（不足してれば0）
        let NumNeed = i < NeedVersion.count ? NeedVersion[i] : 0
        let NumBase = i < MyVersion.count ? MyVersion[i] : 0
        
        // 超過してればそれはOK
        if NumBase > NumNeed {
            break
        }
        
        // 必要なバージョンを割り込んでいる状態
        if NumNeed > NumBase {
            return -1
        }
    }
    
    for i in 0..<maxLength {
        // セマンティック毎の値を取得（不足してれば0）
        let NumNow = i < NowVersion.count ? NowVersion[i] : 0
        let NumBase = i < MyVersion.count ? MyVersion[i] : 0
        
        // 超過してればそれはOK
        if NumBase > NumNow {
            break
        }
        
        // 新しいバージョンが公開されている状態
        if NumNow > NumBase {
            return 1
        }
    }
    
    return 0    // 同じバージョン(更新が必要ない)の状態
}
