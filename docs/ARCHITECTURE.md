# Kiến trúc

```
┌──────────── Kyx.app (Expo / React Native) ────────────┐
│ host/App.tsx  ── ExtensionStorage (UserDefaults suite)│
│                         │ ghi settings                │
└─────────────────────────┼─────────────────────────────┘
                          ▼
              App Group: group.com.henrywizzrd.kyx
                          ▲ đọc (luôn được)
                          │ ghi (chỉ khi bật Full Access, theo Apple)
┌─────────────────────────┼─────────────────────────────┐
│ KyxKeyboard.appex (Swift, UIInputViewController)      │
│   KeyboardViewController ─► engine (Telex, layout)    │
│   Log/                                                │
└───────────────────────────────────────────────────────┘
```

- Bàn phím chạy trong process riêng, bộ nhớ hạn chế, lỗi xảy ra im lặng.
- Apple: khi chưa bật Full Access, bàn phím chỉ **đọc** được shared container, không ghi được. Điều này ảnh hưởng tới thiết kế log (xem DECISIONS, câu hỏi mở).
- Cách nối `engine/` vào target bàn phím (SPM hay chép source vào) sẽ chốt ở M2.
