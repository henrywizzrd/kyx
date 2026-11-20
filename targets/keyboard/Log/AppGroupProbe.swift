import Foundation

/// M0: kiểm tra App Group từ phía bàn phím.
/// Khoá và tên group phải khớp với `shared/README.md` và `host/shared.ts`.
enum AppGroupProbe {
    static let groupID = "group.com.henrywizzrd.kyx"
    static let hostPingKey = "host.ping"
    static let keyboardPingKey = "keyboard.ping"

    struct Result {
        let containerFound: Bool
        let hostPing: String?
        let fileWrite: String
        let defaultsWrite: String
    }

    static func run() -> Result {
        let fm = FileManager.default
        let container = fm.containerURL(forSecurityApplicationGroupIdentifier: groupID)
        let defaults = UserDefaults(suiteName: groupID)
        let hostPing = defaults?.string(forKey: hostPingKey)

        // Thử ghi file: Apple ghi rõ khi tắt Full Access thì container chỉ đọc được.
        var fileWrite = "no container"
        if let container {
            let url = container.appendingPathComponent("keyboard-probe.txt")
            do {
                try Data(timestamp().utf8).write(to: url, options: .atomic)
                fileWrite = "OK"
            } catch {
                fileWrite = "FAIL: \((error as NSError).code)"
            }
        }

        // Thử ghi UserDefaults rồi đọc lại để xác nhận.
        var defaultsWrite = "no defaults"
        if let defaults {
            let value = timestamp()
            defaults.set(value, forKey: keyboardPingKey)
            defaultsWrite = defaults.string(forKey: keyboardPingKey) == value ? "OK (local)" : "FAIL"
        }

        return Result(containerFound: container != nil, hostPing: hostPing,
                      fileWrite: fileWrite, defaultsWrite: defaultsWrite)
    }

    private static func timestamp() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
