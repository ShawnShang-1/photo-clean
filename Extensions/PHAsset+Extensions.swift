// PHAsset+Extensions.swift
// PHAsset 分类判定：截图、自拍、实况、动图、视频

import Photos
import UniformTypeIdentifiers

extension PHAsset {
    /// 是否为截图
    var isScreenshot: Bool {
        mediaSubtypes.contains(.photoScreenshot)
    }

    /// 是否为自拍（前置摄像头拍摄或具有深度效果）
    var isSelfie: Bool {
        mediaSubtypes.contains(.photoDepthEffect)
    }

    /// 是否为实况照片
    var isLive: Bool {
        mediaSubtypes.contains(.photoLive)
    }

    /// 是否为动图（如 GIF）
    var isAnimated: Bool {
        let resources = PHAssetResource.assetResources(for: self)
        guard let utType = resources.first?.value(forKey: "uniformTypeIdentifier") as? String else {
            return false
        }
        return utType.contains("gif") || utType.contains("GIF")
    }

    /// 是否为视频
    var isVideo: Bool {
        mediaType == .video
    }
}