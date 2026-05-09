//
//  StatsView.swift
//  统计主页，包含照片/截屏/视频的清理统计
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var vm: StatsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 总计腾出空间
                VStack(spacing: 8) {
                    Text("总计腾出空间")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(vm.formattedBytesFreed)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // 中间：3 个统计卡片
                HStack(spacing: 12) {
                    StatCardView(
                        title: "照片",
                        icon: "photo",
                        viewed: vm.photoViewed,
                        deleted: vm.photoDeleted,
                        bytesFreed: vm.photoBytesFreed
                    )

                    StatCardView(
                        title: "截屏",
                        icon: "camera.viewfinder",
                        viewed: vm.screenshotViewed,
                        deleted: vm.screenshotDeleted,
                        bytesFreed: vm.screenshotBytesFreed
                    )

                    StatCardView(
                        title: "视频",
                        icon: "video",
                        viewed: vm.videoViewed,
                        deleted: vm.videoDeleted,
                        bytesFreed: vm.videoBytesFreed
                    )
                }

                // 底部：腾出空间进度条 + 重置按钮
                VStack(spacing: 16) {
                    ProgressBarView(progress: vm.storageProgress)

                    Button(action: {
                        vm.resetBrowseHistory()
                    }) {
                        Text("重置浏览历史")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .task { vm.loadStats() }
    }
}
