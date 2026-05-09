// MediaBrowserViewModel.swift
// 首页媒体浏览状态中枢：随机队列 / 当前媒体 / 快捷操作

import SwiftUI
import Photos
import Combine

@MainActor
final class MediaBrowserViewModel: ObservableObject {

    // MARK: - Published 属性

    @Published var currentAsset: PHAsset?
    @Published var isLoading: Bool = false
    @Published var selectedCategory: MediaType? = nil {
        didSet {
            guard oldValue != selectedCategory else { return }
            currentAsset = nil
            randomPool.removeAll()
            shuffle(count: batchSize)
        }
    }
    @Published private(set) var viewedIdentifiers: Set<String> = []
    @Published private(set) var favoritedIdentifiers: Set<String> = []

    // MARK: - 配置

    var batchSize: Int {
        didSet {
            UserDefaults.standard.set(batchSize, forKey: "quliu.batchSize")
        }
    }

    // MARK: - 私有

    private var randomPool: [PHAsset] = []  // 随机候选池
    private let photoService = PhotoLibraryService.shared
    private let statsService = StatisticsService.shared

    // MARK: - 初始化

    init() {
        self.batchSize = UserDefaults.standard.integer(forKey: "quliu.batchSize")
        if batchSize == 0 { batchSize = 20 }
        self.viewedIdentifiers = statsService.getViewedIdentifiers()
    }

    // MARK: - 核心方法

    /// 初始化洗牌池
    func shuffle(count: Int) {
        isLoading = true
        Task {
            let assets = await photoService.fetchAssets(mediaType: selectedCategory, limit: count)
            await MainActor.run {
                randomPool.append(contentsOf: assets)
                randomPool.shuffle()
                // 移除已展示过的
                randomPool.removeAll { self.viewedIdentifiers.contains($0.localIdentifier) }
                self.isLoading = false
                // 补池后自动显示第一张
                if self.currentAsset == nil && !self.randomPool.isEmpty {
                    self.currentAsset = self.randomPool.removeFirst()
                }
            }
        }
    }

    /// 从池中取出下一个资产
    func loadRandomAsset() {
        if randomPool.isEmpty {
            shuffle(count: batchSize * 2)
            return
        }
        currentAsset = randomPool.removeFirst()
    }

    /// 标记资产为已展示
    func markAsViewed(_ asset: PHAsset) {
        let inserted = viewedIdentifiers.insert(asset.localIdentifier).inserted
        guard inserted else { return }
        statsService.addViewedIdentifier(asset.localIdentifier)
        let isVideo = asset.mediaType == .video
        statsService.addViewed(isVideo: isVideo)
    }

    /// 删除当前媒体，执行系统删除 + 统计更新 + 自动刷下一个
    func deleteCurrentAsset() async throws {
        guard let asset = currentAsset else { return }
        markAsViewed(asset)

        // 估算字节数（基于分辨率）
        let bytes = Int64(asset.pixelWidth * asset.pixelHeight * 4)

        try await photoService.deleteAssets([asset])
        statsService.addDeleted(mediaType: MediaType(asset: asset), bytes: bytes)

        await MainActor.run {
            currentAsset = nil
            loadRandomAsset()
        }
    }

    /// 切换收藏状态
    func toggleFavorite() {
        guard let asset = currentAsset else { return }
        let id = asset.localIdentifier
        if favoritedIdentifiers.contains(id) {
            favoritedIdentifiers.remove(id)
        } else {
            favoritedIdentifiers.insert(id)
        }
    }

    /// 连续加载 batchSize 条
    func loadNextInBatch() {
        if let asset = currentAsset {
            markAsViewed(asset)
        }
        loadRandomAsset()
    }

    /// 是否还能继续加载
    var canLoadNext: Bool {
        !randomPool.isEmpty || currentAsset != nil
    }

    /// 重置已浏览历史（退出时调用）
    func resetViewedHistory() {
        viewedIdentifiers.removeAll()
        randomPool.removeAll()
    }
}
