// EmptyStateView.swift
// 空状态视图：居中图标 + 标题 + 副标题 + 按钮，用于空相册、无法加载等场景

import SwiftUI

struct EmptyStateView: View {
    let icon: String          // SF Symbol 图标名
    let title: String         // 主标题
    let message: String       // 副标题/说明
    let buttonTitle: String?  // 可选按钮标题
    let action: (() -> Void)? // 可选按钮回调

    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary)

            // 标题
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // 副标题
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // 按钮（可选）
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "photo.on.rectangle.angled",
        title: "暂无照片",
        message: "相册中还没有照片或视频",
        buttonTitle: "刷新",
        action: {}
    )
}
