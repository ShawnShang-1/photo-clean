// MediaMetadataService.swift
// EXIF 读取：光圈/快门/ISO/焦距/设备/分辨率/大小

import Photos
import ImageIO
import UIKit

/// 媒体元数据结构体
struct MediaMetadata {
    var aperture: Double?           // 光圈 f 值
    var shutterSpeed: Double?      // 快门速度（秒）
    var iso: Int?                   // ISO 值
    var focalLength: Double?        // 焦距（mm）
    var deviceModel: String?        // 设备型号
    var pixelWidth: Int?           // 像素宽度
    var pixelHeight: Int?           // 像素高度
    var fileSizeBytes: Int64?       // 文件大小
}

/// 媒体元数据服务：读取 EXIF 等媒体属性
final class MediaMetadataService {

    /// 加载指定资源的元数据
    /// - Parameter asset: PHAsset
    /// - Returns: MediaMetadata 实例，读取不到字段时为 nil
    func loadMetadata(for asset: PHAsset) async -> MediaMetadata? {
        var metadata = MediaMetadata()

        // 用 async/await 包装 requestImageDataAndOrientation
        let imageData: Data? = await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }

        guard let data = imageData else { return nil }

        // 使用 CGImageSource 解析
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }

        // 分辨率
        metadata.pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int
        metadata.pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int

        // 文件大小
        metadata.fileSizeBytes = Int64(data.count)

        // EXIF 数据
        if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            if let aperture = exif[kCGImagePropertyExifFNumber as String] as? Double {
                metadata.aperture = aperture
            }
            if let exposure = exif[kCGImagePropertyExifExposureTime as String] as? Double {
                metadata.shutterSpeed = exposure
            }
            if let isoArray = exif[kCGImagePropertyExifISOSpeedRatings as String] as? [Int], let iso = isoArray.first {
                metadata.iso = iso
            }
            if let focal = exif[kCGImagePropertyExifFocalLength as String] as? Double {
                metadata.focalLength = focal
            }
        }

        // 设备型号
        if let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            metadata.deviceModel = tiff[kCGImagePropertyTIFFModel as String] as? String
        }

        return metadata
    }
}