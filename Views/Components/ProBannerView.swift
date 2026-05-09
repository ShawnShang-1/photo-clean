//
//  ProBannerView.swift
//  Pro 升级占位横幅
//

import SwiftUI

struct ProBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundColor(.white)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("升级 Pro")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("解锁全部高级功能")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Text("即将上线")
                .font(.caption)
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.3))
                .cornerRadius(12)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}
