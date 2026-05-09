//
//  ProgressBarView.swift
//  渐变进度条，展示存储空间清理进度
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("腾出空间")
                .font(.subheadline)
                .foregroundColor(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    Capsule()
                        .fill(Color(.systemGray5))

                    // 渐变前景
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * clampedProgress)
                        .animation(.easeInOut, value: clampedProgress)
                }
            }
            .frame(height: 12)
        }
    }
}
