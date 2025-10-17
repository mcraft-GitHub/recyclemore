//
//  BrightnessView.swift
//  recyclemore
//
//  Created by 貸し出し用 on 2025/10/08.
//

import SwiftUI

struct BrightnessView: View {
    @State private var isBright = false
    @State private var timer: Timer?
    @State private var original: CGFloat = 0.0
    
    var body: some View {
        Text("輝度変更テスト中")
            .font(.title)
            .padding()
            .onAppear{
                original = UIScreen.main.brightness
                //Timerスタート
                timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {
                    _ in
                    isBright.toggle()
                    print("切り替え")
                    UIScreen.main.brightness = isBright ? 1.0 : 0.2
                    
                    print(UIScreen.main.brightness)
                }
            }
            .onDisappear {
            // タイマーを停止
            timer?.invalidate()
            timer = nil
            // 元の値を入れて戻す
            UIScreen.main.brightness = original
        }
    }
}

#Preview {
    BrightnessView()
}
