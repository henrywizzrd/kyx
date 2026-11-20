# Nhật ký quyết định (mới nhất ở trên)

## 2026-11-20 · ADR-007: Tạo Release bằng workflow_dispatch
Phiên của Claude không push tag được (bị chặn 403). Muốn ra Release: vào Actions → ios-build → Run workflow → nhập `release_tag` (vd `v0.0.1`). Push tag `v*` từ máy của Tyson vẫn chạy được như cũ.

## 2026-11-20 · ADR-006: Câu hỏi mở: log của bàn phím khi tắt Full Access
Apple ghi rõ: khi tắt Full Access thì shared container chỉ đọc được. Vì vậy bàn phím không thể ghi log vào App Group trong v1.
Kết quả M0 sẽ cho dữ liệu thực tế. Phương án sẽ chọn sau M0: (a) bật Full Access ở bản dev, (b) bàn phím tự hiện panel log của nó, (c) khác.

## 2026-11-20 · ADR-005: Build ra IPA không ký, rồi ký ad-hoc kèm entitlements
CI build với `CODE_SIGNING_ALLOWED=NO`, sau đó `codesign -s -` kèm entitlements App Group, để ESign có thể đọc lại. M0 sẽ xác nhận.

## 2026-11-20 · ADR-004: v1 không bật Full Access
`RequestsOpenAccess = false`.

## 2026-11-20 · ADR-003: Tự viết engine Telex bằng Swift theo TDD
Chi phí 0 đồng. Không dùng UniKey (GPL), Kankoda (giấy phép thương mại), KeyboardKit (hiện là commercially licensed). Funput (MIT, Rust) để làm tham khảo.

## 2026-11-20 · ADR-002: Phạm vi v1 = tiếng Anh + Telex
Gợi ý từ, swipe, emoji, theme để sau v1.

## 2026-11-20 · ADR-001: Kiến trúc A, dùng Expo + @bacons/apple-targets
Project Expo nằm ở gốc repo. Source TS của host đặt trong `host/` (không đặt trong `app/` để tránh bị nhầm là route của Expo Router).
