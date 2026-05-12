import SwiftUI

/// 桌面宠物主应用入口
@main
struct DesktopPetApp: App {
    /// 使用 AppDelegate 管理窗口和状态栏
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}