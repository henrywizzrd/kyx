# Trạng thái

## Roadmap
- **M0** "hello keyboard": phát hành `v0.0.1`, chưa test trên máy.
- **M1–M4** (gộp làm một đợt, đang chờ CI xanh và Tyson test `v0.1.0`):
  - Layout giống bản mẫu, 3 trang, Shift/Caps Lock, phím VI/EN ở ô emoji, nhãn VI/EN giữa phím cách
  - Telex (engine Swift, pass bộ test cases JSON), kiểu bỏ dấu hoà/hòa
  - Cử chỉ: trackpad 4 hướng, ⌫ vuốt trái xoá theo từ, giữ phím để hiện chữ có dấu, gõ 2 ngón
  - Cài đặt trong app + đồng bộ App Group, âm/rung, log (bộ nhớ, độ trễ)
- **M5** Hoàn thiện, đo bộ nhớ và độ trễ, sửa lỗi từ lần test trên máy

Spec hành vi: `docs/mockup/index.html` + `telex.js` (ADR-010).

## Cần đo trên máy
- Trackpad lên/xuống dòng (chỉ biết vị trí `\n`, không biết chỗ ngắt dòng tự động)
- Xoá theo từ: bàn phím chỉ thấy đoạn văn ngắn trước con trỏ
- `adjustTextPosition` với emoji (tính theo UTF-16, chưa kiểm chứng)
- Âm click: dùng `AudioServicesPlaySystemSound(1104)` khi bật Full Access

## Bug đã biết
(chưa có)
