# DesktopPet 🐱

macOS 桌面宠物应用，一只可爱的 emoji 宠物悬浮在桌面上，陪伴你的工作。

## 功能

- **桌面悬浮** — 无边框透明窗口，始终在所有窗口之上
- **拖拽移动** — 按住鼠标左键拖动，松开后自动吸附到最近的屏幕边缘
- **点击互动** — 单击弹出随机打招呼气泡，3 秒自动消失
- **双击隐藏** — 双击宠物隐藏到状态栏
- **右键菜单** — 右键可选择「隐藏」或「退出」
- **状态栏控制** — 菜单栏猫图标，支持显示/隐藏/设置/退出
- **单实例运行** — 防止重复启动
- **设置界面** — 可自定义宠物形象（16 种 emoji）和打招呼语句（最多 10 条）

## 运行方式

### 直接运行 .app

双击 `DesktopPet.app` 即可启动。

### 从源码编译

```bash
cd desktop-pet
/usr/bin/swift build --disable-sandbox -c release
.build/release/DesktopPet
```

### 编译为 .app

```bash
cd desktop-pet
/usr/bin/swift build --disable-sandbox -c release
cp -f .build/release/DesktopPet DesktopPet.app/Contents/MacOS/DesktopPet
touch DesktopPet.app
```

### 运行测试

```bash
/usr/bin/swift test --disable-sandbox
```

## 项目结构

```
desktop-pet/
├── Package.swift                    # Swift Package 配置
├── Sources/DesktopPet/
│   ├── DesktopPetApp.swift          # @main 入口
│   ├── AppDelegate.swift            # 窗口管理、状态栏、拖拽、边缘吸附
│   ├── PetView.swift                # 宠物视图 (emoji + 交互)
│   ├── DialogView.swift             # 打招呼气泡对话框
│   ├── SettingsView.swift           # 设置界面 (emoji选择 + 问候语管理)
│   ├── SettingsModel.swift          # 设置数据模型 (UserDefaults 持久化)
│   └── SnapPositionCalculator.swift # 边缘吸附算法
├── Tests/DesktopPetTests/
│   ├── BasicTests.swift             # 基础功能测试
│   └── SnapPositionCalculatorTests.swift # 边缘吸附算法测试
├── DesktopPet.app/                  # 可运行的 .app 包
│   └── Contents/
│       ├── Info.plist
│       ├── MacOS/DesktopPet
│       └── Resources/AppIcon.icns
└── DesktopPet.iconset/              # 图标源文件
```

## 技术栈

- Swift 5.9+
- SwiftUI
- AppKit (NSWindow, NSStatusItem)
- macOS 13+

## License

MIT