import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {
    init(onShortcutChange: @escaping (Shortcut) -> Void) {
        let contentView = SettingsView(onShortcutChange: onShortcutChange)
        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hostingController)

        window.title = "设置"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.titleVisibility = .visible
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.center()
        window.setContentSize(NSSize(width: 320, height: 140))

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindow() {
        guard let window else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)

        if window.isMiniaturized {
            window.deminiaturize(nil)
        }

        window.makeKeyAndOrderFront(nil)
    }
}
