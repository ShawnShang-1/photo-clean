// StatisticsService.swift
// UserDefaults 统计 + 浏览记录集合 + resetBrowseHistory()
// 使用 Models/UserStats.swift 作为唯一统计模型

import Foundation

/// 统计服务：UserDefaults 持久化浏览记录和删除统计
/// 注意：使用 Models/UserStats.swift 作为唯一 UserStats 定义
final class StatisticsService: @unchecked Sendable {

    static let shared = StatisticsService()

    private init() {}

    private let defaults = UserDefaults.standard
    private let statsKey = "quliu.stats"
    private let viewedIdentifiersKey = "quliu.viewedIdentifiers"

    // MARK: - 统计读写

    /// 加载统计
    func loadStats() -> UserStats {
        UserStats.load()
    }

    // MARK: - 浏览记录

    /// 增加一次浏览
    func addViewed(isVideo: Bool) {
        var stats = loadStats()
        stats.addViewed(isVideo: isVideo)
        stats.save()
    }

    /// 获取已浏览标识符集合
    func getViewedIdentifiers() -> Set<String> {
        guard let array = defaults.stringArray(forKey: viewedIdentifiersKey) else {
            return []
        }
        return Set(array)
    }

    /// 添加已浏览标识符
    func addViewedIdentifier(_ id: String) {
        var array = defaults.stringArray(forKey: viewedIdentifiersKey) ?? []
        if !array.contains(id) {
            array.append(id)
            defaults.set(array, forKey: viewedIdentifiersKey)
        }
    }

    /// 重置浏览历史（只清浏览记录，不清删除统计）
    func resetBrowseHistory() {
        defaults.removeObject(forKey: viewedIdentifiersKey)
    }

    // MARK: - 删除统计

    /// 记录一次删除
    func addDeleted(mediaType: MediaType, bytes: Int64) {
        var stats = loadStats()
        stats.addDeleted(mediaType: mediaType, bytes: bytes)
        stats.save()
    }
}
