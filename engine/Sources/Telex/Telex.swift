/// Engine gõ tiếng Việt Telex. Thuần Swift, không UIKit.
/// Bản port 1-1 của docs/mockup/telex.js. Hai bản phải pass cùng file
/// Tests/TelexTests/Resources/telex-vectors.json.
///
/// CI chép file này vào targets/keyboard/Engine/ trước khi build bàn phím.
public enum ToneStyle: String, Sendable {
    /// hoà, thuỷ
    case new
    /// hòa, thủy
    case old
}

public enum Telex {
    public static let engineVersion = "0.1.0"

    private static let toned: [Character: [Character]] = [
        "a": Array("aáàảãạ"), "ă": Array("ăắằẳẵặ"), "â": Array("âấầẩẫậ"),
        "e": Array("eéèẻẽẹ"), "ê": Array("êếềểễệ"), "i": Array("iíìỉĩị"),
        "o": Array("oóòỏõọ"), "ô": Array("ôốồổỗộ"), "ơ": Array("ơớờởỡợ"),
        "u": Array("uúùủũụ"), "ư": Array("ưứừửữự"), "y": Array("yýỳỷỹỵ"),
    ]
    private static let toneKeys: [Character: Int] = ["s": 1, "f": 2, "r": 3, "x": 4, "j": 5, "z": 0]
    private static let circumflex: [Character: Character] = ["a": "â", "e": "ê", "o": "ô"]
    private static let marked: Set<Character> = ["ă", "â", "ê", "ô", "ơ", "ư"]
    private static let rootOf: [Character: Character] = ["ă": "a", "â": "a", "ê": "e", "ô": "o", "ơ": "o", "ư": "u"]
    private static let hooked: Set<Character> = ["ă", "ơ", "ư"]

    private struct Glyph { var base: Character; var tone: Int; var upper: Bool }

    private static let lookup: [Character: (base: Character, tone: Int)] = {
        var map: [Character: (base: Character, tone: Int)] = [:]
        for (base, forms) in toned { for (tone, ch) in forms.enumerated() { map[ch] = (base, tone) } }
        return map
    }()

    private static func lower(_ ch: Character) -> Character { Character(String(ch).lowercased()) }

    private static func parse(_ word: String) -> [Glyph] {
        word.map { ch in
            let l = lower(ch)
            if let v = lookup[l] { return Glyph(base: v.base, tone: v.tone, upper: ch != l) }
            return Glyph(base: l, tone: 0, upper: ch != l)
        }
    }

    private static func isVowel(_ g: Glyph) -> Bool { toned[g.base] != nil }

    private static func render(_ gs: [Glyph]) -> String {
        gs.map { g -> String in
            let ch = isVowel(g) ? toned[g.base]![g.tone] : g.base
            return g.upper ? String(ch).uppercased() : String(ch)
        }.joined()
    }

    /// Cụm nguyên âm cuối cùng của từ (đã bỏ u trong "qu" và i trong "gi").
    private static func cluster(_ gs: [Glyph]) -> [Int] {
        guard let end = gs.lastIndex(where: isVowel) else { return [] }
        var start = end
        while start > 0 && isVowel(gs[start - 1]) { start -= 1 }
        var idx = Array(start...end)
        if idx.count > 1 && start > 0 && gs[start - 1].base == "q" && gs[start].base == "u" {
            idx.removeFirst()
        } else if idx.count > 1 && start == 1 && gs[0].base == "g" && gs[1].base == "i" {
            idx.removeFirst()
        }
        return idx
    }

    private static func tonePosition(_ gs: [Glyph], _ style: ToneStyle) -> Int? {
        let c = cluster(gs)
        guard let first = c.first else { return nil }
        if let horn = c.first(where: { gs[$0].base == "ơ" }) { return horn }
        if let m = c.first(where: { marked.contains(gs[$0].base) }) { return m }
        if c.count == 1 { return first }
        if c.count >= 3 { return c[1] }
        if c[1] < gs.count - 1 { return c[1] }            // có phụ âm cuối
        let pair = String(gs[c[0]].base) + String(gs[c[1]].base)
        if ["oa", "oe", "uy"].contains(pair) { return style == .old ? c[0] : c[1] }
        return c[0]
    }

