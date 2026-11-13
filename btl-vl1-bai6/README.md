# BTL Vật lý 1 – Bài 6: Quỹ đạo chuyển động ném xiên

Mã nguồn MATLAB cho bài tập lớn Vật lý 1 (HK1, 2026–2027).

**Đề bài.** Hai vật được ném lên từ mặt đất với cùng vận tốc ban đầu `v0`. Coi trọng trường là đều và bỏ qua sức cản không khí. Với góc ném `α1` nhập vào ở mỗi lần chạy, tìm góc ném `α2` để hai vật có cùng tầm ném xa, sau đó vẽ quỹ đạo của hai vật.

Cơ sở: tầm xa `R = v0²·sin(2α)/g`, nên điều kiện `R1 = R2` tương đương `sin(2α1) = sin(2α2)`. Trong miền `0° < α < 90°` nghiệm thứ hai là `α2 = 90° − α1` (trùng với `α1` khi `α1 = 45°`).

## Cấu trúc thư mục

```
btl-vl1-bai6/
├── README.md
├── .gitignore
├── .gitattributes
└── src/
    ├── inputParameters.m
    ├── calculateProjectile.m
    ├── solveAngleSymbolic.m
    ├── chaythudoclap_solveAngleSymbolic.m
    ├── VL1.m
    └── runTests.m
```

Toàn bộ file `.m` nằm chung trong `src/` để các hàm gọi được nhau mà không cần `addpath`.

## Các module

| File | Phụ trách | Chức năng |
| --- | --- | --- |
| `inputParameters.m` | TV5 – Gia Lộc | Nhập `v0`, `α1`, `g` từ bàn phím, kiểm tra hợp lệ, đổi góc sang radian. |
| `calculateProjectile.m` | TV5 – Gia Lộc | Tính `T`, `H`, `R` và 500 điểm tọa độ `(x, y)` của quỹ đạo. |
| `solveAngleSymbolic.m` | TV4 – Gia Bảo | Giải `sin(2α2) = sin(2α1)` bằng Symbolic Math Toolbox, lọc nghiệm trong `(0°, 90°)`. Bản tương tác (tự hỏi `α1`, `v0`). |
| `chaythudoclap_solveAngleSymbolic.m` | TV4 – Gia Bảo | Bản có tham số `(a1_deg, v0)` trả về `[a2_deg, R]`; gọi không tham số sẽ chạy 2 ví dụ mẫu. |
| `VL1.m` | TV6 – Đăng Khôi | Lớp ứng dụng App Designer: chọn `α1` bằng thanh trượt, nhập `v0`, vẽ động hai quỹ đạo. |
| `runTests.m` | TV7 – Duy Quang | Bộ 8 ca kiểm thử, báo cáo PASS/FAIL và phân tích sai số `|R1 − R2|`. |

## Yêu cầu

- MATLAB có **Symbolic Math Toolbox** (`syms`, `solve`).
- File lưu ở mã hóa UTF-8 (chuỗi tiếng Việt có dấu trong `fprintf`, `input`).

## Cách chạy

Trong MATLAB, chuyển thư mục hiện hành vào `src/` rồi gọi:

```matlab
solveAngleSymbolic                      % nhập a1, v0 -> in a2 và R
chaythudoclap_solveAngleSymbolic        % chạy 2 ví dụ mẫu (30° và 45°)
[T, H, R, x, y, t] = calculateProjectile(20, 30, 9.81);
runTests                                % bộ kiểm thử
```

## Vấn đề đã biết (cần xử lý khi tích hợp)

Các mục dưới đây rút ra từ việc đọc mã nguồn, chưa được chạy kiểm chứng trên MATLAB.

1. **Lệch giao diện hàm giữa `runTests.m` và `solveAngleSymbolic.m`.**
   `runTests.m` gọi `[a2, ~] = solveAngleSymbolic(alpha1, v0, g)` (3 đầu vào, 2 đầu ra), trong khi `solveAngleSymbolic.m` khai báo `function solveAngleSymbolic()` (không đầu vào, không đầu ra). Bản `chaythudoclap_solveAngleSymbolic` có 2 đầu vào `(a1_deg, v0)` nên cũng chưa khớp.
2. **Điều kiện PASS/FAIL của TC07–TC08 trong `runTests.m` bị ngược.**
   Hai ca này kiểm tra dữ liệu không hợp lệ (`v0 = -5`, `α1 = 90°`), kết quả mong đợi là hàm báo lỗi, nhưng mã hiện gán `FAIL` khi có lỗi và `PASS` khi không có lỗi.
3. **`VL1.m` thiếu file cấu hình giao diện.**
   Lớp `VL1` tham chiếu `./VL1.xml` (bố cục các thành phần giao diện); file này chưa có trong repo. Cần bổ sung file gốc xuất từ App Designer.
4. **`VL1.m` tính trực tiếp `alpha2 = 90 - alpha`**, chưa gọi `solveAngleSymbolic` và `calculateProjectile`; chưa có chức năng lưu hình 300 DPI.
5. **Chưa có chương trình chính (`main.m`)** nối chuỗi nhập liệu → giải Symbolic → tính thông số → vẽ quỹ đạo.
