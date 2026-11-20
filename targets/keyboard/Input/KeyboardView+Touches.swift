import UIKit

/// Trạng thái của một ngón tay đang chạm. Hằng số cử chỉ theo ADR-009.
final class TouchState {
    let index: Int
    let start: CGPoint
    var lastX: CGFloat
    var lastY: CGFloat
    var timer: Timer?
    var repeatTimer: Timer?
    var altsShown = false
    var selectingWords = 0
    var trackpad = false

    init(index: Int, start: CGPoint) {
        self.index = index
        self.start = start
        lastX = start.x
        lastY = start.y
    }

    func invalidate() {
        timer?.invalidate(); timer = nil
        repeatTimer?.invalidate(); repeatTimer = nil
    }
}

extension KeyboardView {
    enum Gesture {
        static let longPress: TimeInterval = 0.4
        static let deleteRepeatDelay: TimeInterval = 0.45
        static let deleteRepeatInterval: TimeInterval = 0.08
        static let deleteSwipeStart: CGFloat = 20
        static let deleteSwipePerWord: CGFloat = 24
        static let trackpadHold: TimeInterval = 0.35
        static let trackpadDrag: CGFloat = 12
        static let trackpadStepX: CGFloat = 9
        static let trackpadStepY: CGFloat = 28
        static let doubleTapShift: CFTimeInterval = 0.3
    }

    func handleBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let p = touch.location(in: self)
            guard let i = keyIndex(at: p) else { continue }
            let kv = keyViews[i]
            let state = TouchState(index: i, start: p)