    private static func currentTone(_ gs: [Glyph]) -> Int {
        gs.first(where: { isVowel($0) && $0.tone != 0 })?.tone ?? 0
    }

    private static func normalize(_ gs: inout [Glyph], _ style: ToneStyle, _ tone: Int) {
        for i in gs.indices where isVowel(gs[i]) { gs[i].tone = 0 }
        if tone != 0, let p = tonePosition(gs, style) { gs[p].tone = tone }
    }

    private static func literal(_ gs: inout [Glyph], _ key: Character) {
        let l = lower(key)
        gs.append(Glyph(base: l, tone: 0, upper: key != l))
    }

    /// `word`: các chữ cái ngay trước con trỏ. `key`: chữ cái vừa gõ.
    public static func apply(word: String, key: Character, style: ToneStyle) -> String {
        var gs = parse(word)
        let k = lower(key)
        var tone = currentTone(gs)

        if let t = toneKeys[k] {
            if cluster(gs).isEmpty || (t == 0 && tone == 0) {
                literal(&gs, key)
            } else if t != 0 && t == tone {
                tone = 0; literal(&gs, key)                  // gõ lại = bỏ dấu
            } else {
                tone = t
            }
            normalize(&gs, style, tone)
            return render(gs)
        }

        let c = cluster(gs)
        if let target = circumflex[k] {                       // aa ee oo
            if let plain = c.last(where: { gs[$0].base == k }) {
                gs[plain].base = target
            } else if let done = c.last(where: { gs[$0].base == target }) {
                gs[done].base = k; literal(&gs, key)          // aaa = aa
            } else {
                literal(&gs, key)
            }
        } else if k == "d" {                                  // dd = đ
            if gs.first?.base == "d" { gs[0].base = "đ" }
            else if gs.first?.base == "đ" { gs[0].base = "d"; literal(&gs, key) }
            else { literal(&gs, key) }
        } else if k == "w" {                                  // aw ow uw uow
            let u = c.first(where: { gs[$0].base == "u" })
            let o = c.last(where: { gs[$0].base == "o" })
            let a = c.last(where: { gs[$0].base == "a" })
            if let u, let o, o == u + 1 {
                gs[u].base = "ư"; gs[o].base = "ơ"
            } else if let o {
                gs[o].base = "ơ"
            } else if let u {
                gs[u].base = "ư"
            } else if let a {
                gs[a].base = "ă"
            } else if c.count == 1, c[0] == gs.count - 1, gs[c[0]].base == "ư" {
                gs[c[0]] = Glyph(base: "w", tone: 0, upper: key != k)   // ww = w
            } else if c.contains(where: { hooked.contains(gs[$0].base) }) {
                for i in c where hooked.contains(gs[i].base) { gs[i].base = rootOf[gs[i].base]! }
                literal(&gs, key)                             // gõ lại w = bỏ móc
            } else if c.isEmpty && gs.last?.base != "w" {
                gs.append(Glyph(base: "ư", tone: 0, upper: key != k))
            } else {
                literal(&gs, key)
            }
        } else {
            literal(&gs, key)
        }
        normalize(&gs, style, tone)
        return render(gs)
    }

    /// Gõ cả chuỗi phím, dùng cho test.
    public static func type(_ keys: String, style: ToneStyle) -> String {
        var out = ""
        for ch in keys {
            if ch.isLetter {
                let word = String(out.reversed().prefix(while: { $0.isLetter }).reversed())
                out.removeLast(word.count)
                out += apply(word: word, key: ch, style: style)
            } else {
                out.append(ch)
            }
        }
        return out
    }
}
