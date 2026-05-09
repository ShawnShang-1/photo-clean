// BottomTabBar.swift
// 底部胶囊 Tab：照片/视频/统计 三个切换按钮
import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "照片", icon: "photo.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "视频", icon: "video.fill", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "统计", icon: "chart.bar.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

private struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.accentColor : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BottomTabBar(selectedTab: .constant(0))
        .padding()
        .background(Color.black)
}
