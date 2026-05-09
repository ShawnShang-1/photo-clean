//
//  StatCardView.swift
//  单个统计卡片，展示类型、查看/删除数量、清理空间
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let icon: String
    let viewed: Int
    let deleted: Int
    let bytesFreed: Int64

    // 字节数格式化
    private var freedText: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytesFreed) + " freed"
    }

    var body: some View {
        VStack(spacing: 8) {
            // 顶部：图标 + 标题
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.headline)

            // 中间：查看/删除数量
            VStack(spacing: 4) {
                Text("\(viewed) 查看")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(deleted) 删除")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            // 底部：清理空间字节数
            Text(freedText)
                .font(.caption2)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
