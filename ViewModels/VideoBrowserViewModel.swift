// VideoBrowserViewModel.swift
// 视频页状态中枢：随机视频 / AVPlayer 生命周期管理

import SwiftUI
import Photos
import AVKit
import AVFoundation
import Combine

@MainActor
final class VideoBrowserViewModel: ObservableObject {

    // MARK: - Published 属性

    @Published var currentAsset: PHAsset?
    @Published var player: AVPlayer?
    @Published var isLoading: Bool = false
    @Published var duration: TimeInterval = 0
    @Published private(set) var viewedIdentifiers: Set<String> = []
    @Published private(set) var favoritedIdentifiers: Set<String> = []

    // MARK: - 配置

    var batchSize: Int {
        didSet {
            UserDefaults.standard.set(batchSize, forKey: "quliu.videoBatchSize")
        }
    }

    // MARK: - 私有

    private var randomPool: [PHAsset] = []
    private var playerItem: AVPlayerItem?
    private let photoService = PhotoLibraryService.shared
    private let statsService = StatisticsService.shared

    // MARK: - 初始化

    init() {
        self.batchSize = UserDefaults.standard.integer(forKey: "quliu.videoBatchSize")
        if batchSize == 0 { batchSize = 20 }
        self.viewedIdentifiers = statsService.getViewedIdentifiers()
    }

    // MARK: - 核心方法

    /// 初始化洗牌池
    func shuffle(count: Int) {
        isLoading = true
        Task {
            let assets = await photoService.fetchAssets(mediaType: .video, limit: count)
            await MainActor.run {
                randomPool.append(contentsOf: assets)
                randomPool.shuffle()
                randomPool.removeAll { self.viewedIdentifiers.contains($0.localIdentifier) }
                self.isLoading = false
                // 补池后自动显示第一张
                if self.currentAsset == nil && !self.randomPool.isEmpty {
                    self.currentAsset = self.randomPool.removeFirst()
                    self.loadCurrentAssetAVAsset()
                }
            }
        }
    }

    /// 加载随机视频
    func loadRandomVideo() {
        if randomPool.isEmpty {
            shuffle(count: batchSize * 2)
            return
        }
        currentAsset = randomPool.removeFirst()
        loadCurrentAssetAVAsset()
    }

    /// 从当前 asset 加载视频 URL 并设置播放器
    func loadCurrentAssetAVAsset() {
        guard let asset = currentAsset else { return }
        Task {
            let url = await MediaLoader.shared.loadVideoURL(asset)
            await MainActor.run {
                self.setupPlayer(url: url)
            }
        }
    }

    /// 绑定 AVPlayer 准备播放
    func setupPlayer(url: URL?) {
        cleanup()

        guard let url = url else { return }
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        playerItem = item
        player = AVPlayer(playerItem: item)

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self,
                      let duration = self.playerItem?.duration,
                      duration.isNumeric else { return }
                self.duration = CMTimeGetSeconds(duration)
            }
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func seek(to time: CMTime) {
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /// 标记为已展示
    func markAsViewed(_ asset: PHAsset) {
        let inserted = viewedIdentifiers.insert(asset.localIdentifier).inserted
        guard inserted else { return }
        statsService.addViewedIdentifier(asset.localIdentifier)
        statsService.addViewed(isVideo: true)
    }

    /// 删除当前视频
    func deleteCurrentAsset() async throws {
        guard let asset = currentAsset else { return }
        markAsViewed(asset)

        let bytes = Int64(asset.pixelWidth * asset.pixelHeight * 4)

        try await photoService.deleteAssets([asset])
        statsService.addDeleted(mediaType: .video, bytes: bytes)

        await MainActor.run {
            cleanup()
            currentAsset = nil
            loadRandomVideo()
        }
    }

    /// 切换收藏
    func toggleFavorite() {
        guard let asset = currentAsset else { return }
        let id = asset.localIdentifier
        if favoritedIdentifiers.contains(id) {
            favoritedIdentifiers.remove(id)
        } else {
            favoritedIdentifiers.insert(id)
        }
    }

    /// 加载下一条
    func loadNextInBatch() {
        if let asset = currentAsset {
            markAsViewed(asset)
        }
        loadRandomVideo()
    }

    /// 退出时调用
    func cleanup() {
        player?.pause()
        player = nil
        playerItem = nil
        duration = 0
    }
}
