# targets/keyboard: Swift keyboard extension

Cấu hình ở `expo-target.config.js`, Info.plist ở `Info.plist` (`RequestsOpenAccess = false`).
Thư mục này được Xcode đồng bộ nguyên cả cây vào target `KyxKeyboard`.

| File | Vai trò |
|---|---|
| `KeyboardViewController.swift` | Điểm vào (`UIInputViewController`). M0: phím 🌐 a ⌫ ⏎ Test + dòng trạng thái |
| `Log/AppGroupProbe.swift` | M0: kiểm tra container App Group, đọc `host.ping`, thử ghi file/defaults |

Thư mục sẽ thêm ở các mốc sau: `Layout/`, `Input/`, `Theme/`.
