// MediaLoader.swift
// actor 封装：图片/视频加载，withCheckedContinuation 包装回调

import Photos
import UIKit
@preconcurrency import AVFoundation

/// 媒体加载器（actor）：负责图片和视频的资源加载
actor MediaLoader {

    static let shared = MediaLoader()

    private init() {}

    /// 加载缩略图
    func loadThumbnail(_ asset: PHAsset, maxDimension: CGFloat) async -> UIImage? {
        let clampedSize = CGSize(width: min(500, maxDimension),
                                  height: min(500, maxDimension))

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: clampedSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                Task { continuation.resume(returning: image) }
            }
        }
    }

    /// 加载全尺寸图片
    func loadFullImage(_ asset: PHAsset, maxDimension: CGFloat) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true

        let targetSize = CGSize(width: maxDimension, height: maxDimension)

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                Task { continuation.resume(returning: image) }
            }
        }
    }

    /// 加载 AVAsset（用于视频播放）
    func loadAVAsset(_ asset: PHAsset) async -> AVAsset? {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestAVAsset(
                forVideo: asset,
                options: options
            ) { avAsset, _, _ in
                Task { continuation.resume(returning: avAsset) }
            }
        }
    }
}
