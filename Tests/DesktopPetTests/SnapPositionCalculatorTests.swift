import XCTest
@testable import DesktopPet

final class SnapPositionCalculatorTests: XCTestCase {

    // MARK: - 垂直边缘吸附测试（左右）

    func testTopLeftAreaSnapsToLeftEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 50, currentY: 500,
            padding: 20
        )
        XCTAssertEqual(result.x, 20, "应吸附到左侧边缘 x=20")
        XCTAssertEqual(result.y, 500, "垂直位置不应改变")
    }

    func testTopRightAreaSnapsToRightEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 1800, currentY: 500,
            padding: 20
        )
        XCTAssertEqual(result.x, 1780, "应吸附到右侧边缘 x=1780")
        XCTAssertEqual(result.y, 500, "垂直位置不应改变")
    }

    func testCenterLeftSnapsToLeftEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 100, currentY: 550,
            padding: 20
        )
        XCTAssertEqual(result.x, 20, "应吸附到左侧边缘 x=20")
        XCTAssertEqual(result.y, 550, "垂直位置不应改变")
    }

    func testCenterRightSnapsToRightEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 1820, currentY: 550,
            padding: 20
        )
        XCTAssertEqual(result.x, 1780, "应吸附到右侧边缘 x=1780")
        XCTAssertEqual(result.y, 550, "垂直位置不应改变")
    }

    // MARK: - 水平边缘吸附测试（上下）

    func testTopCenterSnapsToTopEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 150,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 100, "应吸附到顶部边缘 y=100")
    }

    func testBottomCenterSnapsToBottomEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 900,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 910, "应吸附到底部边缘 y=910")
    }

    func testCenterUpSnapsToTopEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 300,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 100, "应吸附到顶部边缘 y=100")
    }

    func testCenterDownSnapsToBottomEdge() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 800,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 910, "应吸附到底部边缘 y=910")
    }

    // MARK: - 边界值测试

    func testAlreadyAtLeftEdge_NoMove() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 20, currentY: 550,
            padding: 20
        )
        XCTAssertEqual(result.x, 20, "已在左边缘，x不应改变")
        XCTAssertEqual(result.y, 550, "垂直位置不应改变")
    }

    func testAlreadyAtRightEdge_NoMove() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 1780, currentY: 550,
            padding: 20
        )
        XCTAssertEqual(result.x, 1780, "已在右边缘，x不应改变")
        XCTAssertEqual(result.y, 550, "垂直位置不应改变")
    }

    func testAlreadyAtTopEdge_NoMove() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 100,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 100, "已在顶部边缘，y不应改变")
    }

    func testAlreadyAtBottomEdge_NoMove() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 910,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        XCTAssertEqual(result.y, 910, "已在底部边缘，y不应改变")
    }

    // MARK: - 等距/对半场景

    func testExactMiddle_VerticalVsHorizontal() {
        // 窗口在屏幕正中央，x方向距左右各930，y方向距上下各455
        // 此时horizontalDist(455) < verticalDist(930)，应吸附到水平边缘
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 555,
            padding: 20
        )
        XCTAssertEqual(result.x, 960, "水平位置不应改变")
        // 距离顶部: |555-100|=455, 距离底部: |555-910|=355, 选底部
        XCTAssertEqual(result.y, 910, "更靠近底部边缘")
    }

    func testNearScreenCenter_VerticalWins() {
        // x=960(距左右各940，均远超y方向)，y=200(距上100，距下710)，垂直胜
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 200,
            padding: 20
        )
        XCTAssertEqual(result.x, 960)
        XCTAssertEqual(result.y, 100, "距顶部仅80px，应吸附顶部")
    }

    // MARK: - 屏幕原点偏移场景（外接显示器/多屏）

    func testSecondaryDisplayNegativeOrigin() {
        // 左侧外接显示器，原点为(-1920, 0)，窗口在(-960, 540)
        // 距左: |-960-(-1900)|=940, 距右: |-960-(-60)|=900, 距上: |540-20|=520, 距下: |540-910|=370
        // horizontalDist=370 < verticalDist=900, 吸附底部 Dock 边缘
        let result = SnapPositionCalculator.calculate(
            screenFrameX: -1920, screenFrameY: 0,
            screenWidth: 1920, screenHeight: 1080,
            windowWidth: 120, windowHeight: 150,
            currentX: -960, currentY: 540,
            padding: 20
        )
        XCTAssertEqual(result.x, -960, "水平位置不变")
        XCTAssertEqual(result.y, 910, "距Dock(370) < 距菜单栏(520), 吸附底部 y=910")
    }

    func testResultAlwaysWithinScreenBounds() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 80,
            screenWidth: 1920, screenHeight: 1000,
            windowWidth: 120, windowHeight: 150,
            currentX: -50, currentY: -50,
            padding: 20
        )
        XCTAssertGreaterThanOrEqual(result.x, 0, "x不应超出屏幕左边界")
        XCTAssertGreaterThanOrEqual(result.y, 80, "y不应超出屏幕下边界")
        XCTAssertLessThanOrEqual(result.x, 1800, "x不应超出屏幕右边界")
        XCTAssertLessThanOrEqual(result.y, 930, "y不应超出屏幕上边界")
    }

    // MARK: - 自定义 padding

    func testCustomPadding() {
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 0,
            screenWidth: 1920, screenHeight: 1080,
            windowWidth: 120, windowHeight: 150,
            currentX: 50, currentY: 540,
            padding: 50
        )
        XCTAssertEqual(result.x, 50, "自定义padding=50，应吸附到左侧x=50")
        XCTAssertEqual(result.y, 540)
    }

    // MARK: - 新增：右侧副屏场景

    func testRightSideDisplaySnapsToRightEdge() {
        // 副屏在右侧，origin=(1920, 0)，主屏为 (0,0,1920,1080)
        // 窗口在副屏偏右位置(x=3720)，距右边缘仅20px → 应吸附右边缘
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 1920, screenFrameY: 0,
            screenWidth: 1920, screenHeight: 1080,
            windowWidth: 120, windowHeight: 150,
            currentX: 3720, currentY: 540,
            padding: 20
        )
        // 距右: |3720-3700|=20, 距Dock: |540-910|=370 → 垂直边缘胜
        XCTAssertEqual(result.x, 3700, "吸附到副屏右边缘 x=3700")
        XCTAssertEqual(result.y, 540, "垂直位置不变")
    }

    func testUpperDisplaySnapsToTopEdge() {
        // 上方副屏 origin=(0, 1080)（主屏在下方）
        // 窗口在上方副屏偏顶部
        let result = SnapPositionCalculator.calculate(
            screenFrameX: 0, screenFrameY: 1080,
            screenWidth: 1920, screenHeight: 1080,
            windowWidth: 120, windowHeight: 150,
            currentX: 960, currentY: 1150,
            padding: 20
        )
        // 距上: |1150-1100|=50, 距下: |1150-1990|=840 → 选上(菜单栏)
        // 距左: |960-20|=940, 距右: |960-1900|=940 → 平局→先选左
        // horizontalDist(50) < verticalDist(940), 吸附顶部
        XCTAssertEqual(result.x, 960, "水平位置不变")
        XCTAssertEqual(result.y, 1100, "吸附到上方副屏顶部边缘")
    }
}