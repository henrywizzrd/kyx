import UIKit

enum ShiftState { case off, once, lock }

/// KeyboardView gọi các hàm này. KeyboardViewController thực hiện chúng qua textDocumentProxy.
protocol KeyboardViewDelegate: AnyObject {
    func keyboardFeedback()
    func keyboardInsertLetter(_ text: String, raw: Bool)
    func keyboardDeleteBackward()
    func keyboardTextBeforeCursor(words: Int) -> String
    func keyboardDeleteWords(_ count: Int)
    func keyboardMoveCaret(_ offset: Int)
    func keyboardMoveLine(_ direction: Int)
    func keyboardSpace()
    func keyboardReturn()
    func keyboardToggleLanguage()
    func keyboardDidFinishEdit()
    func keyboardGlobe(from view: UIView, with event: UIEvent?)
}

/// Vẽ toàn bộ bàn phím và nhận mọi lần chạm (xem KeyboardView+Touches.swift).
final class KeyboardView: UIView {
    static let rowGap: CGFloat = 11
    static let topInset: CGFloat = 10
    static let bottomInset: CGFloat = 8

    weak var delegate: KeyboardViewDelegate?

    var page: KeyPage = .letters { didSet { if oldValue != page { rebuild() } } }
    var shift: ShiftState = .off { didSet { if oldValue != shift { refreshLabels() } } }
    var language = "VI" { didSet { if oldValue != language { refreshLabels() } } }
    var palette = Palette.dark { didSet { applyPalette() } }
    var keyHeight: CGFloat = 46 { didSet { setNeedsLayout() } }
    var showsGlobe = false { didSet { if oldValue != showsGlobe { rebuild() } } }

    var preferredHeight: CGFloat {
        Self.topInset + Self.bottomInset + 4 * keyHeight + 3 * Self.rowGap
    }

    private(set) var keyViews: [KeyView] = []
    let popup = KeyPopupView()
    let alts = AltsView()
    let bubble = BubbleView()

    // Trạng thái chạm, dùng trong KeyboardView+Touches.swift
    var activeTouches: [ObjectIdentifier: TouchState] = [:]
    var lastShiftTap: CFTimeInterval = 0
    var isTrackpad = false {
        didSet { keyViews.forEach { $0.contentAlpha = isTrackpad ? 0 : 1 } }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        addSubview(popup)
        addSubview(alts)
        addSubview(bubble)
        rebuild()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Chạm (xử lý trong Input/KeyboardView+Touches.swift)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { handleBegan(touches, with: event) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { handleMoved(touches, with: event) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { handleEnded(touches, with: event) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { handleCancelled(touches, with: event) }

    // MARK: - Dựng phím

    func rebuild() {
        keyViews.forEach { $0.removeFromSuperview() }
        keyViews = KeyLayout.rows(page, showsGlobe: showsGlobe).enumerated().flatMap { r, row in
            row.map { spec -> KeyView in
                let kv = KeyView(spec: spec)
                kv.tag = r
                insertSubview(kv, belowSubview: popup)
                return kv
            }
        }
        refreshLabels()
        applyPalette()
        setNeedsLayout()
    }

    func display(_ c: String) -> String {
        page == .letters && shift != .off ? c.uppercased() : c
    }

    func refreshLabels() {
        let letterSize: CGFloat = page == .letters ? 25 : 22
        for kv in keyViews {
            kv.isActive = false
            switch kv.spec.kind {
            case .char(let c):
                kv.setText(display(c), size: letterSize)
            case .shift:
                kv.setSymbol(shift == .lock ? "capslock.fill" : shift == .once ? "shift.fill" : "shift")
                kv.isActive = shift != .off
            case .delete:
                kv.setSymbol("delete.left")
            case .space:
                kv.setText(language, size: 15, weight: .semibold, subtle: true)
            case .ret:
                kv.setSymbol("return")
            case .lang:
                kv.setText(language == "VI" ? "EN" : "VI", size: 16, weight: .medium)
            case .globe:
                kv.setSymbol("globe")
            case .page(let p):
                kv.setText(p == .letters ? "ABC" : p == .numbers ? "123" : "#+=", size: 17, weight: .medium)
            }
        }
    }

    private func applyPalette() {
        backgroundColor = palette.panel
        keyViews.forEach { $0.palette = palette }
        popup.backgroundColor = palette.key
        popup.label.textColor = palette.text
        alts.palette = palette
        bubble.backgroundColor = palette.function
        bubble.label.textColor = palette.text
    }

    // MARK: - Bố cục

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        let pad = width * 0.012
        let gap = width * 0.016
        let unit = (width - 2 * pad - 9 * gap) / 10
        let rows = Dictionary(grouping: keyViews, by: { $0.tag })

        for r in 0..<4 {
            guard let row = rows[r] else { continue }
            let y = Self.topInset + CGFloat(r) * (keyHeight + Self.rowGap)
            let fixed = row.compactMap { $0.spec.width }.reduce(0, +) * unit
            let flexCount = row.filter { $0.spec.width == nil }.count
            let gaps = CGFloat(row.count - 1) * gap
            let flexWidth = flexCount > 0 ? max(unit, (width - 2 * pad - fixed - gaps) / CGFloat(flexCount)) : 0
            let total = fixed + flexWidth * CGFloat(flexCount) + gaps
            var x = (width - total) / 2
            for kv in row {
                let w = kv.spec.width.map { $0 * unit } ?? flexWidth
                kv.frame = CGRect(x: x, y: y, width: w, height: keyHeight)
                x += w + gap
            }
        }
    }

    /// Phím gần điểm chạm nhất (vùng chạm phủ cả khe giữa các phím).
    func keyIndex(at point: CGPoint) -> Int? {
        var best: (Int, CGFloat)?
        for (i, kv) in keyViews.enumerated() {
            let f = kv.frame.insetBy(dx: -bounds.width * 0.008, dy: -Self.rowGap / 2)
            if f.contains(point) { return i }
            let dx = max(f.minX - point.x, 0, point.x - f.maxX)
            let dy = max(f.minY - point.y, 0, point.y - f.maxY)
            let d = dx * dx + dy * dy
            if best == nil || d < best!.1 { best = (i, d) }
        }
        return best?.0
    }

    // MARK: - Bóng chữ, hàng dấu, nhãn xoá

    func showPopup(for kv: KeyView, text: String) {
        let w = kv.frame.width + 14
        let h = keyHeight + 8
        let x = min(max(0, kv.frame.midX - w / 2), bounds.width - w)
        popup.frame = CGRect(x: x, y: max(0, kv.frame.minY - h - 2), width: w, height: h)
        popup.label.text = text
        popup.isHidden = false
    }

    func showAlts(for kv: KeyView, items: [String]) {
        popup.isHidden = true
        alts.show(items)
        let size = alts.preferredSize
        let x = min(max(2, kv.frame.minX - 4), bounds.width - size.width - 2)
        alts.frame = CGRect(origin: CGPoint(x: x, y: max(0, kv.frame.minY - size.height - 2)), size: size)
    }

    func showBubble(above kv: KeyView, text: String) {
        bubble.label.text = text
        let w = min(bounds.width * 0.7, bubble.label.intrinsicContentSize.width + 20)
        bubble.frame = CGRect(x: max(4, kv.frame.maxX - w), y: max(0, kv.frame.minY - 38), width: w, height: 32)
        bubble.isHidden = false
    }
}
