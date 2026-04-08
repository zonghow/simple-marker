import Carbon.HIToolbox
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: Shortcut
    let onChange: (Shortcut) -> Void

    @State private var isRecording = false
    @State private var eventMonitor: Any?

    var body: some View {
        Button(action: toggleRecording) {
            HStack(spacing: 8) {
                Image(systemName: isRecording ? "keyboard.badge.ellipsis" : "keyboard")
                Text(isRecording ? "请按下快捷键" : shortcut.displayString)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 220)
            .background(isRecording ? Color.accentColor.opacity(0.12) : Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isRecording ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onDisappear(perform: stopRecording)
    }

    private func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        stopRecording()
        isRecording = true

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }

            guard let capturedShortcut = Shortcut.capture(from: event) else {
                return nil
            }

            shortcut = capturedShortcut
            onChange(capturedShortcut)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false

        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}
