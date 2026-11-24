# Ghế mô phỏng cảm giác lái — cơ cấu 3-RPS khí nén

Phân tích động học, lực và độ bền sơ bộ cho ghế ba xy lanh khí nén bố trí tam giác đều, đầu trên khớp cầu S và đầu dưới khớp xoay R.

## Hướng dẫn MATLAB/Simulink và mô hình tham khảo mới

- [Đọc hướng dẫn từng bước trên web](docs/simulink_reference/HUONG_DAN_MATLAB_SIMULINK.md).
- [Tải ZIP hướng dẫn và mô hình tham khảo](downloads/Ghe3_HuongDan_Simulink_ThamKhao_R2017b.zip).
- [File Simulink MDL tham khảo](docs/simulink_reference/ghe3_ik_reference.mdl).
- [Script tạo hai model SLX trên MATLAB](docs/simulink_reference/build_ghe3_reference.m).

Chạy `ghe3_reference_init` trước khi mở model. Ví dụ gồm động học ngược, tín hiệu bàn đạp/vô lăng và logic van 5/3. Đây là hướng dẫn và mô hình tham khảo mới, chưa phải mô hình khí nén vòng kín đầy đủ. Đã qua 9 nhóm kiểm tra hàm bằng Octave; chưa mở/compile bằng MATLAB/Simulink. Xem [phạm vi kiểm tra](docs/simulink_reference/VALIDATION.md).

## Bản hoàn thiện 5 chương — 3 bar, 0,09 Hz

- [Tải báo cáo Word đủ 5 chương](downloads/PBL2_5_chuong_3bar_009Hz_bo_tri_CA.docx).
- [Tải gói MATLAB, kết quả và hình minh họa](downloads/MATLAB_PBL2_CA_3bar_009Hz.zip).

Bán kính khớp đế 420 mm; bán kính khớp trên giả định 360 mm. Cạnh ngoài khung đế 1000 mm. Bộ mã dùng áp cấp 3 bar dư và tần số 0,09 Hz. Giải nén ZIP rồi chạy `study = pbl2_chuong4(true);`.

Đã qua 31 nhóm kiểm thử bằng GNU Octave 9.4.0; dùng API hướng tới MATLAB R2017b, chưa chạy trực tiếp trên R2017b. Số liệu thực đo để trống; quỹ đạo yêu cầu không phải chuyển động thực đã được kiểm chứng. Các tệp bên dưới thuộc những phiên bản trước.

## Các tệp

- [Báo cáo Word](Bao_cao_Dong_hoc_Do_ben_Ghe_3RPS.docx): công thức, đối chiếu tám tài liệu tham khảo, ví dụ tính và giới hạn áp dụng.
- [Bản báo cáo Markdown](Bao_cao_Ghe_3RPS.md): đọc trực tiếp trên GitHub.
- [Mã MATLAB và hướng dẫn](MATLAB_Ghe3XyLanh/README.md).
- [Tải bộ MATLAB dạng ZIP](MATLAB_Ghe_3RPS.zip).
- [Kết quả mẫu CSV/MAT](MATLAB_Ghe3XyLanh/ket_qua).
- [Nhật ký kiểm thử](MATLAB_Ghe3XyLanh/test_report.txt) và [tóm tắt xác minh](verification_summary.json).

## Báo cáo PBL2 — cập nhật phần tính máy nén

- [Toàn bộ báo cáo Word đã sửa mục 3.3](docs/may_nen/PBL2Ghemophong_da_sua_may_nen.docx).
- [Riêng mục 3.3: tính toán và chọn nguồn khí nén](docs/may_nen/Muc_3_3_Tinh_chon_may_nen_da_sua.docx).

Phần sửa dùng SC63-500 và quỹ đạo MATLAB 0,30 Hz. Kết quả thể tích quét là 122,79 L/phút trung bình và 169,86 L/phút đỉnh, quy về áp khí quyển ở cùng nhiệt độ; lượng khí nạp tăng áp và tiêu chí FAD được trình bày riêng. Chưa có cơ sở xác nhận máy PA-12L 40 L/phút, bình 12 L đáp ứng chế độ này.

Chỉ mục 3.3 của báo cáo PBL2 được thay; phần tính xy lanh và các phần khác giữ nguyên nội dung, còn cần rà soát và đồng bộ. Bộ tham số SC63-500 trong tài liệu cập nhật khác bộ thông số minh họa ban đầu của mã MATLAB trong repository.

## Chạy trên MATLAB

Mở thư mục MATLAB_Ghe3XyLanh trong MATLAB và chạy:

~~~matlab
r = run_ghe3(); % Nhập tải trọng, hình học và thông số xy lanh
test_ghe3;
~~~

Không cần toolbox bổ sung. Đã chạy 12 nhóm kiểm thử bằng GNU Octave 9.4.0, gồm 200 tư thế động học thuận–ngược và đối chiếu động lực học độc lập. Giao diện/đồ họa MATLAB chưa được chạy trong môi trường kiểm tra.

## Giả thiết cần xác nhận

Ba trục khớp R tại đế được giả thiết nằm ngang và tiếp tuyến đường tròn bố trí chân. Mô hình tính cả chuyển động phụ x, y, yaw và lực ngang lên các chân. Kích thước, vật liệu, áp suất và tải mặc định là số liệu minh họa có thể thay đổi.

Các phép kiểm bền chỉ là sàng lọc sơ bộ. Ổn định cần ngoài miền Euler, tải ngang theo catalog, mỏi, liên kết và khung/neo toàn hệ chưa được xác nhận. Kết quả không phải lệnh vận hành phần cứng hoặc chứng nhận bền sản phẩm.

Các PDF nguồn không được chép lại trong repository; thông tin tham khảo được ghi trong báo cáo.
