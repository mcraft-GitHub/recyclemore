//
//  LoadingView.swift
//  recyclemore
//
//  Created by MC原田 on 2025/10/16.
//

import SwiftUI

// 通信中の表示　ぐ〜るぐる
struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.white.opacity(0.8)
                .edgesIgnoringSafeArea(.all)

            Image("Loading")
                .resizable()
                .frame(width: 40, height: 40)
                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
}

#Preview {
    LoadingView()
}
