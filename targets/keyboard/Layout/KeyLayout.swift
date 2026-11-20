import CoreGraphics

enum KeyPage { case letters, numbers, symbols }

enum KeyKind: Equatable {
    case char(String)
    case shift, delete, space, ret, lang, globe
    case page(KeyPage)
}

/// `width` tính theo đơn vị = bề rộng 1 phím chữ. `nil` = co giãn chia đều phần còn lại.
struct KeySpec {
    let kind: KeyKind
    let width: CGFloat?
}

enum KeyLayout {
    /// Chữ có dấu khi giữ phím (trang chữ).
    static let alternates: [String: [String]] = [
        "a": ["a", "à", "á", "ả", "ã", "ạ", "ă", "â"],
        "e": ["e", "è", "é", "ẻ", "ẽ", "ẹ", "ê"],
        "o": ["o", "ò", "ó", "ỏ", "õ", "ọ", "ô", "ơ"],
        "u": ["u", "ù", "ú", "ủ", "ũ", "ụ", "ư"],
        "i": ["i", "ì", "í", "ỉ", "ĩ", "ị"],
        "y": ["y", "ỳ", "ý", "ỷ", "ỹ", "ỵ"],
        "d": ["d", "đ"],
    ]

    static func rows(_ page: KeyPage, showsGlobe: Bool) -> [[KeySpec]] {
        let chars = { (s: String, w: CGFloat?) in s.map { KeySpec(kind: .char(String($0)), width: w) } }
        var bottom: [KeySpec] = [
            KeySpec(kind: .page(page == .letters ? .numbers : .letters), width: 1.33),
            KeySpec(kind: .lang, width: 1.33),
        ]
        if showsGlobe { bottom.append(KeySpec(kind: .globe, width: 1.33)) }
        bottom += [KeySpec(kind: .space, width: nil), KeySpec(kind: .ret, width: 2.74)]

        switch page {
        case .letters:
            return [
                chars("qwertyuiop", 1),
                chars("asdfghjkl", 1),
                [KeySpec(kind: .shift, width: nil)] + chars("zxcvbnm", 1) + [KeySpec(kind: .delete, width: nil)],
                bottom,
            ]
        case .numbers:
            return [
                chars("1234567890", 1),
                chars("-/:;()$&@\"", 1),
                [KeySpec(kind: .page(.symbols), width: nil)] + chars(".,?!'", 1.4) + [KeySpec(kind: .delete, width: nil)],
                bottom,
            ]
        case .symbols:
            return [
                chars("[]{}#%^*+=", 1),
                chars("_\\|~<>€£¥•", 1),
                [KeySpec(kind: .page(.numbers), width: nil)] + chars(".,?!'", 1.4) + [KeySpec(kind: .delete, width: nil)],
                bottom,
            ]
        }
    }
}
