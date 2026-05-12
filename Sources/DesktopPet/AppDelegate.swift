import SwiftUI

/// AppDelegate - 管理应用生命周期、窗口和状态栏
class AppDelegate: NSObject, NSApplicationDelegate {
    /// 宠物窗口实例
    var petWindow: NSWindow?
    /// 状态栏图标
    var statusItem: NSStatusItem?
    /// 宠物隐藏状态
    var isHidden = false

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

    @objc func screenDidChange() {
        if !isHidden {
            positionWindowToBottomRight()
        }
    }

    // MARK: - 宠物窗口

    /// 设置宠物窗口
    private func setupPetWindow() {
        let petView = PetView(
            onClose: { [weak self] in self?.quitApp() },
            onHide: { [weak self] in self?.hidePet() },
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

        // 计算鼠标在屏幕坐标中的位移增量
        let deltaX = currentMouse.x - previous.x
        let deltaY = currentMouse.y - previous.y
        previousMouseLocation = currentMouse

        // 忽略微小移动（避免无意义的更新）
        guard abs(deltaX) > 0.01 || abs(deltaY) > 0.01 else { return }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let windowSize = window.frame.size

        // 鼠标和窗口都在同一屏幕坐标系（Y轴向上），无需翻转
        var newX = window.frame.origin.x + deltaX
        var newY = window.frame.origin.y + deltaY

        // 边界检查：确保窗口在屏幕可见范围内
        newX = max(screenFrame.origin.x, min(newX, screenFrame.origin.x + screenFrame.width - windowSize.width))
        newY = max(screenFrame.origin.y, min(newY, screenFrame.origin.y + screenFrame.height - windowSize.height))

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

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
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
}