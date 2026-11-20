import Foundation
import Testing
@testable import Telex

struct Vector: Decodable, CustomTestStringConvertible {
    let keys: String
    let style: String
    let out: String
    var testDescription: String { "\(keys) (\(style)) → \(out)" }
}

/// Bộ test cases dùng chung với docs/mockup/telex.js.
let vectors: [Vector] = {
    let url = Bundle.module.url(forResource: "telex-vectors", withExtension: "json")!
    return try! JSONDecoder().decode([Vector].self, from: Data(contentsOf: url))
}()

@Test(arguments: vectors)
func telexVector(_ v: Vector) {
    #expect(Telex.type(v.keys, style: ToneStyle(rawValue: v.style)!) == v.out)
}

@Test func nonLetterKeepsWordBoundary() {
    #expect(Telex.type("as,as", style: .new) == "á,á")
}
