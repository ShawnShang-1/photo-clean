//  RootTabView.swift
//  底部 Tab 容器，管理三个主要 Tab 页面切换

import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    MediaBrowserView()
                case 1:
                    VideoBrowserView()
                default:
                    StatsView()
                }
            }
            .ignoresSafeArea()

            BottomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 34)
                .padding(.bottom, 18)
        }
    }
}
