import Foundation

/// Log của bàn phím, ghi vào App Group (khoá `log`, các dòng nối bằng \n, giữ 200 dòng cuối).
/// Chỉ ghi được khi bật Full Access; khi tắt, lệnh ghi sẽ không có tác dụng.
enum KeyboardLog {
    static let key = "log"
    static let maxLines = 200

    static func write(_ message: String) {
        guard let defaults = UserDefaults(suiteName: KyxSettings.groupID) else { return }
        let stamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current,
                                                formatOptions: [.withTime, .withColonSeparatorInTime])
        var lines = (defaults.string(forKey: key) ?? "").split(separator: "\n").map(String.init)
        lines.append("\(stamp) \(message)")
        if lines.count > maxLines { lines.removeFirst(lines.count - maxLines) }
        defaults.set(lines.joined(separator: "\n"), forKey: key)
    }

    /// Bộ nhớ thực tế (phys_footprint) của process bàn phím, đơn vị MB.
    static func memoryMB() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        return kr == KERN_SUCCESS ? Double(info.phys_footprint) / 1_048_576 : -1
    }
}

/// Đo độ trễ mỗi lần gõ (từ lúc nhấc tay tới lúc gửi xong chữ cho app).
struct KeystrokeStats {
    private(set) var count = 0
    private var total: Double = 0
    private var worst: Double = 0

    mutating func record(_ seconds: Double) {
        count += 1; total += seconds; worst = max(worst, seconds)
    }

    var summary: String {
        guard count > 0 else { return "keys=0" }
        return String(format: "keys=%d avg=%.1fms max=%.1fms", count, total / Double(count) * 1000, worst * 1000)
    }
}
