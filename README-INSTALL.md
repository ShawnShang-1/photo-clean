# 去留 (QuLiu) - 手动 Xcode 工程创建指南

由于本机未安装 XcodeGen，需手动创建 Xcode 工程。

## 前置要求

- Xcode 15+
- Xcode Command Line Tools: `xcode-select --install`
- iOS 17+ 模拟器或真机

## 手动创建工程步骤

### 1. 创建新工程

1. 打开 Xcode
2. **File > New > Project...**
3. 选择 **iOS** > **App**
4. 点击 **Next**

### 2. 配置工程选项

| 配置项 | 值 |
|--------|-----|
| Product Name | QuLiu |
| Bundle Identifier | com.quliu.app |
| Interface | SwiftUI |
| Life Cycle | SwiftUI App |
| Language | Swift |
| Minimum Deployments | iOS 17.0 |

5. 点击 **Next**
6. 选择存储位置（建议与 `去留/` 同级目录），点击 **Create**

### 3. 添加现有源文件

1. 在 Project Navigator 中删除自动生成的 `QuLiuApp.swift`（如果有）
2. 右键点击项目根节点 > **Add Files to "QuLiu"**
3. 导航到 `去留/` 目录
4. **勾选 "Copy items if needed"**
5. **勾选 "Create groups"**
6. 选择以下目录并添加：
   - `App/` (包含 Info.plist 和 QuLiuApp.swift)
   - `Models/`
   - `Views/`
   - `ViewModels/`
   - `Services/`
   - `Extensions/`
   - `Resources/`

### 4. 配置 Info.plist

Xcode 会使用 `App/Info.plist`。确保包含以下键（已在 `App/Info.plist` 中配置）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>去留需要访问你的相册以随机展示并协助你清理照片和视频</string>
</dict>
</plist>
```

### 5. 配置工程设置

1. 选择 **QuLiu** target
2. **Signing & Capabilities**:
   - 取消勾选 "Automatically manage signing"（手动签名）
   - Team: 选择你的开发团队
   - Bundle Identifier: `com.quliu.app`
3. **General**:
   - Display Name: `去留`
   - iOS Deployment Target: `17.0`
   - Orientation: 仅勾选 **Portrait**（竖屏）
4. **Build Settings**:
   - Swift Version: `6.0`
   - Strict Concurrency Checking: `Complete`（用于开发）

### 6. 验证工程

```bash
cd "/Users/shawnshang/code project/去留app/去留"
xcodebuild -list -project QuLiu.xcodeproj
```

预期输出：
```
Targets:
    QuLiu
```

### 7. 构建工程

```bash
cd "/Users/shawnshang/code project/去留app/去留"
xcodebuild -project QuLiu.xcodeproj -scheme QuLiu \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 工程结构

```
去留/
├── App/
│   ├── Info.plist
│   └── QuLiuApp.swift
├── Models/
│   ├── AuthorizationStatus.swift
│   ├── MediaItem.swift
│   ├── MediaType.swift
│   └── UserStats.swift
├── ViewModels/
│   ├── MediaBrowserViewModel.swift
│   ├── StatsViewModel.swift
│   └── VideoBrowserViewModel.swift
├── Views/
│   ├── RootTabView.swift
│   ├── Browser/
│   │   ├── GlassCardView.swift
│   │   ├── MediaBrowserView.swift
│   │   └── VideoBrowserView.swift
│   ├── Components/
│   │   └── [15 个组件文件]
│   └── Stats/
│       └── StatsView.swift
├── Services/
│   ├── MediaLoader.swift
│   ├── MediaMetadataService.swift
│   ├── PhotoLibraryService.swift
│   └── StatisticsService.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   ├── PHAsset+Extensions.swift
│   └── View+Extensions.swift
└── Resources/
    └── Assets.xcassets/
```

## 依赖

本项目**不使用 CocoaPods 或 Swift Package Manager**。所有代码均为原生实现：
- SwiftUI（UI框架）
- Photos（PhotoKit，相册访问）
- AVKit/AVFoundation（视频播放）
- Combine（响应式编程）
- UserDefaults（本地存储）

## 常见问题

### Q: 构建失败，提示 "Cannot find 'QuLiuApp'"
A: 确保 `App/QuLiuApp.swift` 已正确添加到工程，且 `@main` 属性在该文件上。

### Q: 照片权限未弹窗
A: 确保 Info.plist 中 `NSPhotoLibraryUsageDescription` 已正确配置，且首次调用了 `PHPhotoLibrary.requestAuthorization`。

### Q: 模拟器无法测试照片功能
A: 照片库访问权限仅在**真机**上可用。模拟器会返回空相册。
