//
//  RootView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/12/04.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {

    let assetName: String   // Assets の JSON 名

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        // ① Assets から JSON データを取り出す
        guard let dataAsset = NSDataAsset(name: assetName) else {
            print("見つからない: \(assetName)")
            return view
        }

        // ② JSON を Animation に変換
        guard let animation = try? LottieAnimation.from(data: dataAsset.data) else {
            print("JSONの変換に失敗")
            return view
        }

        // ③ AnimationView 作成
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = .loop
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
