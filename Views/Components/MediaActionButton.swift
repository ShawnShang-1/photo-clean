// MediaActionButton.swift
// 单个圆形媒体操作按钮，支持收藏/分享/删除/撤销
import SwiftUI

struct MediaActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    let isDestructive: Bool

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Circle()
                    .fill(isDestructive ? Color.red.opacity(0.85) : Color.white.opacity(0.25))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(isDestructive ? .white : .white)
                    )
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        MediaActionButton(icon: "heart.fill", label: "收藏", action: {}, isDestructive: false)
        MediaActionButton(icon: "trash.fill", label: "删除", action: {}, isDestructive: true)
    }
    .padding()
    .background(Color.black)
}
