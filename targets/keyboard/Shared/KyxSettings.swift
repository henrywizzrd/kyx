import Foundation

/// Cài đặt do app chứa ghi vào App Group (khoá `settings`, chuỗi JSON).
/// Hợp đồng: shared/README.md và host/settings.ts.
struct KyxSettings: Equatable {
    static let groupID = "group.com.henrywizzrd.kyx"
    static let storageKey = "settings"

    var click = true
    var haptic = true
    var autocap = true
    var doubleSpace = true
    var tone = "new"            // "new" = hoà, "old" = hòa
    var defaultLang = "VI"      // "VI" | "EN"
    var height = 1.0            // 0.85 ... 1.2
    var theme = "system"        // "system" | "light" | "dark"

    static func load() -> KyxSettings {
        var s = KyxSettings()
        guard let json = UserDefaults(suiteName: groupID)?.string(forKey: storageKey),
              let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return s }
        if let v = obj["click"] as? Bool { s.click = v }
        if let v = obj["haptic"] as? Bool { s.haptic = v }
        if let v = obj["autocap"] as? Bool { s.autocap = v }
        if let v = obj["doubleSpace"] as? Bool { s.doubleSpace = v }
        if let v = obj["tone"] as? String, v == "new" || v == "old" { s.tone = v }
        if let v = obj["defaultLang"] as? String, v == "VI" || v == "EN" { s.defaultLang = v }
        if let v = obj["height"] as? Double { s.height = min(1.2, max(0.85, v)) }
        if let v = obj["theme"] as? String, ["system", "light", "dark"].contains(v) { s.theme = v }
        return s
    }
}
