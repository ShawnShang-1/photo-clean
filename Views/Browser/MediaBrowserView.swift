// MediaBrowserView.swift
// 照片浏览页：顶部分类下拉 + 中间玻璃卡片展示当前照片 + 右侧操作栏 + 底部滑动切换
import SwiftUI
import Photos

struct MediaBrowserView: View {
    @EnvironmentObject var vm: MediaBrowserViewModel
    @State private var showInfo: Bool = false
    @State private var toastMessage: String = ""
    @State private var showDeleteConfirm: Bool = false
    @State private var deleteError: String?
    @State private var showDeleteError: Bool = false
    @State private var showToast: Bool = false

    private let photoService = PhotoLibraryService.shared

    // 权限引导：denied/limited 时显示对应 UI
    @State private var authStatus: AuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            // 背景色
            Color.black.ignoresSafeArea()

            if !authStatus.hasAccess {
                // 权限引导 UI
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
                    vm.shuffle(count: vm.batchSize)
                }
            } else {
                authStatus = AuthorizationStatus(phStatus: status)
                if authStatus.hasAccess && vm.currentAsset == nil {
                    vm.shuffle(count: vm.batchSize)
                }
            }
        }
        .alert("删除失败", isPresented: $showDeleteError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(deleteError ?? "未知错误")
        }
        .fullScreenCover(isPresented: $showInfo) {
            if let asset = vm.currentAsset {
                MediaInfoView(asset: asset)
            }
        }
    }

    // MARK: - 主内容

    private var mainContent: some View {
        VStack(spacing: 0) {
            // 顶部：分类下拉
            HStack {
                FilterMenuView(selectedFilter: $vm.selectedCategory, batchSize: $vm.batchSize)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // 中间：玻璃卡片展示当前照片
            GeometryReader { geometry in
                ZStack {
                    if let asset = vm.currentAsset {
                        GlassCardView(asset: asset) {
                            // 点击照片：弹出详情
                            showInfo = true
                        }
                    } else if vm.isLoading {
                        LoadingView()
                    } else {
                        Text("暂无照片")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .gesture(
                    // 左右滑动切换照片
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                // 左滑：加载下一张
                                vm.loadNextInBatch()
                            } else if value.translation.width > 50 {
                                // 右滑：撤销（上一张不在池中，此处仅提示）
                                toastMessage = "已是第一张"
                                showToast = true
                            }
                        }
                )
            }

            // 底部操作提示
            HStack {
                Text("左右滑动切换")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .overlay(alignment: .trailing) {
            // 右侧：媒体操作栏
            MediaActionRail(onAction: { action in
                switch action {
                case .favorite:
                    vm.toggleFavorite()
                case .share:
                    shareCurrentAsset()
                case .delete:
                    showDeleteConfirm = true
                case .undo:
                    toastMessage = "撤销功能开发中"
                    showToast = true
                }
            })
            .padding(.trailing, 12)
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

    // MARK: - 权限引导

    private var permissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: authStatus == .denied ? "lock.shield.fill" : "photo.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.white.opacity(0.7))

            Text(authStatus == .denied ? "照片访问被拒绝" : "部分照片权限")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(authStatus == .denied
                 ? "请在设置中开启照片访问权限"
                 : "仅能访问部分照片，请前往设置扩展访问范围")
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

    // MARK: - 分享

    private func shareCurrentAsset() {
        guard let asset = vm.currentAsset else { return }
        let screenScale = UIScreen.main.scale
        let maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * screenScale * 2
        Task {
            let image = await MediaLoader.shared.loadFullImage(asset, maxDimension: maxDimension)
            if let image = image {
                await MainActor.run {
                    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - 删除

    private func deleteAsset() async {
        do {
            try await vm.deleteCurrentAsset()
            await MainActor.run {
                toastMessage = "已删除"
                showToast = true
            }
        } catch {
            await MainActor.run {
                deleteError = error.localizedDescription
                showDeleteError = true
            }
        }
    }
}
