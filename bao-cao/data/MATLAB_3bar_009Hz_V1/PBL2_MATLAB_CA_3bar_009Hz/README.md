# Ghế 3-RPS — hình học khớp và khung tách riêng

Đây là mô hình sàng lọc ngoại tuyến 3 bar dư, 0,09 Hz. Mã dùng API hướng tới MATLAB R2017b và được kiểm bằng GNU Octave 9.4.0; chưa chạy trực tiếp trên MATLAB R2017b. Không gửi lệnh tới phần cứng.

## Bộ hình học hiện dùng

- `p.frameBaseSide = 1.000` m: cạnh ngoài khung đế tam giác đều giả thiết.
- `p.rb = 0.420` m: bán kính ba tâm chốt CA dưới; cạnh nối tâm bằng `sqrt(3)*p.rb`, khoảng 727,461 mm.
- `p.rp = 0.360` m: bán kính ba tâm mắt trâu/CA trên **giả thiết**; cạnh nối tâm khoảng 623,538 mm. Đây không phải kích thước ngoài của mặt ghế.
- Ba gá CA trên cùng một mặt phẳng cứng đỡ ghế; hình dạng/kích thước ngoài của mặt ghế chưa được xác định.
- Chiều dài trung tính `L0 = 0.981` m, chiều dài thu hết giả thiết 0.731 m và hành trình 0.500 m.
- `h0 = sqrt(0.981^2 - 0.060^2)` m. Thân xy lanh nghiêng vào tâm khoảng 3,506° so với phương đứng, quay **quanh** trục chốt CA dưới. Trục chốt dưới vẫn nằm ngang, tiếp tuyến vòng tâm khớp, vuông góc mặt phẳng chuyển động của chân.

Không dùng cạnh ngoài khung 1000 mm để tự gán `p.rp = 1/sqrt(3)`. Muốn đổi vị trí tâm mắt trâu trên, sửa `p.rp`, cập nhật `p.h0` và chạy lại toàn bộ lực, lưu lượng, áp bình, góc khớp và kiểm nghiệm.

## Chạy

```matlab
addpath(pwd);
study = pbl2_chuong4(true,fullfile(pwd,'ket_qua_PBL2'));
checks = pbl2_extended_checks(fullfile(pwd,'ket_qua_PBL2'));
test_ghe3;
test_ghe3_layout;
test_pbl2_chuong4;
```

`study.periodic` là hai chu kỳ nâng ±20 mm, Roll/Pitch ±4° ở 0,09 Hz. `study.events` chứa tăng tốc, phanh, cua trái, cua phải với chuyển nghiêng bậc năm. Các sự kiện riêng dùng trung bình lưu lượng **toàn bản ghi**, không lấy chu kỳ cuối như tín hiệu tuần hoàn.

`pbl2_extended_checks` tái lập kiểm nguồn 120 s, độ nhạy trễ 50 ms, chín tư thế tĩnh và hai lưới 4°/15°; lưu `extended_checks.mat`. Kiểm nguồn dài dùng vận tốc tham chiếu lặp lại, không giải chuyển động vật lý 120 s.

`ghe3_layout(p)` xuất các tâm khớp và đường bao khung giả thiết. Khoảng cách tâm điểm tới cạnh ngoài chưa trừ bề rộng thanh khung, gá CA, thân xy lanh, mắt trâu hoặc khoảng hở an toàn.

## Góc khớp thực và góc chẩn đoán

`ghe3_assembly_diagnostics(q,p)` giữ riêng:

- độ nghiêng thân so với phương đứng;
- góc xoay dưới so với tư thế lắp trung tính;
- góc lệch hai trục mắt trâu khi giả thiết chốt CA trên tiếp tuyến trong hệ mặt ghế và cần không tự xoay quanh trục;
- cận dưới góc lệch nếu cho phép xoay cần tự do;
- góc nón cũ giữa chân và pháp tuyến mặt ghế.

Các góc trên có đơn vị rad. Cận dưới khi xoay tự do không phải dự báo đáp ứng thực. Cần tròn SC có thể tự xoay nếu không có ràng buộc chống xoay, nên phải kiểm thực tế góc lắp và hướng trục mắt trâu. `g.topJointAngle` và `g.baseJointAngle` giữ nguyên ý nghĩa chẩn đoán hình học cũ; không đồng nhất chúng với PH trong catalogue. Các cờ `capacityAssessed=false` và `safeDesignCertified=false` nêu rõ chưa xác nhận giới hạn khớp, va chạm gá, tải ngang hoặc an toàn kết cấu.

## Giới hạn kết quả

Các lịch sử L/v/F là yêu cầu theo quỹ đạo. Proxy từ lượng khí không phải chuyển động đã giải. `actualMotionSolved=false`, `trajectoryAchieved=NaN`. Chưa giải áp hai buồng, phản hồi vị trí, giữ khí bị nhốt, nạp/xả thể tích chết, rò, nhiệt động thực, dòng đảo chiều và chế độ nhiệt máy nén. FAD 40 L/phút và rơ-le 6–8 bar còn là giả thiết. Kiểm ổn định cần ngoài miền Euler, tải ngang hãng, kết cấu toàn khung và mỏi chưa hoàn tất.
