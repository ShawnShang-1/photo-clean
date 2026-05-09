// PhotoLibraryService.swift
// PhotoKit 封装：权限请求、按分类 fetch、performChanges 删除

import Photos
import UIKit

/// 照片库服务：封装 PhotoKit 权限与资源操作
final class PhotoLibraryService: @unchecked Sendable {

    static let shared = PhotoLibraryService()

    private init() {}

    /// 请求照片库权限
    func requestAuthorization() async -> AuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch newStatus {
            case .authorized:
                return .authorized
            case .limited:
                return .limited
            case .denied, .restricted:
                return .denied
            default:
                return .denied
            }
        @unknown default:
            return .denied
        }
    }

    /// 按类型查询资源
    /// - Parameters:
    ///   - mediaType: 媒体类型，nil 表示全部
    ///   - limit: 可选数量限制，nil 表示全部
    /// - Returns: 匹配的 PHAsset 数组
    func fetchAssets(mediaType: MediaType?, limit: Int?) async -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        if let mediaType = mediaType {
            switch mediaType {
            case .photo, .selfie, .livePhoto, .animated:
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            case .screenshot:
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            case .video:
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            }
        }
        // mediaType == nil 表示全部，不加 predicate

        if let limit = limit {
            options.fetchLimit = limit
        }

        let result = PHAsset.fetchAssets(with: options)
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    /// 删除资源（使用 performChanges 批量删除）
    func deleteAssets(_ assets: [PHAsset]) async throws {
        guard !assets.isEmpty else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if !success {
                        continuation.resume(throwing: NSError(domain: "PhotoLibraryService", code: -1,
                                                             userInfo: [NSLocalizedDescriptionKey: "删除失败"]))
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }

    /// 获取 Limited Library Picker 对应的 PhotoLibrary 实例
    func getLimitedLibraryPicker() -> PHPhotoLibrary {
        return PHPhotoLibrary.shared()
    }
}
