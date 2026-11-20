# Kyx: bản đồ project (ĐỌC FILE NÀY TRƯỚC)

Bàn phím iOS tự làm: tiếng Anh + tiếng Việt Telex. App chứa viết bằng Expo, bàn phím là Swift extension.
Đọc thêm `docs/STATUS.md`, rồi README của **đúng một** thư mục mà task đụng tới.

## Cái gì nằm ở đâu
| Đường dẫn | Nội dung |
|---|---|
| `targets/keyboard/` | Swift keyboard extension (`com.apple.keyboard-service`). Mọi file trong đây đều vào target. Xem README trong thư mục. |
| `engine/` | Swift Package thuần, không UIKit: Telex + logic layout. Test bằng `swift test`. |
| `shared/` | Hợp đồng dùng chung: tên App Group, các khoá, định dạng log. |
| `host/` | Source TS của app chứa (onboarding, settings, Log). `index.ts` ở gốc import `host/App`. |
| `docs/` | ARCHITECTURE, DECISIONS (ADR), STATUS. |
| `.github/workflows/ios-build.yml` | CI: engine tests + typecheck + build IPA. |

Project Expo nằm ở gốc repo (`app.json`, `package.json`), vì `@bacons/apple-targets` đọc thư mục `/targets` ở gốc. `ios/` sinh ra bằng prebuild và không commit.

## Định danh
- App: `com.henrywizzrd.kyx` · Bàn phím: `com.henrywizzrd.kyx.keyboard` · App Group: `group.com.henrywizzrd.kyx`

## Lệnh
- `npm ci` · `npm run typecheck`
- `swift test --package-path engine` (cần Swift 6 / macOS)
- `npx expo prebuild -p ios --clean`: sinh `ios/` để kiểm tra, không commit

## Quy tắc
- Commit gắn tag `[build]` khi thay đổi native/Swift (cần IPA mới), `[update]` khi chỉ đổi JS/TS.
- Trước khi push: typecheck/test phải pass. Sau khi push: theo dõi CI tới khi xanh.
- Không commit `.env`, chứng chỉ, provisioning profile, token.
- Mỗi file nên < 400 dòng. `engine/` không được import UIKit.
- Xong một milestone: cập nhật `docs/STATUS.md`, README của thư mục vừa sửa, và file này nếu bản đồ đổi.
- Không đọc cả repo. Tìm symbol bằng `grep`/`rg` và chỉ đọc các đoạn dòng cần thiết.

## Milestone hiện tại
M0: xem `docs/STATUS.md`.
