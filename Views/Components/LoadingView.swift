// LoadingView.swift
// 通用加载 spinner，支持可选文案和半透明背景遮罩

import SwiftUI

struct LoadingView: View {
    // 可选加载文案，默认为"加载中..."
    var message: String? = "加载中..."

    var body: some View {
        ZStack {
            // 半透明背景遮罩
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            // 居中内容
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .background(Color(.systemGray5).opacity(0.9))
            .cornerRadius(12)
        }
    }
}

#Preview {
    LoadingView()
}
