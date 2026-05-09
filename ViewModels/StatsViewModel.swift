// StatsViewModel.swift
// 统计页状态中枢：聚合三组统计 + 进度百分比

import SwiftUI
import Photos
import Combine

@MainActor
final class StatsViewModel: ObservableObject {

    // MARK: - Published 属性

    @Published private(set) var stats: UserStats = UserStats()
    @Published var photoProgress: Double = 0
    @Published var screenshotProgress: Double = 0
    @Published var videoProgress: Double = 0
    @Published private(set) var storageProgress: Double = 0

    // MARK: - 私有

    private let statsService = StatisticsService.shared

    // MARK: - 核心方法

    /// 从 StatisticsService 加载统计数据
    func loadStats() {
        stats = statsService.loadStats()
        refreshProgress()
    }

    /// 重置浏览历史
    func resetBrowseHistory() {
        statsService.resetBrowseHistory()
        loadStats()
    }

    /// 重新计算进度百分比
    /// 进度 = 已删除数 / (已删除数 + 剩余可浏览数)
    /// 由于 UserStats 没有 remaining，用 "删除数 / 浏览数" 近似（用户在浏览过的照片里删了多少比例）
    private func refreshProgress() {
        photoProgress = ratio(deleted: stats.photoDeleted, viewed: stats.photoViewed)
        // 截图没有独立 viewed，用 photoViewed 粗估
        screenshotProgress = ratio(deleted: stats.screenshotDeleted, viewed: stats.photoViewed)
        videoProgress = ratio(deleted: stats.videoDeleted, viewed: stats.videoViewed)

        let estimatedTotalBytes = Int64(stats.totalViewed) * 3 * 1024 * 1024
        storageProgress = estimatedTotalBytes > 0
            ? min(Double(stats.bytesFreed) / Double(estimatedTotalBytes), 1.0)
            : 0
    }

    private func ratio(deleted: Int, viewed: Int) -> Double {
        guard viewed > 0 else { return 0 }
        return min(Double(deleted) / Double(viewed), 1.0)
    }

    // MARK: - 便捷访问

    /// 总释放空间（字节）
    var totalBytesFreed: Int64 { stats.bytesFreed }

    /// 格式化释放空间
    var formattedBytesFreed: String { stats.formattedBytesFreed }

    // MARK: - 暴露给 StatsView 的计算属性

    var photoViewed: Int { stats.photoViewed }
    var photoDeleted: Int { stats.photoDeleted }
    var photoBytesFreed: Int64 { stats.photoBytesFreed }

    // 注意：UserStats 没有独立的 screenshotViewed，用 photoViewed 代替显示
    var screenshotViewed: Int { 0 }
    var screenshotDeleted: Int { stats.screenshotDeleted }
    var screenshotBytesFreed: Int64 { stats.screenshotBytesFreed }

    var videoViewed: Int { stats.videoViewed }
    var videoDeleted: Int { stats.videoDeleted }
    var videoBytesFreed: Int64 { stats.videoBytesFreed }
}
