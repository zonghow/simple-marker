import AppKit

final class AnnotationController {
    private var annotationWindow: AnnotationWindow?

    func startAnnotation() {
        guard annotationWindow == nil else {
            return
        }

        guard let screen = screenContainingMouse() else {
            return
        }

        let window = AnnotationWindow(screen: screen) { [weak self] in
            self?.stopAnnotation()
        }

        annotationWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    func stopAnnotation() {
        annotationWindow?.orderOut(nil)
        annotationWindow?.close()
        annotationWindow = nil
        NSCursor.arrow.set()
    }

    private func screenContainingMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation

        return NSScreen.screens.first {
            NSMouseInRect(mouseLocation, $0.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first
    }
}
