import SwiftUI

/// 宠物视图 - 显示宠物形象、处理交互（点击、拖拽）
struct PetView: View {
    // MARK: - 设置模型
    @ObservedObject var settings: SettingsModel

    // MARK: - 回调闭包
    let onClose: () -> Void
    let onHide: () -> Void
    let onSettings: () -> Void
    let onDragStart: () -> Void
    let onDragChange: (CGFloat, CGFloat) -> Void
    let onDragEnd: () -> Void

    // MARK: - 状态变量
    @State private var showDialog = false
    @State private var greeting = ""
    @State private var petOffset: CGFloat = 0
    @State private var isDragging = false

    // MARK: - 视图主体
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // 对话框视图
            if showDialog {
                DialogView(text: greeting)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 4)
            }

            // 宠物主体
            ZStack {
                // 阴影/倒影效果
                if let imageData = settings.petImageData,
                   NSImage(data: imageData) != nil {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.12))
                        .frame(width: 68, height: 68)
                        .offset(y: 5)
                } else {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 70, height: 70)
                        .offset(y: 5)
                }

                // 优先显示自定义图片，否则显示 emoji
                if let imageData = settings.petImageData,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .cornerRadius(16)
                        .offset(y: isDragging ? 0 : petOffset)
                        .animation(
                            isDragging ? .none : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: petOffset
                        )
                } else {
                    Text(settings.petEmoji)
                        .font(.system(size: 70))
                        .offset(y: isDragging ? 0 : petOffset)
                        .animation(
                            isDragging ? .none : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: petOffset
                        )
                }
            }
            .frame(width: 120, height: 120)
            .background(Color.clear)
            // 单击显示打招呼对话框（非拖拽状态）
            .onTapGesture {
                if !isDragging {
                    showGreeting()
                }
            }
            // 拖拽手势处理
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { dragChanged($0) }
                    .onEnded { _ in dragEnded() }
            )
            // 右键菜单
            .contextMenu {
                Button("设置...") { onSettings() }
                Divider()
                Button("隐藏") { onHide() }
                Button("退出") { onClose() }
            }
        }
        .frame(minWidth: 120)
        // 视图出现时初始化
        .onAppear {
            petOffset = -6
            showGreeting()
            // 3秒后自动隐藏对话框
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showDialog = false }
            }
        }
    }

    // MARK: - 方法

    /// 显示随机打招呼对话框
    private func showGreeting() {
        greeting = settings.greetings.randomElement() ?? "你好！"
        withAnimation(.spring(response: 0.3)) {
            showDialog = true
        }
    }

    /// 拖拽中 - 通知 AppDelegate（位置增量由 AppDelegate 通过 NSEvent.mouseLocation 自行计算）
    private func dragChanged(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            onDragStart()
        }
        // dx/dy 参数被 AppDelegate 忽略，改用屏幕绝对坐标追踪鼠标位移
        onDragChange(value.translation.width, value.translation.height)
    }

    /// 拖拽结束 - 重置状态并通知AppDelegate触发边缘吸附
    private func dragEnded() {
        isDragging = false
        petOffset = -6  // 恢复浮动动画
        onDragEnd()     // 触发边缘吸附
    }
}