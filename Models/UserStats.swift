// UserStats.swift
// 统计 Codable 模型，按 type 分：viewed/deleted/bytesFreed

import Foundation

/// 用户统计模型
/// 记录用户的浏览、删除行为和空间释放情况
struct UserStats: Codable {
    /// 照片浏览次数
    var photoViewed: Int = 0

    /// 视频浏览次数
    var videoViewed: Int = 0

    /// 已删除的照片数量
    var photoDeleted: Int = 0

    /// 已删除的视频数量
    var videoDeleted: Int = 0

    /// 已删除的截图数量
    var screenshotDeleted: Int = 0

    /// 通过删除照片释放的空间（字节）
    var photoBytesFreed: Int64 = 0

    /// 通过删除视频释放的空间（字节）
    var videoBytesFreed: Int64 = 0

    /// 通过删除截图释放的空间（字节）
    var screenshotBytesFreed: Int64 = 0

    // MARK: - 计算属性

    /// 总浏览次数
    var totalViewed: Int {
        photoViewed + videoViewed
    }

    /// 总删除数量
    var totalDeleted: Int {
        photoDeleted + videoDeleted + screenshotDeleted
    }

    /// 总释放空间（字节）
    var bytesFreed: Int64 {
        photoBytesFreed + videoBytesFreed + screenshotBytesFreed
    }

    /// 格式化释放空间
    var formattedBytesFreed: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytesFreed)
    }

    // MARK: - 操作方法

    /// 增加浏览次数
    /// - Parameter isVideo: 是否为视频
    mutating func addViewed(isVideo: Bool) {
        if isVideo {
            videoViewed += 1
        } else {
            photoViewed += 1
        }
    }

    /// 增加删除记录
    /// - Parameters:
    ///   - mediaType: 媒体类型
    ///   - bytes: 释放的字节数
    mutating func addDeleted(mediaType: MediaType, bytes: Int64) {
        switch mediaType {
        case .photo:
            photoDeleted += 1
            photoBytesFreed += bytes
        case .video:
            videoDeleted += 1
            videoBytesFreed += bytes
        case .screenshot:
            screenshotDeleted += 1
            screenshotBytesFreed += bytes
        default:
            // 自拍、实况照片、动图归入照片统计
            photoDeleted += 1
            photoBytesFreed += bytes
        }
    }

    /// 重置浏览历史（保留删除统计）
    mutating func resetBrowseHistory() {
        photoViewed = 0
        videoViewed = 0
    }

    /// 重置所有统计数据
    mutating func resetAll() {
        photoViewed = 0
        videoViewed = 0
        photoDeleted = 0
        videoDeleted = 0
        screenshotDeleted = 0
        photoBytesFreed = 0
        videoBytesFreed = 0
        screenshotBytesFreed = 0
    }

    // MARK: - 持久化

    private static let userDefaultsKey = "UserStats"

    /// 从 UserDefaults 加载统计
    static func load() -> UserStats {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let stats = try? JSONDecoder().decode(UserStats.self, from: data) else {
            return UserStats()
        }
        return stats
    }

    /// 保存统计到 UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: UserStats.userDefaultsKey)
        }
    }
}