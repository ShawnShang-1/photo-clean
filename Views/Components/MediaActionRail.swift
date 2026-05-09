// MediaActionRail.swift
// 媒体页右侧竖排圆形操作栏：收藏/分享/删除/撤销
import SwiftUI

enum ActionType {
    case favorite
    case share
    case delete
    case undo
}

struct MediaActionRail: View {
    let onAction: (ActionType) -> Void

    var body: some View {
        VStack(spacing: 20) {
            MediaActionButton(icon: "heart.fill", label: "收藏", action: { onAction(.favorite) }, isDestructive: false)
            MediaActionButton(icon: "square.and.arrow.up.fill", label: "分享", action: { onAction(.share) }, isDestructive: false)
            MediaActionButton(icon: "trash.fill", label: "删除", action: { onAction(.delete) }, isDestructive: true)
            MediaActionButton(icon: "arrow.uturn.backward", label: "撤销", action: { onAction(.undo) }, isDestructive: false)
        }
    }
}

#Preview {
    HStack {
        Spacer()
        MediaActionRail(onAction: { _ in })
            .padding()
    }
    .background(Color.black)
}
