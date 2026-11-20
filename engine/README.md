# engine: Swift Package `KyxEngine`

Thuần Swift, không UIKit. Test: `swift test --package-path engine` (CI, macOS).

| File | Vai trò |
|---|---|
| `Sources/Telex/Telex.swift` | `Telex.apply(word:key:style:)`. Bản port 1-1 của `docs/mockup/telex.js` |
| `Tests/TelexTests/TelexTests.swift` | Chạy toàn bộ test cases trong file JSON (Swift Testing) |
| `Tests/TelexTests/Resources/telex-vectors.json` | Test cases dùng chung cho bản JS và bản Swift. Thêm case mới vào đây |

Khi build IPA, CI chép `Sources/Telex/*.swift` vào `targets/keyboard/Engine/`.
