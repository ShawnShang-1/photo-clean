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
            MediaActionButton(icon: "arrow.uturn.backward", label: "撤销", action: { onAction(.undo) }, isDestructive: false)
        }
        .opacity(0.6)
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
