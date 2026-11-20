# Trạng thái

## Roadmap
- **M0** "hello keyboard": build xong, phát hành `v0.0.1`. Chưa test trên máy.
- **M1** Layout giống bản mẫu + trang 123/#+= + Shift/Caps Lock + log (vì đã bật Full Access) ← **tiếp theo**
- **M2** Engine Telex (TDD) + đổi VI/EN + kiểu bỏ dấu hoà/hòa
- **M3** Cử chỉ: trackpad 4 hướng trên phím cách, vuốt ⌫ để xoá theo từ, giữ phím để hiện chữ có dấu
- **M4** Trang Cài đặt trong app (âm, rung, tự viết hoa, cách đôi ra dấu chấm, kiểu bỏ dấu, ngôn ngữ mặc định, theme, chiều cao) + đồng bộ qua App Group
- **M5** Hoàn thiện, đo bộ nhớ và độ trễ

Spec hành vi: `docs/mockup/index.html` (ADR-010). Telex: `docs/mockup/telex.js` + test cases `engine/Tests/TelexTests/Resources/telex-vectors.json` (38 case, CI chạy). Engine Swift ở M2 phải pass cùng bộ test cases này.

## Đang chờ
- Tyson xem bản mẫu v3 (đã có Telex) và duyệt. Sau đó Claude làm M1 trở đi, build `v0.1.0` để test chung với M0.

## Lần chạy CI gần nhất
- e562d7c: success

## Bug đã biết
(chưa có)
