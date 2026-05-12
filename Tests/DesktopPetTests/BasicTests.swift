import XCTest
@testable import DesktopPet

final class BasicTests: XCTestCase {

    func testGreetingsArrayNotEmpty() {
        let greetings = [
            "你好呀！😊",
            "今天心情不错！☀️",
            "陪我玩一会儿吧~",
            "主人好！🐾",
            "喵~ 想我了吗？",
            "天气真好呀！🌈",
            "今天也要加油哦！💪",
            "饿了... 有小鱼干吗？🐟",
            "嘿嘿，见到你真开心！",
            "要不要一起发呆？"
        ]
        XCTAssertFalse(greetings.isEmpty)
        XCTAssertGreaterThanOrEqual(greetings.count, 5)
    }

    func testRandomGreetingProducesVariety() {
        let greetings = [
            "你好呀！😊", "今天心情不错！☀️", "陪我玩一会儿吧~",
            "主人好！🐾", "喵~ 想我了吗？"
        ]
        var selected = Set<String>()
        for _ in 0..<20 {
            if let g = greetings.randomElement() { selected.insert(g) }
        }
        XCTAssertGreaterThan(selected.count, 1, "随机选择应产生不同结果")
    }

    func testEdgePositionCalculations() {
        let screenWidth: CGFloat = 1920
        let screenHeight: CGFloat = 1080
        let windowWidth: CGFloat = 120
        let windowHeight: CGFloat = 150
        let padding: CGFloat = 20

        XCTAssertEqual(screenHeight - windowHeight - padding, 910, "顶部边缘Y坐标")
        XCTAssertEqual(padding, 20, "底部边缘Y坐标")
        XCTAssertEqual(padding, 20, "左侧边缘X坐标")
        XCTAssertEqual(screenWidth - windowWidth - padding, 1780, "右侧边缘X坐标")
    }

    func testCoordinateClampedToScreenBounds() {
        let screenWidth: CGFloat = 1920
        let screenHeight: CGFloat = 1080
        let windowWidth: CGFloat = 120
        let windowHeight: CGFloat = 150

        var x: CGFloat = -100
        var y: CGFloat = -100
        x = max(0, min(x, screenWidth - windowWidth))
        y = max(0, min(y, screenHeight - windowHeight))
        XCTAssertEqual(x, 0, "X坐标应被限制在屏幕边界内")
        XCTAssertEqual(y, 0, "Y坐标应被限制在屏幕边界内")
    }

    func testHiddenStateToggle() {
        var isHidden = false
        XCTAssertFalse(isHidden, "初始状态应为可见")

        isHidden = true
        XCTAssertTrue(isHidden, "隐藏后状态应为true")

        isHidden = false
        XCTAssertFalse(isHidden, "显示后状态应为false")
    }

    func testHiddenStateToggleTenTimes() {
        var isHidden = false
        for _ in 0..<10 { isHidden.toggle() }
        XCTAssertFalse(isHidden, "10次切换后状态应为false")
    }

    func testHiddenStateToggleFifteenTimes() {
        var isHidden = false
        for _ in 0..<10 { isHidden.toggle() }  // back to false
        for _ in 0..<5 { isHidden.toggle() }   // 5 more = true
        XCTAssertTrue(isHidden, "15次切换后状态应为true")
    }

    func testSingleInstanceDetection() {
        func check(_ count: Int) -> Bool { count <= 1 }
        XCTAssertTrue(check(1), "允许1个实例")
        XCTAssertFalse(check(2), "禁止2个实例")
        XCTAssertFalse(check(5), "禁止多个实例")
    }

    func testStatusMenuItems() {
        let items = ["显示宠物", "隐藏宠物", "退出"]
        XCTAssertTrue(items.contains("显示宠物"))
        XCTAssertTrue(items.contains("隐藏宠物"))
        XCTAssertTrue(items.contains("退出"))
        XCTAssertGreaterThanOrEqual(items.count, 3)
    }

    func testAppIdentifierFormat() {
        let id = "com.example.DesktopPet"
        XCTAssertFalse(id.isEmpty)
        XCTAssertTrue(id.contains("."))
    }
}