// MediaType.swift
// 媒体分类枚举：photo/screenshot/selfie/livePhoto/animated/video

import Foundation
import Photos

/// 媒体类型枚举，映射 PHAsset 的 mediaType 和 mediaSubtypes
enum MediaType: String, CaseIterable {
    case photo       // 普通照片
    case screenshot  // 截图
    case selfie      // 自拍
    case livePhoto   // 实况照片
    case animated    // 动图（GIF/WebP）
    case video       // 视频

    /// 友好的中文名称
    var displayName: String {
        switch self {
        case .photo:      return "照片"
        case .screenshot: return "截图"
        case .selfie:     return "自拍"
        case .livePhoto:  return "实况照片"
        case .animated:   return "动图"
        case .video:      return "视频"
        }
    }

    /// 从 PHAsset 推断媒体类型
    /// - Parameter asset: PHAsset 实例
    /// - Returns: MediaType 枚举值
    init(asset: PHAsset) {
        // 优先检测视频
        if asset.mediaType == .video {
            self = .video
            return
        }

        // 检测实况照片
        if asset.mediaSubtypes.contains(.photoLive) {
            self = .livePhoto
            return
        }

        // 检测截图
        if asset.mediaSubtypes.contains(.photoScreenshot) {
            self = .screenshot
            return
        }

        // 检测自拍（前置摄像头拍摄的照片）
        if asset.mediaSubtypes.contains(.photoDepthEffect) || asset.isFavorite {
            // 自拍通过位置信息和角度进一步判断，此处简化处理
            self = .selfie
            return
        }

        // 默认普通照片
        self = .photo
    }
}