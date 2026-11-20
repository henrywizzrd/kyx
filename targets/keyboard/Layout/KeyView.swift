import UIKit

/// Một phím. Chỉ vẽ, không tự xử lý chạm (KeyboardView xử lý chạm cho cả bàn phím).
final class KeyView: UIView {
    let spec: KeySpec
    private let label = UILabel()
    private let icon = UIImageView()

    var palette = Palette.dark { didSet { applyColors() } }
    var isPressed = false { didSet { if oldValue != isPressed { applyColors() } } }
    /// Phím Shift đang bật: nền sáng, chữ tối (giống iOS).
    var isActive = false { didSet { if oldValue != isActive { applyColors() } } }
    var contentAlpha: CGFloat = 1 { didSet { label.alpha = contentAlpha; icon.alpha = contentAlpha } }

    var isFunction: Bool {
        switch spec.kind {
        case .char, .space: return false
        default: return true
        }
    }

    init(spec: KeySpec) {
        self.spec = spec
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.cornerRadius = 9
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)

        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        icon.contentMode = .center
        addSubview(label)
        addSubview(icon)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setText(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, subtle: Bool = false) {
        icon.isHidden = true
        label.isHidden = false
        label.text = text
        label.font = .systemFont(ofSize: size, weight: weight)
        labelIsSubtle = subtle
        applyColors()
    }

    func setSymbol(_ name: String, pointSize: CGFloat = 20) {
        label.isHidden = true
        icon.isHidden = false
        icon.image = UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular))
        applyColors()
    }

    private var labelIsSubtle = false

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.insetBy(dx: 2, dy: 0)
        icon.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 9).cgPath
    }

    private func applyColors() {
        let base = isFunction ? palette.function : palette.key
        backgroundColor = isActive ? palette.text : (isPressed ? palette.pressed : base)
        let fg = isActive ? palette.panel : palette.text
        label.textColor = labelIsSubtle ? palette.subtle : fg
        icon.tintColor = fg
    }
}

/// Bóng chữ phóng to hiện phía trên phím khi chạm.
final class KeyPopupView: UIView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isHidden = true
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 4
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() { super.layoutSubviews(); label.frame = bounds }
}

/// Hàng chữ có dấu khi giữ phím.
final class AltsView: UIView {
    static let cellWidth: CGFloat = 36
    static let cellHeight: CGFloat = 44
    private var labels: [UILabel] = []
    private(set) var items: [String] = []
    private(set) var selected = 0
    var palette = Palette.dark

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isHidden = true
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 6
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func show(_ items: [String]) {
        self.items = items
        labels.forEach { $0.removeFromSuperview() }
        labels = items.enumerated().map { i, text in
            let l = UILabel(frame: CGRect(x: 4 + CGFloat(i) * Self.cellWidth, y: 4, width: Self.cellWidth - 2, height: Self.cellHeight))
            l.text = text
            l.textAlignment = .center
            l.font = .systemFont(ofSize: 24)
            l.layer.cornerRadius = 7
            l.layer.masksToBounds = true
            addSubview(l)
            return l
        }
        backgroundColor = palette.key
        select(0)
        isHidden = false
    }

    var preferredSize: CGSize {
        CGSize(width: CGFloat(items.count) * Self.cellWidth + 8, height: Self.cellHeight + 8)
    }

    func select(atX x: CGFloat) {
        let i = Int(((x - frame.minX - 4) / Self.cellWidth).rounded(.down))
        select(max(0, min(items.count - 1, i)))
    }

    private func select(_ i: Int) {
        selected = i
        for (j, l) in labels.enumerated() {
            l.backgroundColor = j == i ? palette.accent : .clear
            l.textColor = j == i ? .white : palette.text
        }
    }

    func hide() { isHidden = true }
}

/// Nhãn nhỏ phía trên phím ⌫ cho biết sẽ xoá những gì khi vuốt.
final class BubbleView: UIView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isHidden = true
        layer.cornerRadius = 8
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byTruncatingHead
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() { super.layoutSubviews(); label.frame = bounds.insetBy(dx: 10, dy: 0) }
}
