//  GlassCardView.swift
//  毛玻璃卡片：背景模糊 + 前景主媒体叠加层

import SwiftUI
import Photos

struct GlassCardView: View {
    let asset: PHAsset?
    var onTap: (() -> Void)? = nil

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            // 背景层：高斯模糊 + 毛玻璃材质
            backgroundLayer

            // 前景层：主媒体缩略图
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        onTap?()
                    }
            }
        }
        .onChange(of: asset?.localIdentifier) { _, _ in
            loadThumbnail()
        }
        .onAppear {
            loadThumbnail()
        }
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let thumbnail = thumbnail {
            let blurredImage = Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .blur(radius: 30)

            blurredImage
                .overlay {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
        }
    }

    private func loadThumbnail() {
        guard let asset = asset else {
            thumbnail = nil
            return
        }
        let screenScale = UIScreen.main.scale
        let maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * screenScale * 2
        Task {
            let image = await MediaLoader.shared.loadThumbnail(asset, maxDimension: maxDimension)
            await MainActor.run {
                self.thumbnail = image
            }
        }
    }
}