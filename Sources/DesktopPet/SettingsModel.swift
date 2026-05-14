import Foundation
import Combine
import AppKit

/// 设置数据模型 - 管理宠物表情和问候语，持久化到 UserDefaults
class SettingsModel: ObservableObject {
    /// 当前选中的宠物表情
    @Published var petEmoji: String {
        didSet { UserDefaults.standard.set(petEmoji, forKey: "petEmoji") }
    }

    /// 自定义宠物图片（TIFF 编码）
    @Published var petImageData: Data? {
        didSet {
            if let data = petImageData {
                UserDefaults.standard.set(data, forKey: "petImageData")
            } else {
                UserDefaults.standard.removeObject(forKey: "petImageData")
            }
        }
    }

    /// 宠物缩放比例（0.5=小, 1.0=中, 2.0=大）
    @Published var petScale: Double {
        didSet { UserDefaults.standard.set(petScale, forKey: "petScale") }
    }

    /// 近期使用的自定义形象（最多 5 个）
    @Published var recentPetImages: [Data] {
        didSet {
            let encoded = recentPetImages.compactMap { $0.base64EncodedString() }
            UserDefaults.standard.set(encoded, forKey: "recentPetImages")
        }
    }

    /// 是否使用自定义图片
    var hasCustomImage: Bool {
        petImageData != nil && !petImageData!.isEmpty
    }

    /// 问候语列表
    @Published var greetings: [String] {
        didSet { UserDefaults.standard.set(greetings, forKey: "greetings") }
    }

    /// 预设的宠物表情选项
    static let availableEmojis = [
        "🐱", "🐶", "🐰", "🐻", "🐼", "🐨", "🦊", "🐸",
        "🐵", "🐮", "🐷", "🐭", "🐹", "🐯", "🦁", "🐙",
    ]

    /// 默认问候语
    static let defaultGreetings = [
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

    init() {
        self.petEmoji = UserDefaults.standard.string(forKey: "petEmoji") ?? "🐱"
        self.petImageData = UserDefaults.standard.data(forKey: "petImageData")
        self.petScale = UserDefaults.standard.object(forKey: "petScale") as? Double ?? 1.0
        self.recentPetImages = Self.loadRecentImages()
        self.greetings = UserDefaults.standard.stringArray(forKey: "greetings") ?? SettingsModel.defaultGreetings

        if greetings.isEmpty {
            greetings = SettingsModel.defaultGreetings
        }
    }

    /// 将自定义图片加入近期记录（去重，最多保留 5 个）
    func addToRecent(_ imageData: Data) {
        recentPetImages.removeAll { $0 == imageData }
        recentPetImages.insert(imageData, at: 0)
        if recentPetImages.count > 5 {
            recentPetImages = Array(recentPetImages.prefix(5))
        }
    }

    private static func loadRecentImages() -> [Data] {
        guard let encoded = UserDefaults.standard.stringArray(forKey: "recentPetImages") else { return [] }
        return encoded.compactMap { Data(base64Encoded: $0) }.filter { data in
            // 过滤掉损坏的数据
            NSImage(data: data) != nil
        }
    }
}