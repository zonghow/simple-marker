import AppKit

final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let onStartAnnotation: () -> Void
    private let onOpenSettings: () -> Void
    private let onToggleLaunchAtLogin: () -> Void
    private let isLaunchAtLoginEnabled: () -> Bool

    init(
        onStartAnnotation: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void,
        onToggleLaunchAtLogin: @escaping () -> Void,
        isLaunchAtLoginEnabled: @escaping () -> Bool
    ) {
        self.onStartAnnotation = onStartAnnotation
        self.onOpenSettings = onOpenSettings
        self.onToggleLaunchAtLogin = onToggleLaunchAtLogin
        self.isLaunchAtLoginEnabled = isLaunchAtLoginEnabled
        super.init()
        configureStatusItem()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            systemSymbolName: "pencil.tip.crop.circle",
            accessibilityDescription: "SimpleMarker"
        )
        button.image?.isTemplate = true
        button.target = self
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func handleClick(_ sender: Any?) {
        switch NSApp.currentEvent?.type {
        case .rightMouseUp:
            showContextMenu()
        default:
            onStartAnnotation()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let launchItem = NSMenuItem(title: "开机启动", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    @objc private func toggleLaunchAtLogin() {
        onToggleLaunchAtLogin()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
