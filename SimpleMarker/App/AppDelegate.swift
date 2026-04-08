import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let annotationController = AnnotationController()
    private let hotkeyManager = HotkeyManager()
    private let loginItemManager = LoginItemManager()

    private lazy var settingsWindowController = SettingsWindowController { [weak self] shortcut in
        Shortcut.save(shortcut)
        self?.hotkeyManager.register(shortcut: shortcut)
    }

    private lazy var statusItemController = StatusItemController(
        onStartAnnotation: { [weak self] in
            self?.annotationController.startAnnotation()
        },
        onOpenSettings: { [weak self] in
            self?.settingsWindowController.showWindow()
        },
        onToggleLaunchAtLogin: { [weak self] in
            self?.toggleLaunchAtLogin()
        },
        isLaunchAtLoginEnabled: { [weak self] in
            self?.loginItemManager.isEnabled ?? false
        }
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        _ = statusItemController

        hotkeyManager.onHotKey = { [weak self] in
            self?.annotationController.startAnnotation()
        }
        hotkeyManager.register(shortcut: Shortcut.load())
    }

    private func toggleLaunchAtLogin() {
        do {
            try loginItemManager.toggle()
        } catch {
            presentAlert(
                message: "无法切换开机启动",
                informativeText: error.localizedDescription
            )
        }
    }

    private func presentAlert(message: String, informativeText: String) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "好")
        alert.runModal()
    }
}
