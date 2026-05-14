# DesktopPet 🐱

macOS 桌面宠物应用，支持 emoji 或自定义图片作为宠物形象，悬浮在桌面上陪伴你的工作。

## 功能

- **桌面悬浮** — 无边框透明窗口，始终在所有层之上
- **拖拽移动** — 按住鼠标左键拖动，松开后自动吸附到当前屏幕最近边缘
- **多屏幕支持** — 可在多个显示器间自由拖拽移动
- **点击互动** — 单击弹出随机打招呼气泡，3 秒自动消失
- **右键菜单** — 右键可选择「设置...」「隐藏」「退出」
- **状态栏控制** — 菜单栏图标，支持显示/隐藏/设置/退出
- **单实例运行** — 防止重复启动
- **设置界面** — 自定义宠物形象、大小、打招呼语句

### 宠物形象

- 16 种预设 emoji 表情（🐱🐶🐰🐻🐼🐨🦊🐸🐵🐮🐷🐭🐹🐯🦁🐙）
- **自定义图片上传** — 支持 PNG/JPG 格式，自动调用 AI 模型（rembg）去除背景
- **近期形象** — 自动保存最近 5 个自定义形象，可直接复用无需重复生成

### 宠物大小

- 滑动条三档调节：小 (0.5×) / 中 (1.0×) / 大 (2.0×)
- 宠物主图、阴影、圆角全部等比缩放

### 打招呼语句

- 最多 10 条自定义问候语
- 支持编辑和删除

## 运行方式

### 直接运行 .app

双击 `DesktopPet.app` 即可启动。

### 从源码编译

```bash
cd desktop-pet
swift build --disable-sandbox -c release
.build/release/DesktopPet
```

### 编译为 .app

```bash
cd desktop-pet
swift build --disable-sandbox -c release
cp -f .build/release/DesktopPet DesktopPet.app/Contents/MacOS/DesktopPet
touch DesktopPet.app
```

### 运行测试

```bash
swift test --disable-sandbox
```

### 自定义图片去背景（可选）

如需用户上传图片时自动去除背景，需安装 rembg：

```bash
# 前置条件：Python 3.11、brew install llvm@20 libomp
# 创建 venv 并安装
cd experiments
python3.11 -m venv --copies venv
source venv/bin/activate
pip install "rembg[cpu,cli]"
```

详见 `experiments/remove_background.py`。

## 项目结构

```
desktop-pet/
├── Package.swift                    # Swift Package 配置
├── Sources/DesktopPet/
│   ├── DesktopPetApp.swift          # @main 入口
│   ├── AppDelegate.swift            # 窗口管理、状态栏、拖拽、边缘吸附、多屏
│   ├── PetView.swift                # 宠物视图 (emoji/图片 + 交互 + 动态尺寸)
│   ├── DialogView.swift             # 打招呼气泡对话框
│   ├── SettingsView.swift           # 设置界面 (形象选择、大小调节、问候语管理)
│   ├── SettingsModel.swift          # 设置数据模型 (UserDefaults 持久化)
│   └── SnapPositionCalculator.swift # 边缘吸附算法
├── Tests/DesktopPetTests/
│   ├── BasicTests.swift             # 基础功能测试 (29 个)
│   └── SnapPositionCalculatorTests.swift # 边缘吸附算法测试 (19 个)
├── DesktopPet.app/                  # 可运行的 .app 包
│   └── Contents/
│       ├── Info.plist
│       ├── MacOS/DesktopPet
│       └── Resources/DesktopPet.icns
├── DesktopPet.iconset/              # 图标源文件
└── experiments/                     # 实验性功能 (rembg 背景透明化等)
    └── remove_background.py
```

## 技术栈

- Swift 5.9+
- SwiftUI
- AppKit (NSWindow, NSStatusItem)
- macOS 13+

## License

MIT