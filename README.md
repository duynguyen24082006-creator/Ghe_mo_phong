# Ghế mô phỏng cảm giác lái — cơ cấu 3-RPS khí nén

Phân tích động học, lực và độ bền sơ bộ cho ghế ba xy lanh khí nén bố trí tam giác đều, đầu trên khớp cầu S và đầu dưới khớp xoay R.

## Các tệp

- [Báo cáo Word](Bao_cao_Dong_hoc_Do_ben_Ghe_3RPS.docx): công thức, đối chiếu tám tài liệu tham khảo, ví dụ tính và giới hạn áp dụng.
- [Bản báo cáo Markdown](Bao_cao_Ghe_3RPS.md): đọc trực tiếp trên GitHub.
- [Mã MATLAB và hướng dẫn](MATLAB_Ghe3XyLanh/README.md).
- [Tải bộ MATLAB dạng ZIP](MATLAB_Ghe_3RPS.zip).
- [Kết quả mẫu CSV/MAT](MATLAB_Ghe3XyLanh/ket_qua).
- [Nhật ký kiểm thử](MATLAB_Ghe3XyLanh/test_report.txt) và [tóm tắt xác minh](verification_summary.json).

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
