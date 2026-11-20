# shared: hợp đồng giữa app chứa và bàn phím

App Group: `group.com.henrywizzrd.kyx`

| Khoá (UserDefaults suite) | Ai ghi | Ai đọc | Kiểu |
|---|---|---|---|
| `host.ping` | app chứa | bàn phím | chuỗi ISO8601 |
| `keyboard.ping` | bàn phím (cần Full Access, chờ xác nhận) | app chứa | chuỗi ISO8601 |

Bản sao các hằng số: `host/shared.ts`, `targets/keyboard/Log/AppGroupProbe.swift`.
