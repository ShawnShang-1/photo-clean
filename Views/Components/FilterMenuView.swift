// FilterMenuView.swift
// 顶部下拉分类菜单：6 分类按钮 + 调整每组数量
import SwiftUI

struct FilterMenuView: View {
    @Binding var selectedFilter: MediaType?
    @Binding var batchSize: Int
    @State private var showActionSheet = false

    var body: some View {
        // 水平滚动的分类按钮行
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 全部按钮
                FilterButton(
                    title: "全部",
                    icon: "square.grid.2x2",
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }

                // 6 个分类按钮
                ForEach(MediaType.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.displayName,
                        icon: iconFor(filter),
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }

                // 调整每组数量按钮
                FilterButton(
                    title: "每组\(batchSize)张",
                    icon: "slider.horizontal.3",
                    isSelected: false
                ) {
                    showActionSheet = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground).opacity(0.9))
        // 点击弹出 ActionSheet
        .confirmationDialog("选择分类", isPresented: $showActionSheet) {
            // 6 个分类选项
            Button("全部") {
                selectedFilter = nil
            }
            ForEach(MediaType.allCases, id: \.self) { filter in
                Button(filter.displayName) {
                    selectedFilter = filter
                }
            }
            // 分隔线
            Divider()
            // 调整每组数量
            Button("调整每组数量...") {
                // 显示 BatchSizeEditorView sheet
                showBatchSizeEditor = true
            }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $showBatchSizeEditor) {
            BatchSizeEditorView(batchSize: $batchSize)
        }
    }

    @State private var showBatchSizeEditor = false

    /// 根据 MediaType 返回对应图标
    private func iconFor(_ filter: MediaType) -> String {
        switch filter {
        case .photo:     return "photo"
        case .screenshot: return "rectangle.on.rectangle"
        case .selfie:    return "person.crop.square"
        case .livePhoto: return "livephoto"
        case .animated:  return "gift"
        case .video:     return "video"
        }
    }
}

// 单个分类按钮组件
private struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FilterMenuView(selectedFilter: .constant(.photo), batchSize: .constant(20))
        .padding()
        .background(Color(.systemGroupedBackground))
}
