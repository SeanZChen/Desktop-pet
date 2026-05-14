import SwiftUI

/// AppDelegate - 管理应用生命周期、窗口和状态栏
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    /// 宠物窗口实例
    var petWindow: NSWindow?
    /// 设置窗口实例
    var settingsWindow: NSWindow?
    /// 状态栏图标
    var statusItem: NSStatusItem?
    /// 宠物隐藏状态
    var isHidden = false
    /// 全局设置模型（宠物窗口和设置窗口共享）
    let settingsModel = SettingsModel()

    /// 应用启动完成回调
    func applicationDidFinishLaunching(_ notification: Notification) {
        if !ensureSingleInstance() {
            NSApplication.shared.terminate(nil)
            return
        }

        setupStatusItem()
        setupPetWindow()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - 单实例检测

    /// 单实例检测 - 防止重复启动多个桌宠
    private func ensureSingleInstance() -> Bool {
        let appIdentifier = "com.example.DesktopPet"
        let runningApps = NSWorkspace.shared.runningApplications
        var instanceCount = 0

        for app in runningApps {
            if let bundleIdentifier = app.bundleIdentifier, bundleIdentifier == appIdentifier {
                instanceCount += 1
                if instanceCount > 1 {
                    return false
                }
            }
        }
        return true
    }

    // MARK: - 状态栏

    /// 设置状态栏图标
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cat", accessibilityDescription: "DesktopPet")
            button.action = #selector(togglePetVisibility)
            button.target = self
        }

        setupStatusMenu()
    }

    /// 设置状态栏右键菜单
    private func setupStatusMenu() {
        let menu = NSMenu(title: "DesktopPet")

        let showItem = NSMenuItem(title: "显示宠物", action: #selector(showPet), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        let hideItem = NSMenuItem(title: "隐藏宠物", action: #selector(hidePet), keyEquivalent: "")
        hideItem.target = self
        menu.addItem(hideItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc func togglePetVisibility() {
        if isHidden {
            showPet()
        } else {
            hidePet()
        }
    }

    @objc func showPet() {
        petWindow?.makeKeyAndOrderFront(nil)
        isHidden = false
    }

    @objc func hidePet() {
        petWindow?.orderOut(nil)
        isHidden = true
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func openSettings() {
        if let existing = settingsWindow {
            existing.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(settings: settingsModel)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.title = "桌宠设置"
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self

        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    @objc func screenDidChange() {
        if !isHidden {
            positionWindowToBottomRight()
        }
    }

    // MARK: - 宠物窗口

    /// 设置宠物窗口
    private func setupPetWindow() {
        let petView = PetView(
            settings: settingsModel,
            onClose: { [weak self] in self?.quitApp() },
            onHide: { [weak self] in self?.hidePet() },
            onSettings: { [weak self] in self?.openSettings() },
            onDragStart: { [weak self] in self?.onDragStart() },
            onDragChange: { [weak self] dx, dy in self?.onDragChange(dx: dx, dy: dy) },
            onDragEnd: { [weak self] in
                print("[DesktopPet] dragEnded, triggering snapToEdge")
                self?.onDragEnd()
            }
        )
        let hostingController = NSHostingController(rootView: petView)

        // 创建无边框透明窗口
        petWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 150),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // 配置窗口属性
        petWindow?.contentViewController = hostingController
        petWindow?.isOpaque = false
        petWindow?.backgroundColor = .clear
        petWindow?.level = .floating
        petWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        petWindow?.ignoresMouseEvents = false
        petWindow?.isReleasedWhenClosed = false
        petWindow?.title = "DesktopPet"

        petWindow?.makeKeyAndOrderFront(nil)

        // 延迟0.1秒后定位到右下角（等待窗口完全初始化）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.positionWindowToBottomRight()
        }
    }

    /// 将窗口定位到屏幕右下角
    private func positionWindowToBottomRight() {
        guard let window = petWindow else { return }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let windowSize = window.frame.size

        let targetX = screenFrame.origin.x + screenFrame.width - windowSize.width - 20
        let targetY = screenFrame.origin.y + 20

        let safeX = max(screenFrame.origin.x, min(targetX, screenFrame.origin.x + screenFrame.width - windowSize.width))
        let safeY = max(screenFrame.origin.y, min(targetY, screenFrame.origin.y + screenFrame.height - windowSize.height))

        window.setFrameOrigin(NSPoint(x: safeX, y: safeY))
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - 拖拽处理

    /// 上一次鼠标位置（屏幕绝对坐标），用于计算逐帧位移增量
    private var previousMouseLocation: NSPoint?

    /// 拖拽开始 - 记录鼠标起始位置
    func onDragStart() {
        previousMouseLocation = NSEvent.mouseLocation
    }

    /// 拖拽中 - 根据鼠标屏幕位移增量移动窗口（限制在屏幕内）
    /// 参数 dx/dy 来自 SwiftUI DragGesture，此处忽略，改用屏幕绝对坐标追踪
    func onDragChange(dx: CGFloat, dy: CGFloat) {
        guard let window = petWindow else { return }

        let currentMouse = NSEvent.mouseLocation
        guard let previous = previousMouseLocation else {
            previousMouseLocation = currentMouse
            return
        }

        let deltaX = currentMouse.x - previous.x
        let deltaY = currentMouse.y - previous.y
        previousMouseLocation = currentMouse

        // 忽略微小移动（避免无意义的更新）
        guard abs(deltaX) > 0.01 || abs(deltaY) > 0.01 else { return }

        let windowSize = window.frame.size

        // 鼠标和窗口都在全局屏幕坐标系（Y轴向上），无需翻转
        var newX = window.frame.origin.x + deltaX
        var newY = window.frame.origin.y + deltaY

        // 仅确保窗口至少部分可见于任意屏幕，不锁定在单一屏幕内
        var anyScreenContains = false
        for screen in NSScreen.screens {
            let s = screen.visibleFrame
            let windowRect = NSRect(x: newX, y: newY, width: windowSize.width, height: windowSize.height)
            if windowRect.intersects(s) {
                anyScreenContains = true
                break
            }
        }

        // 若窗口完全脱离所有屏幕，弹回最近屏幕可见范围
        if !anyScreenContains, let nearest = screenForWindow() {
            let s = nearest.visibleFrame
            newX = max(s.origin.x, min(newX, s.origin.x + s.width - windowSize.width))
            newY = max(s.origin.y, min(newY, s.origin.y + s.height - windowSize.height))
        }

        window.setFrameOrigin(NSPoint(x: newX, y: newY))
    }

    /// 拖拽结束 - 触发边缘吸附
    func onDragEnd() {
        snapToEdge()
    }

    // MARK: - 边缘吸附

    /// 边缘吸附算法 - 将窗口吸附到最近的屏幕边缘
    private func snapToEdge() {
        guard let window = petWindow else {
            print("[DesktopPet] snapToEdge: petWindow is nil, aborting")
            return
        }

        // 获取窗口当前所在的屏幕（而非默认主屏幕）
        let currentScreen = screenForWindow()
        let screenFrame = currentScreen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let windowSize = window.frame.size
        let currentX = window.frame.origin.x
        let currentY = window.frame.origin.y
        let padding: CGFloat = 20

        print("[DesktopPet] snapToEdge: current=\(currentX),\(currentY) screen=\(screenFrame)")

        // 调用独立的 SnapPositionCalculator 进行计算
        let (targetX, targetY) = SnapPositionCalculator.calculate(
            screenFrameX: screenFrame.origin.x,
            screenFrameY: screenFrame.origin.y,
            screenWidth: screenFrame.width,
            screenHeight: screenFrame.height,
            windowWidth: windowSize.width,
            windowHeight: windowSize.height,
            currentX: currentX,
            currentY: currentY,
            padding: padding
        )

        print("[DesktopPet] snapToEdge: target=\(targetX),\(targetY)")

        // 如果位置发生变化，执行平滑动画
        if abs(targetX - currentX) > 1 || abs(targetY - currentY) > 1 {
            print("[DesktopPet] snapToEdge: animating to (\(targetX), \(targetY))")
            let targetFrame = NSRect(x: targetX, y: targetY, width: windowSize.width, height: windowSize.height)
            window.setFrame(targetFrame, display: true, animate: true)
        } else {
            print("[DesktopPet] snapToEdge: already at target, no animation needed")
        }
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
        }
    }

    // MARK: - 多屏辅助

    /// 查找窗口中心点所在的屏幕
    /// 若窗口中心不在任何屏幕内，则返回距离最近的屏幕
    private func screenForWindow() -> NSScreen? {
        guard let window = petWindow else { return nil }

        let windowCenter = NSPoint(
            x: window.frame.origin.x + window.frame.width / 2,
            y: window.frame.origin.y + window.frame.height / 2
        )

        // 优先匹配窗口中心所在的屏幕
        for screen in NSScreen.screens {
            if screen.visibleFrame.contains(windowCenter) {
                return screen
            }
        }

        // 回退：返回距离窗口中心最近的屏幕
        var nearestScreen: NSScreen?
        var minDistance: CGFloat = .greatestFiniteMagnitude
        for screen in NSScreen.screens {
            let frame = screen.visibleFrame
            let clampedX = max(frame.minX, min(windowCenter.x, frame.maxX))
            let clampedY = max(frame.minY, min(windowCenter.y, frame.maxY))
            let dx = windowCenter.x - clampedX
            let dy = windowCenter.y - clampedY
            let dist = sqrt(dx * dx + dy * dy)
            if dist < minDistance {
                minDistance = dist
                nearestScreen = screen
            }
        }

        return nearestScreen ?? NSScreen.main
    }
}