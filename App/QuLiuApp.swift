import SwiftUI

@main
struct QuLiuApp: App {
    @StateObject var mediaBrowserVM = MediaBrowserViewModel()
    @StateObject var videoBrowserVM = VideoBrowserViewModel()
    @StateObject var statsVM = StatsViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(mediaBrowserVM)
                .environmentObject(videoBrowserVM)
                .environmentObject(statsVM)
        }
    }
}
