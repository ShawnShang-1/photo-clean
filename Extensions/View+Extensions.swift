// View+Extensions.swift
// View 修饰器扩展：玻璃态背景封装
import SwiftUI

extension View {
    /// 玻璃态背景：.ultraThinMaterial 背景 + 白色边框 + 圆角
    func glassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.3), lineWidth: 0.5)
            )
    }
}
