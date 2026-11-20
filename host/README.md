# host: app chứa (Expo / React Native)

| File | Vai trò |
|---|---|
| `App.tsx` | M0: hướng dẫn bật bàn phím + nút ghi/đọc ping qua App Group + ô gõ thử |
| `shared.ts` | Tên App Group và các khoá (phải khớp với `shared/README.md`) |

Đọc/ghi App Group bằng `ExtensionStorage` của `@bacons/apple-targets` (thực chất là UserDefaults suite).
