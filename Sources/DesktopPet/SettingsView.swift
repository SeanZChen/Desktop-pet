import SwiftUI

/// 设置界面 - emoji 选择 + 问候语管理 + 自定义图片上传
struct SettingsView: View {
    @ObservedObject var settings: SettingsModel
    @Environment(\.dismiss) private var dismiss

    // 问候语编辑状态
    @State private var editingIndex: Int?
    @State private var editText = ""
    @State private var newGreetingText = ""
    @State private var showingImagePicker = false
    @State private var isProcessingImage = false

    /// 最大问候语数量
    static let maxGreetings = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("桌宠设置")
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 14)

            Divider()
                .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    emojiSection
                    Divider()
                    sizeSection
                    Divider()
                    greetingsSection
                }
                .padding(24)
            }
        }
        .frame(width: 420, height: 600)
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                isProcessingImage = true
                processWithRembgAndResize(url: url) { processedData in
                    DispatchQueue.main.async {
                        self.isProcessingImage = false
                        if let data = processedData {
                            settings.petImageData = data
                            settings.addToRecent(data)
                        }
                    }
                }
            case .failure(let error):
                print("图片选择失败：\(error.localizedDescription)")
            }
        }
    }

    // MARK: - 宠物表情选择区域

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("宠物形象")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Emoji 选择网格
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(44), spacing: 10), count: 7),
                spacing: 10
            ) {
                // 近期形象（若有）
                if !settings.recentPetImages.isEmpty {
                    ForEach(Array(settings.recentPetImages.enumerated()), id: \.offset) { _, imageData in
                        recentImageCell(imageData)
                    }
                }

                ForEach(SettingsModel.availableEmojis, id: \.self) { emoji in
                    Button {
                        settings.petEmoji = emoji
                        settings.petImageData = nil
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(
                                settings.petEmoji == emoji && !settings.hasCustomImage
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        settings.petEmoji == emoji && !settings.hasCustomImage ? Color.accentColor : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // 自定义图片上传
            customImageSection
        }
    }

    // MARK: - 近期形象缩略图

    private func recentImageCell(_ imageData: Data) -> some View {
        let isSelected = (settings.petImageData == imageData)
        return Button {
            settings.petImageData = imageData
            settings.petEmoji = ""
        } label: {
            if let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
        .background(
            isSelected
                ? Color.accentColor.opacity(0.2)
                : Color.gray.opacity(0.1)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .help("近期使用的形象")
    }

    // MARK: - 宠物大小调整

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("宠物大小")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text("小")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 16)

                Slider(value: $settings.petScale, in: 0.5...2.0, step: 0.5)
                    .frame(width: 280)

                Text("大")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
            }
        }
    }

    // MARK: - 自定义图片区域

    private var customImageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("或者上传自定义图片")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if settings.hasCustomImage {
                    Button("清除") {
                        settings.petImageData = nil
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .font(.caption)
                }
            }

            HStack(spacing: 12) {
                // 预览区域
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)

                    if let imageData = settings.petImageData,
                       let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                Button {
                    showingImagePicker = true
                } label: {
                    if isProcessingImage {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("正在去除背景...")
                                .font(.system(size: 13, weight: .medium))
                            HStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("请稍候")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("选择图片...")
                                .font(.system(size: 13, weight: .medium))
                            Text("支持 PNG、JPG 格式，自动去除背景")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isProcessingImage)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .cornerRadius(10)
    }

    // MARK: - 问候语管理区域

    private var greetingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("打招呼语句")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(settings.greetings.count)/\(SettingsView.maxGreetings)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 添加新问候语
            if settings.greetings.count < SettingsView.maxGreetings {
                addGreetingRow
            }

            // 问候语列表
            if settings.greetings.isEmpty {
                Text("还没有问候语，点击上方添加")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
            } else {
                ForEach(Array(settings.greetings.enumerated()), id: \.offset) { index, greeting in
                    greetingRow(index: index, greeting: greeting)
                }
            }
        }
    }

    // MARK: - 添加问候语行

    private var addGreetingRow: some View {
        HStack(spacing: 6) {
            TextField("新增问候语...", text: $newGreetingText)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))

            Button("添加") {
                let trimmed = newGreetingText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                guard settings.greetings.count < SettingsView.maxGreetings else { return }
                settings.greetings.append(trimmed)
                newGreetingText = ""
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(newGreetingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - 单条问候语行

    private func greetingRow(index: Int, greeting: String) -> some View {
        HStack(spacing: 8) {
            if editingIndex == index {
                // 编辑模式
                TextField("编辑问候语...", text: $editText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onSubmit { saveEdit() }

                Button("保存") { saveEdit() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                Button("取消") {
                    editingIndex = nil
                    editText = ""
                }
                .controlSize(.small)
            } else {
                // 显示模式
                Text(greeting)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Button {
                    startEdit(index: index, text: greeting)
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("编辑")

                Button {
                    settings.greetings.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .help("删除")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.06))
        .cornerRadius(6)
    }

    // MARK: - 编辑操作

    private func startEdit(index: Int, text: String) {
        editingIndex = index
        editText = text
    }

    private func saveEdit() {
        guard let index = editingIndex else { return }
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        settings.greetings[index] = trimmed
        editingIndex = nil
        editText = ""
    }

    // MARK: - 图片处理

    /// 等比例缩放图片，保持宽高比，长边不超过 maxDimension
    private func resizeImageProportional(_ image: NSImage, maxDimension: CGFloat) -> NSImage? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let ratio = size.width / size.height
        let targetWidth: CGFloat
        let targetHeight: CGFloat

        if size.width >= size.height {
            targetWidth = min(size.width, maxDimension)
            targetHeight = targetWidth / ratio
        } else {
            targetHeight = min(size.height, maxDimension)
            targetWidth = targetHeight * ratio
        }

        let resized = NSImage(size: NSSize(width: targetWidth, height: targetHeight))
        resized.lockFocus()
        image.draw(
            in: NSRect(origin: .zero, size: resized.size),
            from: NSRect(origin: .zero, size: size),
            operation: .copy, fraction: 1.0
        )
        resized.unlockFocus()
        return resized
    }

    /// 纯本地回退：从原文件读取 → 等比例缩放 → 返回压缩数据
    private func resizeForPet(url: URL) -> Data? {
        guard let imageData = try? Data(contentsOf: url),
              let image = NSImage(data: imageData),
              let resized = resizeImageProportional(image, maxDimension: 200),
              let tiffData = resized.tiffRepresentation else { return nil }
        return tiffData
    }

    /// 图片上传完整流程：调用 venv rembg 脚本去背景 → 等比例缩放 → 返回处理后的图片数据
    private func processWithRembgAndResize(url: URL, completion: @escaping (Data?) -> Void) {
        let experimentsDir = "/Users/yumingqian/Desktop/coding/desktop-pet/experiments"
        let pythonBin = "\(experimentsDir)/venv/bin/python"
        let scriptPath = "\(experimentsDir)/remove_background.py"

        // 若 rembg 环境不可用，走本地回退
        guard FileManager.default.fileExists(atPath: pythonBin),
              FileManager.default.fileExists(atPath: scriptPath) else {
            completion(resizeForPet(url: url))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("deskpet_\(UUID().uuidString.prefix(8))")
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let inputFile = tempDir.appendingPathComponent("input.png")
            let outputFile = tempDir.appendingPathComponent("output.png")

            // 将原图保存为 PNG 到临时目录
            if let image = NSImage(contentsOf: url),
               let tiff = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiff) {
                try? bitmap.representation(using: .png, properties: [:])?.write(to: inputFile)
            } else {
                try? Data(contentsOf: url).write(to: inputFile)
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: pythonBin)
            process.arguments = [scriptPath, inputFile.path, outputFile.path]
            process.currentDirectoryURL = URL(fileURLWithPath: experimentsDir)
            process.standardOutput = Pipe()
            process.standardError = Pipe()

            var env = ProcessInfo.processInfo.environment
            env["DYLD_LIBRARY_PATH"] = "/usr/local/opt/libomp/lib:/usr/local/opt/llvm@20/lib"
            process.environment = env

            do {
                try process.run()
                process.waitUntilExit()

                guard process.terminationStatus == 0,
                      let processedData = try? Data(contentsOf: outputFile),
                      let image = NSImage(data: processedData),
                      let resized = self.resizeImageProportional(image, maxDimension: 200),
                      let finalData = resized.tiffRepresentation else {
                    // rembg 失败 → 回退
                    completion(self.resizeForPet(url: url))
                    return
                }
                completion(finalData)
            } catch {
                completion(self.resizeForPet(url: url))
            }
        }
    }
}