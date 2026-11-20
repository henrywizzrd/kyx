# shared: hợp đồng giữa app chứa và bàn phím

App Group: `group.com.henrywizzrd.kyx` (UserDefaults suite)

| Khoá | Ai ghi | Ai đọc | Nội dung |
|---|---|---|---|
| `settings` | app chứa | bàn phím | Chuỗi JSON `{click, haptic, autocap, doubleSpace, tone: "new"/"old", defaultLang: "VI"/"EN", height: 0.85–1.2, theme: "system"/"light"/"dark"}` |
| `log` | bàn phím (cần Full Access) | app chứa | Các dòng `HH:mm:ss sự kiện` nối bằng `\n`, giữ tối đa 200 dòng |

Bản sao: `host/shared.ts` + `host/settings.ts`, `targets/keyboard/Shared/KyxSettings.swift`, `targets/keyboard/Log/KeyboardLog.swift`.
Bàn phím tự lưu ngôn ngữ dùng lần cuối trong UserDefaults riêng của nó (`kyx.lastLang`).
