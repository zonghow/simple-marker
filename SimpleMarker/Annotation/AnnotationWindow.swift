import AppKit

final class AnnotationWindow: NSWindow {
    init(screen: NSScreen, onEscape: @escaping () -> Void) {
        let canvasView = AnnotationCanvasView(frame: NSRect(origin: .zero, size: screen.frame.size))
        canvasView.onEscape = onEscape

        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        contentView = canvasView
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .screenSaver
        ignoresMouseEvents = false
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
