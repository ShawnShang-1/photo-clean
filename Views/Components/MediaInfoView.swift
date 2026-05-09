// MediaInfoView.swift
// 媒体详情 fullScreenCover：相对时间 + 绝对时间 + EXIF + 文件信息 + 返回/相册按钮

import SwiftUI
import Photos

/// 媒体详情视图（fullScreenCover 呈现）
/// - 参数：
///   - asset: PHAsset 实例
///   - metadata: MediaMetadata?（可选，EXIF 等详细信息）
struct MediaInfoView: View {
    let asset: PHAsset
    var metadata: MediaMetadata? = nil

    @State private var loadedMetadata: MediaMetadata? = nil
    @Environment(\.dismiss) private var dismiss

    // MARK: - 时间

    private var relativeTimeString: String {
        asset.creationDate?.relativeString ?? "--"
    }

    private var absoluteTimeString: String {
        asset.creationDate?.absoluteString ?? "--"
    }

    /// 文件名（基于 localIdentifier）
    private var fileNameString: String {
        asset.localIdentifier
    }

    /// 分辨率字符串：4032 × 3024
    private var resolutionString: String {
        "\(asset.pixelWidth) × \(asset.pixelHeight)"
    }

    /// 格式化文件大小
    private var fileSizeString: String {
        if let bytes = loadedMetadata?.fileSizeBytes, bytes > 0 {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: bytes)
        }
        // 估算大小
        let pixelCount = Int64(asset.pixelWidth * asset.pixelHeight)
        let estimatedBytes = asset.mediaType == .video
            ? Int64(asset.duration * 1_000_000)
            : pixelCount * 3
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return "估算: \(formatter.string(fromByteCount: estimatedBytes))"
    }

    /// 视频时长字符串（如 0:45）
    private var durationString: String? {
        guard asset.mediaType == .video, asset.duration > 0 else { return nil }
        let minutes = Int(asset.duration) / 60
        let seconds = Int(asset.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - EXIF 格式化

    /// 光圈字符串，如 f/1.8
    private var apertureString: String? {
        guard let aperture = loadedMetadata?.aperture else { return nil }
        return String(format: "f/%.1f", aperture)
    }

    /// 快门速度字符串，如 1/120s
    private var shutterSpeedString: String? {
        guard let shutter = loadedMetadata?.shutterSpeed else { return nil }
        if shutter >= 1 {
            return String(format: "%.1fs", shutter)
        } else {
            let denominator = Int(round(1.0 / shutter))
            return "1/\(denominator)s"
        }
    }

    /// ISO 字符串
    private var isoString: String? {
        guard let iso = loadedMetadata?.iso else { return nil }
        return "ISO \(iso)"
    }

    /// 焦距字符串，如 26mm
    private var focalLengthString: String? {
        guard let focal = loadedMetadata?.focalLength else { return nil }
        return String(format: "%.0fmm", focal)
    }

    /// 是否有任何 EXIF 数据
    private var hasExifData: Bool {
        apertureString != nil || shutterSpeedString != nil || isoString != nil || focalLengthString != nil
    }

    // MARK: - 标签行视图

    /// 单行 HStack + Label 布局
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 1. 时间
                VStack(alignment: .leading, spacing: 8) {
                    Text("时间")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 4) {
                        infoRow(title: "相对时间", value: relativeTimeString)
                        infoRow(title: "绝对时间", value: absoluteTimeString)
                    }
                }

                Divider()

                // 2. 设备
                if loadedMetadata?.deviceModel != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("设备")
                            .font(.headline)
                        infoRow(title: "型号", value: loadedMetadata?.deviceModel ?? "--")
                    }
                    Divider()
                }

                // 3. EXIF
                if hasExifData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXIF")
                            .font(.headline)
                        if let aperture = apertureString {
                            infoRow(title: "光圈", value: aperture)
                        }
                        if let shutter = shutterSpeedString {
                            infoRow(title: "快门", value: shutter)
                        }
                        if let iso = isoString {
                            infoRow(title: "ISO", value: iso)
                        }
                        if let focal = focalLengthString {
                            infoRow(title: "焦距", value: focal)
                        }
                    }
                    Divider()
                }

                // 4. 文件信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("文件信息")
                        .font(.headline)
                    infoRow(title: "文件名", value: fileNameString)
                    infoRow(title: "分辨率", value: resolutionString)
                    infoRow(title: "大小", value: fileSizeString)
                    if let duration = durationString {
                        infoRow(title: "视频时长", value: duration)
                    }
                }
            }
            .padding()
        }
        .task {
            loadedMetadata = await MediaMetadataService().loadMetadata(for: asset)
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .topLeading) {
            // 关闭按钮，左上角
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
