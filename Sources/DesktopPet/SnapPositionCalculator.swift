import Foundation

/// 边缘吸附位置计算器 - 提供纯逻辑计算，便于测试
struct SnapPositionCalculator {
    
    /// 计算边缘吸附的目标位置
    /// - Parameters:
    ///   - screenFrameX: 屏幕可见区域X坐标
    ///   - screenFrameY: 屏幕可见区域Y坐标
    ///   - screenWidth: 屏幕宽度
    ///   - screenHeight: 屏幕高度
    ///   - windowWidth: 窗口宽度
    ///   - windowHeight: 窗口高度
    ///   - currentX: 当前X坐标
    ///   - currentY: 当前Y坐标
    ///   - padding: 边缘边距
    /// - Returns: 吸附后的目标位置 (x, y)
    static func calculate(
        screenFrameX: CGFloat,
        screenFrameY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat,
        windowWidth: CGFloat,
        windowHeight: CGFloat,
        currentX: CGFloat,
        currentY: CGFloat,
        padding: CGFloat = 20
    ) -> (x: CGFloat, y: CGFloat) {
        // 计算目标边缘位置（注意：macOS坐标系 Y 轴向上增长，数值越大越靠上）
        let targetLeftX = screenFrameX + padding
        let targetRightX = screenFrameX + screenWidth - windowWidth - padding
        let targetNearMenuBarY = screenFrameY + padding  // 靠近菜单栏（顶部，Y小）
        let targetNearDockY = screenFrameY + screenHeight - windowHeight - padding  // 靠近Dock（底部，Y大）
        
        // 计算窗口当前位置到各个边缘的距离
        let distToLeft = abs(currentX - targetLeftX)
        let distToRight = abs(currentX - targetRightX)
        let distToMenuBar = abs(currentY - targetNearMenuBarY)
        let distToDock = abs(currentY - targetNearDockY)
        
        // 找到最近的垂直边缘和水平边缘
        let nearestVertical = distToLeft < distToRight ? targetLeftX : targetRightX
        let nearestHorizontal = distToMenuBar < distToDock ? targetNearMenuBarY : targetNearDockY
        
        // 判断是靠近垂直边缘还是水平边缘
        let verticalDist = min(distToLeft, distToRight)
        let horizontalDist = min(distToMenuBar, distToDock)
        
        var targetX = currentX
        var targetY = currentY
        
        if verticalDist < horizontalDist {
            // 更靠近垂直边缘，只水平移动
            targetX = nearestVertical
            targetY = currentY
        } else {
            // 更靠近水平边缘，只垂直移动
            targetX = currentX
            targetY = nearestHorizontal
        }
        
        // 安全边界检查
        targetX = max(screenFrameX, min(targetX, screenFrameX + screenWidth - windowWidth))
        targetY = max(screenFrameY, min(targetY, screenFrameY + screenHeight - windowHeight))
        
        return (targetX, targetY)
    }
}