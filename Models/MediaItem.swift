// MediaItem.swift
// PHAsset 的 ViewModel 映射，包含 localIdentifier/mediaType/size/createdAt/duration/width/height

import Foundation
import Photos

/// 媒体条目视图模型
/// 封装 PHAsset 的关键信息，提供便捷的计算属性
struct MediaItem: Identifiable, Hashable {
    var id: String { localIdentifier }

    let localIdentifier: String
    let mediaType: MediaType
    let pixelWidth: Int
    let pixelHeight: Int
    let creationDate: Date?
    let duration: TimeInterval       // 视频时长，仅对视频有效
    let fileSizeBytes: Int64          // 估算的文件大小

    // MARK: - 便捷计算属性

    /// 是否为视频
    var isVideo: Bool {
        mediaType == .video
    }

    /// 是否为照片（包括普通照片、截图、自拍、实况照片、动图）
    var isPhoto: Bool {
        !isVideo
    }

    /// 分辨率描述
    var resolution: String {
        "\(pixelWidth) × \(pixelHeight)"
    }

    /// 宽高比
    var aspectRatio: Double {
        guard pixelHeight > 0 else { return 1.0 }
        return Double(pixelWidth) / Double(pixelHeight)
    }

    /// 格式化时长（仅视频）
    var formattedDuration: String? {
        guard isVideo else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 格式化文件大小
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSizeBytes)
    }

    // MARK: - 构造器

    /// 从 PHAsset 构造 MediaItem
    /// - Parameter asset: PHAsset 实例
    init(asset: PHAsset) {
        self.localIdentifier = asset.localIdentifier
        self.mediaType = MediaType(asset: asset)
        self.pixelWidth = asset.pixelWidth
        self.pixelHeight = asset.pixelHeight
        self.creationDate = asset.creationDate
        self.duration = asset.duration

        // 估算文件大小：基于分辨率和媒体类型
        // 照片按每像素 3 字节（JPEG）估算，视频按每秒 1MB 估算
        let pixelCount = Int64(pixelWidth * pixelHeight)
        if asset.mediaType == .video {
            self.fileSizeBytes = Int64(asset.duration * 1_000_000) // 粗略估算
        } else {
            self.fileSizeBytes = pixelCount * 3
        }
    }

    /// 完全初始化构造器（供测试和预览用）
    init(
        localIdentifier: String,
        mediaType: MediaType,
        pixelWidth: Int,
        pixelHeight: Int,
        creationDate: Date?,
        duration: TimeInterval,
        fileSizeBytes: Int64
    ) {
        self.localIdentifier = localIdentifier
        self.mediaType = mediaType
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.creationDate = creationDate
        self.duration = duration
        self.fileSizeBytes = fileSizeBytes
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(localIdentifier)
    }

    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.localIdentifier == rhs.localIdentifier
    }
}