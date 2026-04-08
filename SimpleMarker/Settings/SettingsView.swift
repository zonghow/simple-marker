import SwiftUI

struct SettingsView: View {
    @State private var shortcut = Shortcut.load()
    let onShortcutChange: (Shortcut) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快捷键")
                .font(.headline)

            ShortcutRecorderView(shortcut: $shortcut, onChange: onShortcutChange)

            Text("点击上方控件后，按下新的组合键进行录制。按 Esc 可取消录制。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 320)
    }
}
