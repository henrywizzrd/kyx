import UIKit

/// Màu bàn phím, lấy theo bản mẫu docs/mockup/index.html.
/// `panel` không còn tô làm nền (nền do iOS vẽ), chỉ dùng làm màu mũi tên khi Shift đang bật.
struct Palette {
    let panel: UIColor
    let key: UIColor
    let function: UIColor
    let pressed: UIColor
    let text: UIColor
    let subtle: UIColor
    let accent: UIColor

    static let dark = Palette(
        panel: UIColor(white: 0.149, alpha: 1),     // #262626
        key: UIColor(white: 0.29, alpha: 1),        // #4a4a4a
        function: UIColor(white: 0.227, alpha: 1),  // #3a3a3a
        pressed: UIColor(white: 0.416, alpha: 1),   // #6a6a6a
        text: .white,
        subtle: UIColor(white: 0.62, alpha: 1),
        accent: UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1))

    static let light = Palette(
        panel: UIColor(red: 0.82, green: 0.827, blue: 0.851, alpha: 1),     // #d1d3d9
        key: .white,
        function: UIColor(red: 0.671, green: 0.69, blue: 0.729, alpha: 1),  // #abb0ba
        pressed: UIColor(red: 0.769, green: 0.78, blue: 0.804, alpha: 1),   // #c4c7cd
        text: .black,
        subtle: UIColor(white: 0.4, alpha: 1),
        accent: UIColor(red: 0, green: 0.48, blue: 1, alpha: 1))
}
