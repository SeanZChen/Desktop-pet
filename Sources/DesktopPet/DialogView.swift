import SwiftUI

/// 对话框视图 - 显示打招呼文本，支持自动换行和自适应大小
struct DialogView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 180, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.75))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
            )
    }
}