//
//  PermissionGuideView.swift
//  全屏权限引导视图
//

import SwiftUI
import Photos

struct PermissionGuideView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // 锁图标
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            // 标题
            Text("需要照片访问权限")
                .font(.title2)
                .fontWeight(.bold)

            // 说明
            Text("去留需要访问您的照片来帮您整理回忆")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // 主按钮
            Button(action: {
                requestAuthorization()
            }) {
                Text("打开照片权限")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            // 次按钮
            Button(action: {
                isPresented = false
            }) {
                Text("稍后再说")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 48)
        }
    }

    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                DispatchQueue.main.async {
                    isPresented = false
                }
            }
        }
    }
}
