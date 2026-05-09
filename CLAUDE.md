# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuLiu (去留) is a SwiftUI iOS app that helps users review and declutter their photo/video library. Users swipe through their media, choosing to keep or delete items, with statistics tracking space freed.

## Architecture

**Pattern**: MVVM with service layer

- **Models/** - Data structures: `MediaType` (photo/screenshot/selfie/livePhoto/animated/video), `MediaItem`, `AuthorizationStatus`, `UserStats`
- **ViewModels/** - `@MainActor` ObservableObjects: `MediaBrowserViewModel`, `VideoBrowserViewModel`, `StatsViewModel`
- **Services/** - Business logic:
  - `PhotoLibraryService` - PhotoKit wrapper (permissions, fetch, delete via `performChanges`)
  - `MediaLoader` - `actor` for thread-safe image/video loading with `withCheckedContinuation`
  - `StatisticsService` - Tracks viewed/deleted counts and bytes freed via UserDefaults
  - `MediaMetadataService` - Media metadata extraction
- **Views/** - SwiftUI views organized as:
  - `Browser/` - `MediaBrowserView`, `VideoBrowserView`, `GlassCardView`
  - `Components/` - Reusable UI: `MediaActionRail`, `FilterMenuView`, `StatCardView`, etc.
  - `Stats/` - Statistics dashboard

## Key Implementation Details

- **Actor-based loading**: `MediaLoader` is an `actor` that wraps PHImageManager callbacks with `withCheckedContinuation`
- **Permission handling**: Uses `PHPhotoLibrary.authorizationStatus(for: .readWrite)` and handles `.authorized`, `.limited`, `.denied` states
- **Batch operations**: Deletions use `PHPhotoLibrary.performChanges { PHAssetChangeRequest.deleteAssets }`
- **State persistence**: `batchSize` and viewed identifiers stored in UserDefaults

## Building

No `.xcodeproj` or `Package.swift` exists in the repository. An Xcode project needs to be created:
1. Use Xcode: **File > New > Project > iOS > App**
2. Add existing source files to the project
3. Configure **Info.plist** with photo library usage descriptions:
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`

## Development Notes

- App entry: `App/QuLiuApp.swift` creates three `@StateObject` ViewModels passed as `environmentObject`
- Tab navigation via `RootTabView` with `BottomTabBar` (3 tabs: Photos, Videos, Stats)
- Media type inference: `MediaType.init(asset:)` maps `PHAsset.mediaType` and `mediaSubtypes`
- All ViewModels use `@MainActor` for UI thread safety
