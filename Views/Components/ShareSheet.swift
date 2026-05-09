// ShareSheet.swift
// UIViewControllerRepresentable 包装 UIActivityViewController，支持分享 UIImage/URL
import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 无需更新，items 通过初始化传入
    }
}

#Preview {
    ShareSheet(items: [URL(string: "https://example.com")!])
}