            switch kv.spec.kind {
            case .char(let c):
                commitPendingChars()                 // gõ nhanh bằng 2 ngón: chốt chữ trước
                kv.isPressed = true
                showPopup(for: kv, text: display(c))
                delegate?.keyboardFeedback()
                if page == .letters, let items = KeyLayout.alternates[c] {
                    state.timer = Timer.scheduledTimer(withTimeInterval: Gesture.longPress, repeats: false) { [weak self, weak state] _ in
                        guard let self, let state else { return }
                        state.altsShown = true
                        kv.isPressed = false
                        self.showAlts(for: kv, items: items.map { self.display($0) })
                    }
                }
            case .delete:
                kv.isPressed = true
                delegate?.keyboardFeedback()
                delegate?.keyboardDeleteBackward()
                state.timer = Timer.scheduledTimer(withTimeInterval: Gesture.deleteRepeatDelay, repeats: false) { [weak self, weak state] _ in
                    state?.repeatTimer = Timer.scheduledTimer(withTimeInterval: Gesture.deleteRepeatInterval, repeats: true) { _ in
                        self?.delegate?.keyboardDeleteBackward()
                    }
                }
            case .space:
                kv.isPressed = true
                delegate?.keyboardFeedback()
                state.timer = Timer.scheduledTimer(withTimeInterval: Gesture.trackpadHold, repeats: false) { [weak self, weak state] _ in
                    guard let self, let state else { return }
                    self.enterTrackpad(state)
                }
            case .shift:
                let now = CACurrentMediaTime()
                shift = now - lastShiftTap < Gesture.doubleTapShift ? .lock : (shift == .off ? .once : .off)
                lastShiftTap = now
                delegate?.keyboardFeedback()
            case .globe:
                delegate?.keyboardGlobe(from: self, with: event)
            case .ret, .lang, .page:
                kv.isPressed = true
                delegate?.keyboardFeedback()
            }
            activeTouches[ObjectIdentifier(touch)] = state
        }
    }

    func handleMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let state = activeTouches[ObjectIdentifier(touch)] else { continue }
            let p = touch.location(in: self)
            switch keyViews[state.index].spec.kind {
            case .char where state.altsShown:
                alts.select(atX: p.x)
            case .delete:
                moveDelete(state, to: p)
            case .space:
                moveSpace(state, to: p)
            case .globe:
                delegate?.keyboardGlobe(from: self, with: event)
            default:
                break
            }
        }
    }

    func handleEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let state = activeTouches.removeValue(forKey: ObjectIdentifier(touch)) else { continue }
            finish(state, event: event, perform: true)
        }
    }

    func handleCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let state = activeTouches.removeValue(forKey: ObjectIdentifier(touch)) else { continue }
            finish(state, event: event, perform: false)
        }
    }

    // MARK: - Kết thúc chạm

    private func finish(_ state: TouchState, event: UIEvent?, perform: Bool) {
        state.invalidate()
        guard state.index < keyViews.count else { return }
        let kv = keyViews[state.index]
        kv.isPressed = false

        switch kv.spec.kind {
        case .char(let c):
            let text = state.altsShown ? alts.items[alts.selected] : display(c)
            popup.isHidden = true
            alts.hide()
            if perform { typeChar(text, raw: state.altsShown) }
        case .delete:
            bubble.isHidden = true
            if perform && state.selectingWords > 0 { delegate?.keyboardDeleteWords(state.selectingWords) }
            delegate?.keyboardDidFinishEdit()
        case .space:
            if state.trackpad {
                isTrackpad = false
            } else if perform {
                delegate?.keyboardSpace()
            }
            delegate?.keyboardDidFinishEdit()
        case .ret:
            if perform { delegate?.keyboardReturn(); delegate?.keyboardDidFinishEdit() }
        case .lang:
            if perform { delegate?.keyboardToggleLanguage() }
        case .page(let target):
            if perform { page = target; delegate?.keyboardDidFinishEdit() }
        case .globe:
            delegate?.keyboardGlobe(from: self, with: event)
        case .shift:
            break
        }
    }

    private func typeChar(_ text: String, raw: Bool) {
        delegate?.keyboardInsertLetter(text, raw: raw)
        if shift == .once { shift = .off }
    }

    /// Ngón thứ hai chạm xuống khi ngón đầu chưa nhấc: chốt chữ của ngón đầu ngay.
    private func commitPendingChars() {
        for (id, state) in activeTouches {
            guard case .char(let c) = keyViews[state.index].spec.kind, !state.altsShown else { continue }
            state.invalidate()
            keyViews[state.index].isPressed = false
            activeTouches.removeValue(forKey: id)
            typeChar(display(c), raw: false)
        }
        popup.isHidden = true
    }

    // MARK: - ⌫: vuốt trái để chọn từng từ

    private func moveDelete(_ state: TouchState, to p: CGPoint) {
        let dx = p.x - state.start.x
        if dx < -Gesture.deleteSwipeStart {
            state.invalidate()
            let words = 1 + Int((-dx - Gesture.deleteSwipeStart) / Gesture.deleteSwipePerWord)
            guard words != state.selectingWords else { return }
            state.selectingWords = words
            let preview = delegate?.keyboardTextBeforeCursor(words: words) ?? ""
            showBubble(above: keyViews[state.index], text: preview.isEmpty ? "Không còn gì để xoá" : "Xoá: \(preview)")
            delegate?.keyboardFeedback()
        } else if state.selectingWords > 0 {
            state.selectingWords = 0
            bubble.isHidden = true
        }
    }

    // MARK: - Phím cách: trackpad 4 hướng

    private func enterTrackpad(_ state: TouchState) {
        guard !state.trackpad else { return }
        state.timer?.invalidate()
        state.trackpad = true
        isTrackpad = true
        delegate?.keyboardFeedback()
    }

    private func moveSpace(_ state: TouchState, to p: CGPoint) {
        if !state.trackpad && abs(p.x - state.start.x) > Gesture.trackpadDrag {
            enterTrackpad(state)
        }
        guard state.trackpad else { return }
        while p.x - state.lastX >= Gesture.trackpadStepX { delegate?.keyboardMoveCaret(1); state.lastX += Gesture.trackpadStepX }
        while state.lastX - p.x >= Gesture.trackpadStepX { delegate?.keyboardMoveCaret(-1); state.lastX -= Gesture.trackpadStepX }
        while p.y - state.lastY >= Gesture.trackpadStepY { delegate?.keyboardMoveLine(1); state.lastY += Gesture.trackpadStepY }
        while state.lastY - p.y >= Gesture.trackpadStepY { delegate?.keyboardMoveLine(-1); state.lastY -= Gesture.trackpadStepY }
    }
}
