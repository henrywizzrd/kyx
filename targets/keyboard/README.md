# targets/keyboard: Swift keyboard extension

Cấu hình ở `expo-target.config.js`. `Info.plist`: `RequestsOpenAccess = true` (ADR-008), `PrimaryLanguage = vi-VN`.
Xcode đồng bộ nguyên cả cây thư mục này vào target `KyxKeyboard`. `Engine/` do CI chép từ `engine/Sources/Telex/` (không commit).

| File | Vai trò |
|---|---|
| `KeyboardViewController.swift` | Điểm vào. Tải cài đặt, theme, chiều cao, ngôn ngữ, âm/rung, tự viết hoa, ghi log mở/đóng |
| `Input/TextActions.swift` | Sửa văn bản qua proxy: Telex, cách đôi ra dấu chấm, xoá theo từ, trackpad (ngang + lên/xuống dòng) |
| `Input/KeyboardView+Touches.swift` | Toàn bộ xử lý chạm và cử chỉ. Hằng số ở `Gesture` (ADR-009) |
| `Layout/KeyboardView.swift` | Vẽ và bố cục phím, bóng chữ, hàng dấu, nhãn xoá. Delegate `KeyboardViewDelegate` |
| `Layout/KeyLayout.swift` | Hàng phím của 3 trang (chữ / 123 / #+=), chữ có dấu khi giữ phím |
| `Layout/KeyView.swift` | Một phím + `KeyPopupView`, `AltsView`, `BubbleView` |
| `Theme/Palette.swift` | Màu sáng/tối theo bản mẫu |
| `Shared/KyxSettings.swift` | Đọc cài đặt JSON từ App Group (khớp `host/settings.ts`) |
| `Log/KeyboardLog.swift` | Ghi log vào App Group, đo bộ nhớ, thống kê độ trễ gõ |
