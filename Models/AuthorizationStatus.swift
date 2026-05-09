// AuthorizationStatus.swift
// App 内部权限状态枚举，映射 PHAuthorizationStatus

import Foundation
import Photos

/// App 内部权限状态枚举
/// 映射 Photos 框架的 PHAuthorizationStatus
enum AuthorizationStatus: String {
    case notDetermined  // 用户尚未做出选择
    case authorized     // 已授权（完整访问）
    case limited        // 仅限部分照片访问（iOS 14+ Limited 模式）
    case denied         // 被拒绝或受限

    /// 从系统 PHAuthorizationStatus 映射到内部枚举
    /// - Parameter status: 系统权限状态
    init(phStatus: PHAuthorizationStatus) {
        switch phStatus {
        case .notDetermined:
            self = .notDetermined
        case .restricted, .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .limited:
            self = .limited
        @unknown default:
            self = .denied
        }
    }

    /// 转换为系统 PHAuthorizationStatus
    var toPHStatus: PHAuthorizationStatus {
        switch self {
        case .notDetermined: return .notDetermined
        case .authorized:    return .authorized
        case .limited:       return .limited
        case .denied:        return .denied
        }
    }

    /// 友好的中文描述
    var displayName: String {
        switch self {
        case .notDetermined: return "未授权"
        case .authorized:     return "已授权"
        case .limited:        return "部分授权"
        case .denied:         return "拒绝访问"
        }
    }

    /// 是否有权限访问照片库
    var hasAccess: Bool {
        switch self {
        case .authorized, .limited:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}