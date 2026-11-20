import QuartzCore
import UIKit

/// Các thao tác sửa văn bản qua textDocumentProxy.
/// Lưu ý: bàn phím chỉ đọc được một đoạn ngắn quanh con trỏ (documentContextBefore/AfterInput),
/// nên xoá theo từ và di chuyển lên/xuống dòng chỉ chính xác trong phạm vi đoạn đó.
extension KeyboardViewController {
    private var proxy: UITextDocumentProxy { textDocumentProxy }
    private var before: String { proxy.documentContextBeforeInput ?? "" }
    private var after: String { proxy.documentContextAfterInput ?? "" }

    func keyboardInsertLetter(_ text: String, raw: Bool) {
        let t0 = CACurrentMediaTime()
        defer { stats.record(CACurrentMediaTime() - t0) }

        guard !raw, keyboard.language == "VI", keyboard.page == .letters,
              text.count == 1, let key = text.first, key.isASCII, key.isLetter
        else { proxy.insertText(text); return }

        let word = String(before.reversed().prefix(while: { $0.isLetter }).reversed())
        let style = ToneStyle(rawValue: settings.tone) ?? .new
        replaceTail(word, with: Telex.apply(word: word, key: key, style: style))
    }

    /// Chỉ xoá và gõ lại phần khác nhau, để đỡ nháy chữ.
    private func replaceTail(_ old: String, with new: String) {
        let o = Array(old), n = Array(new)
        var common = 0
        while common < o.count && common < n.count && o[common] == n[common] { common += 1 }
        for _ in common..<o.count { proxy.deleteBackward() }
        if common < n.count { proxy.insertText(String(n[common...])) }
    }

    func keyboardDeleteBackward() {
        proxy.deleteBackward()
    }

    func keyboardSpace() {
        let b = Array(before)
        if settings.doubleSpace, b.count >= 2, b[b.count - 1] == " ",
           b[b.count - 2].isLetter || b[b.count - 2].isNumber {
            proxy.deleteBackward()
            proxy.insertText(". ")
        } else {
            proxy.insertText(" ")
        }
    }

    func keyboardReturn() {
        proxy.insertText("\n")
    }

    // MARK: - Xoá theo từ (⌫ + vuốt trái)

    func keyboardTextBeforeCursor(words: Int) -> String {
        let chars = Array(before)
        var i = chars.count
        for _ in 0..<words where i > 0 {
            while i > 0 && chars[i - 1].isWhitespace { i -= 1 }
            while i > 0 && !chars[i - 1].isWhitespace { i -= 1 }
        }
        return String(chars[i...])
    }

    func keyboardDeleteWords(_ count: Int) {
        let text = keyboardTextBeforeCursor(words: count)
        for _ in text { proxy.deleteBackward() }
    }

    // MARK: - Trackpad

    func keyboardMoveCaret(_ offset: Int) {
        // Chặn ở hai đầu đoạn văn bản bàn phím thấy được, để khỏi rung/nhảy khi chạm biên.
        if offset < 0 && before.isEmpty { return }
        if offset > 0 && after.isEmpty { return }
        let ch = offset < 0 ? before.last : after.first
        proxy.adjustTextPosition(byCharacterOffset: offset * (ch.map { $0.utf16.count } ?? 1))
    }

    /// Lên/xuống 1 dòng, tính theo ký tự xuống dòng (không biết được chỗ ngắt dòng tự động).
    func keyboardMoveLine(_ direction: Int) {
        let b = before, a = after
        let lineStart = b.lastIndex(of: "\n").map { b.index(after: $0) } ?? b.startIndex
        let column = b[lineStart...].utf16.count
        if direction < 0 {
            guard lineStart > b.startIndex else {
                if !b.isEmpty { proxy.adjustTextPosition(byCharacterOffset: -b.utf16.count) }
                return
            }
            let prevEnd = b.index(before: lineStart)                       // vị trí "\n"
            let prevStart = b[..<prevEnd].lastIndex(of: "\n").map { b.index(after: $0) } ?? b.startIndex
            let prevLen = b[prevStart..<prevEnd].utf16.count
            let target = min(column, prevLen)
            proxy.adjustTextPosition(byCharacterOffset: -(column + 1 + (prevLen - target)))
        } else {
            guard let nl = a.firstIndex(of: "\n") else {
                if !a.isEmpty { proxy.adjustTextPosition(byCharacterOffset: a.utf16.count) }
                return
            }
            let restOfLine = a[..<nl].utf16.count
            let nextStart = a.index(after: nl)
            let nextEnd = a[nextStart...].firstIndex(of: "\n") ?? a.endIndex
            let nextLen = a[nextStart..<nextEnd].utf16.count
            proxy.adjustTextPosition(byCharacterOffset: restOfLine + 1 + min(column, nextLen))
        }
    }

    // MARK: - Tự viết hoa

    func shouldCapitalize() -> Bool {
        let b = before
        if b.isEmpty || b.hasSuffix("\n") { return true }
        let trimmed = b.reversed().drop(while: { $0 == " " })
        guard trimmed.count < b.count, let last = trimmed.first else { return false }
        return ".!?".contains(last)
    }
}
