// VideoBrowserView.swift
// 视频浏览页：全屏播放器 + 顶部分类下拉 + 右侧操作栏 + 底部播放控制条
import SwiftUI
import Photos
import AVKit

struct VideoBrowserView: View {
    @EnvironmentObject var vm: VideoBrowserViewModel
    @State private var showInfo: Bool = false
    @State private var isPlaying: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false
    @State private var authStatus: AuthorizationStatus = .notDetermined

    private let photoService = PhotoLibraryService.shared

    var body: some View {
        ZStack {
            // 背景色
            Color.black.ignoresSafeArea()

            if !authStatus.hasAccess {
                permissionView
            } else {
                mainContent
            }

            // Toast 提示
            if showToast {
                toastView
            }
        }
        .task {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .notDetermined {
                authStatus = AuthorizationStatus(phStatus: status)
                let newStatus = await photoService.requestAuthorization()
                authStatus = newStatus
                if newStatus.hasAccess {
                    vm.loadRandomVideo()
                }
            } else {
                authStatus = AuthorizationStatus(phStatus: status)
                if authStatus.hasAccess {
                    vm.loadRandomVideo()
                }
            }
        }
        .onDisappear {
            vm.cleanup()
        }
        .fullScreenCover(isPresented: $showInfo) {
            if let asset = vm.currentAsset {
                MediaInfoView(asset: asset)
            }
        }
        .confirmationDialog("确认删除", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) {
                Task { await deleteAsset() }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后将无法恢复，确定要删除吗？")
        }
    }

    // MARK: - 主内容

    private var mainContent: some View {
        ZStack {
            if vm.isLoading {
                LoadingView()
            } else if let player = vm.player {
                playerView(player: player)
            } else if vm.currentAsset == nil {
                emptyView
            }
        }
    }

    // MARK: - 播放器主视图

    private func playerView(player: AVPlayer) -> some View {
        ZStack {
            // 全屏 VideoPlayer
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onTapGesture {
                    // 点击视频：弹出详情
                    showInfo = true
                }

            // 顶部：分类下拉（半透明背景）
            VStack {
                HStack {
                    FilterMenuView(selectedFilter: .constant(.video), batchSize: .constant(20))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(
                    LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 80)
                        .allowsTightening(false)
                )

                Spacer()
            }

            // 底部按钮栏（收藏、分享、撤销）
            VStack(spacing: 16) {
                Spacer()
                HStack {
                    HStack(spacing: 24) {
                        Button {
                            vm.toggleFavorite()
                            toastMessage = "已收藏"
                            showToast = true
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Button {
                            shareCurrentVideo()
                        } label: {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    Spacer()
                    Button {
                        vm.loadNextInBatch()
                        toastMessage = "已切换下一条"
                        showToast = true
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 160)

                playbackControls(player: player)
            }
        }
    }

    // MARK: - 播放控制条

    private func playbackControls(player: AVPlayer) -> some View {
        HStack(spacing: 40) {
            // 快退 10 秒
            Button {
                let currentTime = player.currentTime()
                let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
                vm.seek(to: newTime)
            } label: {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            // 播放/暂停
            Button {
                if isPlaying {
                    vm.pause()
                } else {
                    vm.play()
                }
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }

            // 快进 10 秒
            Button {
                let currentTime = player.currentTime()
                let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
                vm.seek(to: newTime)
            } label: {
                Image(systemName: "goforward.10")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom, 40)
    }

    // MARK: - 重试视图

    private var retryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.6))

            Text("视频加载失败")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Button("重试") {
                vm.loadRandomVideo()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 权限引导

    private var permissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: authStatus == .denied ? "lock.shield.fill" : "photo.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.white.opacity(0.7))

            Text(authStatus == .denied ? "视频访问被拒绝" : "部分视频权限")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(authStatus == .denied
                 ? "请在设置中开启视频访问权限"
                 : "仅能访问部分视频，请前往设置扩展访问范围")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("前往设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 空状态视图

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.6))

            Text("相册中没有视频")
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }

    // MARK: - Toast

    private var toastView: some View {
        VStack {
            Spacer()
            Text(toastMessage)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 60)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showToast = false
            }
        }
    }

    // MARK: - 分享视频

    private func shareCurrentVideo() {
        guard let asset = vm.currentAsset else { return }
        Task {
            let url = await MediaLoader.shared.loadVideoURL(asset)
            await MainActor.run {
                guard let url = url else {
                    toastMessage = "视频分享暂时不可用"
                    showToast = true
                    return
                }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            }
        }
    }

    // MARK: - 删除视频

    private func deleteAsset() async {
        do {
            try await vm.deleteCurrentAsset()
            await MainActor.run {
                toastMessage = "已删除"
                showToast = true
            }
        } catch {
            await MainActor.run {
                toastMessage = "删除失败"
                showToast = true
            }
        }
    }
}
