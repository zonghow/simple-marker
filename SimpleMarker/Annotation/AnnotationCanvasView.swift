import AppKit
import Carbon.HIToolbox

final class AnnotationCanvasView: NSView {
    private struct Stroke: Equatable {
        let id: UUID
        var points: [CGPoint]
    }

    private enum HistoryAction {
        case add(Stroke)
        case remove(Stroke, index: Int)
    }

    var onEscape: (() -> Void)?

    private let strokeLineWidth: CGFloat = 4
    private let dotDiameter: CGFloat = 6
    private let eraserHitWidth: CGFloat = 18

    private var strokes: [Stroke] = []
    private var historyActions: [HistoryAction] = []
    private var redoActions: [HistoryAction] = []
    private var currentStroke: Stroke?
    private var trackingArea: NSTrackingArea?
    private var isErasing = false
    private var lastErasePoint: CGPoint?

    override var acceptsFirstResponder: Bool {
        true
    }

    override var isOpaque: Bool {
        false
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
        window?.invalidateCursorRects(for: self)
        NSCursor.crosshair.set()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [
            .activeAlways,
            .inVisibleRect,
            .mouseEnteredAndExited,
            .mouseMoved,
            .cursorUpdate
        ]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: activeCursor)
    }

    override func cursorUpdate(with event: NSEvent) {
        activeCursor.set()
    }

    override func mouseEntered(with event: NSEvent) {
        activeCursor.set()
    }

    override func mouseMoved(with event: NSEvent) {
        activeCursor.set()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        currentStroke = Stroke(id: UUID(), points: [point])
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard currentStroke != nil else {
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        currentStroke?.points.append(point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard var currentStroke else {
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        if currentStroke.points.last != point {
            currentStroke.points.append(point)
        }

        commitStroke(currentStroke)
        self.currentStroke = nil
        needsDisplay = true
    }

    override func rightMouseDown(with event: NSEvent) {
        isErasing = true
        updateCursor()

        let point = convert(event.locationInWindow, from: nil)
        lastErasePoint = point
        eraseStrokesAlongPath(from: point, to: point)
    }

    override func rightMouseDragged(with event: NSEvent) {
        updateCursor()

        let point = convert(event.locationInWindow, from: nil)
        let startPoint = lastErasePoint ?? point
        eraseStrokesAlongPath(from: startPoint, to: point)
        lastErasePoint = point
    }

    override func rightMouseUp(with event: NSEvent) {
        isErasing = false
        lastErasePoint = nil
        updateCursor()
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])

        if event.keyCode == UInt16(kVK_Escape) {
            onEscape?()
            return
        }

        if modifiers == [.command, .shift], event.charactersIgnoringModifiers?.lowercased() == "z" {
            redoLastAction()
            return
        }

        if modifiers == [.command], event.charactersIgnoringModifiers?.lowercased() == "z" {
            undoLastAction()
            return
        }

        super.keyDown(with: event)
    }

    private func commitStroke(_ stroke: Stroke) {
        strokes.append(stroke)
        historyActions.append(.add(stroke))
        redoActions.removeAll()
    }

    private func eraseStrokesAlongPath(from startPoint: CGPoint, to endPoint: CGPoint) {
        let touchedStrokeIDs = Set(sampledPoints(from: startPoint, to: endPoint).compactMap { point in
            strokeID(at: point)
        })

        guard !touchedStrokeIDs.isEmpty else {
            return
        }

        let removals = strokes.enumerated()
            .filter { touchedStrokeIDs.contains($0.element.id) }
            .map { ($0.offset, $0.element) }
            .reversed()

        for (index, stroke) in removals {
            strokes.remove(at: index)
            historyActions.append(.remove(stroke, index: index))
        }

        redoActions.removeAll()
        needsDisplay = true
    }

    private func sampledPoints(from startPoint: CGPoint, to endPoint: CGPoint) -> [CGPoint] {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let distance = hypot(deltaX, deltaY)

        guard distance > 0 else {
            return [startPoint]
        }

        let step = max(eraserHitWidth / 2, 1)
        let segmentCount = max(Int(ceil(distance / step)), 1)

        return (0...segmentCount).map { index in
            let progress = CGFloat(index) / CGFloat(segmentCount)
            return CGPoint(
                x: startPoint.x + deltaX * progress,
                y: startPoint.y + deltaY * progress
            )
        }
    }

    private func strokeID(at point: CGPoint) -> UUID? {
        strokes.indices.reversed().first { index in
            stroke(at: strokes[index], contains: point)
        }.map { strokes[$0].id }
    }

    private func stroke(at stroke: Stroke, contains point: CGPoint) -> Bool {
        guard let firstPoint = stroke.points.first else {
            return false
        }

        if stroke.points.count == 1 {
            return hypot(point.x - firstPoint.x, point.y - firstPoint.y) <= eraserHitWidth / 2
        }

        let hitPath = smoothedPath(for: stroke.points).copy(
            strokingWithWidth: strokeLineWidth + eraserHitWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 10
        )
        return hitPath.contains(point)
    }

    private func undoLastAction() {
        guard let action = historyActions.popLast() else {
            return
        }

        applyInverse(of: action)
        redoActions.append(action)
        needsDisplay = true
    }

    private func redoLastAction() {
        guard let action = redoActions.popLast() else {
            return
        }

        apply(action)
        historyActions.append(action)
        needsDisplay = true
    }

    private func apply(_ action: HistoryAction) {
        switch action {
        case .add(let stroke):
            strokes.append(stroke)
        case .remove(let stroke, _):
            removeStroke(withID: stroke.id)
        }
    }

    private func applyInverse(of action: HistoryAction) {
        switch action {
        case .add(let stroke):
            removeStroke(withID: stroke.id)
        case .remove(let stroke, let index):
            let insertionIndex = min(index, strokes.count)
            strokes.insert(stroke, at: insertionIndex)
        }
    }

    private func removeStroke(withID id: UUID) {
        guard let index = strokes.firstIndex(where: { $0.id == id }) else {
            return
        }

        strokes.remove(at: index)
    }

    private func updateCursor() {
        window?.invalidateCursorRects(for: self)
        activeCursor.set()
    }

    private var activeCursor: NSCursor {
        isErasing ? .openHand : .crosshair
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let strokeColor = NSColor.systemRed.withAlphaComponent(0.95)
        strokeColor.setFill()

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(strokeLineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        for stroke in renderedStrokes {
            guard let firstPoint = stroke.points.first else {
                continue
            }

            if stroke.points.count == 1 {
                let dotRect = NSRect(
                    x: firstPoint.x - dotDiameter / 2,
                    y: firstPoint.y - dotDiameter / 2,
                    width: dotDiameter,
                    height: dotDiameter
                )
                NSBezierPath(ovalIn: dotRect).fill()
                continue
            }

            context.addPath(smoothedPath(for: stroke.points))
            context.strokePath()
        }
    }

    private var renderedStrokes: [Stroke] {
        guard let currentStroke else {
            return strokes
        }

        return strokes + [currentStroke]
    }

    private func smoothedPath(for points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        path.move(to: points[0])

        guard points.count > 2 else {
            path.addLine(to: points[1])
            return path
        }

        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let midpoint = CGPoint(
                x: (previous.x + current.x) / 2,
                y: (previous.y + current.y) / 2
            )

            if index == 1 {
                path.addLine(to: midpoint)
            } else {
                path.addQuadCurve(to: midpoint, control: previous)
            }
        }

        path.addLine(to: points[points.count - 1])
        return path
    }
}
