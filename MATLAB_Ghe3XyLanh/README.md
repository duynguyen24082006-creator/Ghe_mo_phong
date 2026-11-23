# Ghế khí nén 3-RPS: van 5/3 trung vị kín và nguồn 40 L/phút

Đặt toàn bộ các file `.m` trong cùng thư mục. Bộ mã không cần Optimization, Robotics hoặc Symbolic Toolbox. Mã dùng API tương thích **MATLAB R2017b**; đã kiểm thực thi bằng **GNU Octave 9.4.0**, chưa chạy trực tiếp MATLAB R2017b/Desktop hay phần cứng.

## Chạy

```matlab
test_ghe3;
r = run_ghe3(true);   % Hộp thoại nhập + tính + xuất CSV/MAT + vẽ

% Không mở hộp thoại/hình:
p = ghe3_defaults();
r = run_ghe3(false,p,fullfile(pwd,'ket_qua'));
ghe3_plot(r,fullfile(pwd,'ket_qua'));  % Vẽ riêng khi muốn
```

Trong cấu trúc `p`, dùng SI: m, kg, s, rad, N, Pa. Hộp thoại đổi kích thước sang mm. Áp là **Pa dư**, riêng `pAtm` là áp tuyệt đối. Lưu lượng quy về khí quyển 101325 Pa, giả thiết cùng nhiệt độ; không tự là NL/phút ở nhiệt độ chuẩn khác.

## Bộ cơ khí mặc định

- Tam giác trên cạnh 1000 mm: `rp=1/sqrt(3)` m. `rb=0.42` m còn là giả thiết.
- SC63-500: piston 63 mm, cần 20 mm, hành trình 500 mm. Chiều dài thu hết `Lmin=0.731` m theo gá CA/mắt trâu, ăn ren 20 mm, cần đo xác nhận.
- Đặt piston giữa hành trình cho `h0≈0.9682984523` m, là chiều cao tâm tam giác khớp trên, không phải mặt ngồi.
- Người 100 kg, ghế 20 kg giả thiết, tổng 120 kg. COM chung cao 0.208333 m nếu COM người cao 250 mm và COM ghế ở mặt phẳng khớp. Quán tính `diag([10 12 8])` kg·m² vẫn là giả thiết.
- `legAngles=pi-(0:2)*2*pi/3`: chân 1 sau, 2 trước-trái, 3 trước-phải. Tham số cũ thiếu trường này giữ quy ước góc cũ để tương thích.
- Trục R dưới được giả thiết nằm ngang, tiếp tuyến đường tròn đế. Hướng thực khác cần đổi mô hình ràng buộc.

`q=[h;roll;pitch]`; `ghe3_geometry` giải ràng buộc ba chân, gồm dịch ngang/yaw phụ và Jacobi toàn phần. Lực Newton–Euler gồm trọng lực, gia tốc COM và quán tính quay của cụm người–ghế; chưa gồm khối lượng động lực học riêng từng chân. FK chỉ tìm nhánh nghiệm cục bộ. Quỹ đạo sin là phép thử ngoại tuyến, chưa có Washout hay ramp khởi động/dừng.

## Tham số van và nguồn mới

| Trường | Mặc định | Ý nghĩa |
|---|---:|---|
| `valveType` | `'5/3_CLOSED_CENTER'` | +1 duỗi, 0 khóa kín, −1 thu |
| `valveDeadbandSpeed` | 0.001 m/s | Vùng chết của lệnh tốc độ |
| `valveResponseTime` | 0.025 s | Trễ vận chuyển thuần, không làm tròn về số bước mẫu |
| `valveRatedFlowLpm` | 300 L/phút | Điểm hiệu chuẩn **giả thiết**, chưa chọn hãng/model van |
| `valveRatedInletPressure` | 0.60 MPa dư | Áp vào tại điểm hiệu chuẩn |
| `valveRatedPressureDrop` | 0.10 MPa | Chênh áp tại điểm hiệu chuẩn |
| `valveCriticalRatio` | 0.5 | Tỷ số tới hạn giả thiết |
| `valveMaxPressureDrop` | 0.05 MPa | Ngân sách tụt áp trên nhánh van/tiết lưu |
| `valveMaxTrackingError` | 0.003 m | Ngưỡng sàng lọc quãng đường bỏ qua do trễ/vùng chết; không phải sai số bám đã đạt |
| `pSupply`, `regulatorPressure` | 0.45 MPa dư | Hai tên của cùng giá trị đặt điều áp |
| `regulatorHeadroom` | 0.02 MPa | Dự trữ chênh áp để giữ điều áp |
| `compressorFlowLpm` | 40 L/phút | FAD giả thiết **khi máy bật**, cần xác nhận tại áp xả thực |
| `compressorMaxDuty` | 1 | Tỷ lệ chạy trung bình cho phép; giá trị 1 chưa phải xác nhận máy được chạy 100% |
| `tankVolume` | 0.012 m³ | Bình 12 L |
| `tankPressureMax` | 0.80 MPa dư | Ngắt máy nén |
| `tankPressureCutIn` | 0.60 MPa dư | Bật lại máy nén |
| `tankInitialPressure` | 0.80 MPa dư | Áp bình ban đầu |
| `airTimeStep` | 0.01 s | Bước tích phân khí tối đa; chia thêm tại các sự kiện |

Thay lưu lượng tham chiếu và tỷ số tới hạn bằng catalogue thật ở đúng áp/chênh áp/nhiệt độ. Mã suy hệ số dẫn khí và dùng mô hình nghẹt/chưa nghẹt; không dùng công thức Kv chất lỏng. Tiết lưu được gộp vào đặc tính dòng của nhánh. Cỡ ren 1/4 hoặc 1/8 không tự cho biết lưu lượng.

`ghe3_validate` bổ sung trường khí cho cấu trúc cũ. Sau một lần validate, sửa riêng `pSupply` hoặc `regulatorPressure` sẽ đồng bộ trường kia. Nếu sửa cả hai thành hai số khác nhau, hàm báo lỗi để tránh chọn nhầm áp.

### So sánh 6 và 4,5 bar

```matlab
p = ghe3_defaults();
p.pSupply = 0.60e6;
p = ghe3_validate(p);
r6 = run_ghe3(false,p,fullfile(pwd,'ket_qua_6bar'));
p.pSupply = 0.45e6;
p = ghe3_validate(p);
r45 = run_ghe3(false,p,fullfile(pwd,'ket_qua_45bar'));
```

Đặt điều áp 6 bar trong khi rơ-le chỉ bật máy khi bình xuống 6 bar không còn chênh áp dự trữ. Mô hình liên tục có thể loại chế độ đó dù bình bắt đầu ở 8 bar.

## Cân bằng khí và giới hạn mô hình

Trạng thái van là lệnh từ dấu vận tốc/vùng chết, lùi theo thời gian trễ. Các thời điểm đổi lệnh được chèn vào lưới khí. Trung vị kín hoặc vận tốc bằng không có phần khí quét bằng không. Áp hai buồng bị nhốt và vị trí thực khi giữ tải **chưa được giải**.

```text
dpTank/dt = pAtm/tankVolume * (Qcompressor - Qinlet)/60000
```

Hệ số `/60000` đổi L/phút thành m³/s. Rơ-le bật/ngắt theo ngưỡng 6–8 bar, chia bước tại sự kiện. Khi bình cạn, lượng khí không cấp được ghi riêng. `tankInflowVolumeL` và `tankOutflowVolumeL` là tích phân khí quy đổi dùng trong phương trình, phù hợp kiểm bảo toàn hơn tích phân hình thang tín hiệu rơ-le lấy mẫu thưa.

Hai loại lưu lượng được giữ riêng:

- `flowAirDemandLpm`, `averageAirDemandLpm`: nhu cầu khí quét của quỹ đạo ở áp đặt, có xét vùng chết, trước khi giảm do van/nguồn không cấp được.
- `flowAirLpm`, `averageAirLpm`: khí quét được ghi nhận sau trạng thái van, sụt áp và khả năng cấp của mô hình thu gọn. Không phải chứng minh ghế thật bám đúng quỹ đạo.

`idealFlowAirLpm` giữ công thức khí quét cũ không vùng chết. Trung bình lấy trên cửa sổ một chu kỳ đầy đủ cuối bản ghi; nếu chưa đủ chu kỳ thì ghi rõ chỉ là trung bình thời gian. `tankPressureDemand` là bình kiểm tra bảo thủ theo toàn nhu cầu; tránh coi áp bình còn cao vì van chưa cấp được khí là đủ nguồn.

`airSupplyOK` kết hợp nhu cầu trung bình, áp thấp nhất của cả bình ghi nhận và bình bảo thủ so với áp đặt cộng headroom, khả năng dòng của van và ngưỡng quãng đường bỏ qua do trễ/vùng chết. Các cờ thành phần được lưu riêng. Kiểm lực dùng lịch sử `workingPressureAvailable` sau sụt áp. Lời gọi sức bền cũ thiếu lịch sử áp giữ hành vi cũ.

`pneumatic.pass` là kiểm **bao khả năng tạo lực** theo áp. Nó không xác nhận áp thật hai buồng hoặc lực thực khi van đổi chiều. Trường hợp tải kéo xy lanh thu cần kiểm tiết lưu xả, áp hai buồng và điều khiển vị trí. Kiểm giữ yên dùng bao lực lý tưởng, không lấy ma sát cản chuyển động làm điều kiện giữ tải; áp bị nhốt vẫn chưa được mô phỏng.

`valvePressureDrop` là tổn thất quasi-tĩnh cần thiết ở lưu lượng yêu cầu, kể cả khi kiểm nhánh đang trễ/khóa; không phải phép đo chênh áp hai phía một van đã đóng. `flowChamberM3s` là thể tích cấp được ghi nhận sau giới hạn nguồn, còn `requestedFlowChamberM3s` lưu thể tích quét yêu cầu.

Chưa tính nạp tăng áp trong thể tích chết/ống, rò rỉ, nhiệt, lưu lượng xả đầy đủ, động lực học chuyển van và chuyển động có phản hồi. Dự phòng 10% trong tìm kiếm không chứng minh các phần thiếu này dưới 4 L/phút. Mã không phát lệnh phần cứng.

## Tìm cấu hình cho nguồn 40 L/phút

```matlab
opt = ghe3_optimize_40lpm();
disp(opt.status);
disp(opt.columns);
disp(opt.feasibleData);
if ~isempty(opt.recommended)
    disp(opt.recommended.metrics);
    pBest = opt.recommended.parameters;
    pBest.computeWorkspace = true;
    pBest.computeFK = true;
    pBest.dt = 0.02;     % Kiểm lại bằng lưới cơ học nhỏ hơn
    rBest = run_ghe3(false,pBest,fullfile(pwd,'ket_qua_tot_nhat'));
end
```

Lưới mặc định 288 tổ hợp: áp 3,5–6 bar bước 0,5; hai mức của mỗi biên độ nâng/Roll/Pitch; tần số 0,05/0,10/0,20 Hz; giới hạn tốc độ 0,03/0,08 m/s. Cơ học được dùng lại giữa các trường hợp áp và giới hạn tốc độ; mỗi chu kỳ có 81 khoảng mẫu. Khí dùng lưới tích phân riêng nhỏ hơn. FK/workspace được bỏ qua có ghi rõ trong tìm kiếm, không coi là đã kiểm.

Điều kiện chấp nhận đồng thời: đủ bao lực; hình học/tốc độ hợp lệ; nhu cầu trung bình ≤36 L/phút và ≤FAD nhân tỷ lệ chạy cho phép; khởi động và cận áp bình khi chạy lặp liên tục đạt; van đáp ứng dòng, sụt áp và ngưỡng quãng đường bỏ qua.

Cận áp liên tục dùng lượng thiếu hụt tích lũy lớn nhất trong một chu kỳ khi máy bật, có biên bảo thủ theo mẫu. Trung bình phải nhỏ hơn khả năng máy để hồi bình. Bình đầy đủ chạy vài giây không tự làm cấu hình đạt. Chứng minh chỉ áp dụng cho mô hình nguồn đẳng nhiệt, FAD hằng và nhu cầu tuần hoàn đã lấy mẫu.

`maxSpeed` là điều kiện loại, **không âm thầm kẹp vận tốc** để giảm khí. Cột `peak_required_speed_mps` là vận tốc lớn nhất quỹ đạo của dòng đó; cài tiết lưu thật cần đặc tính độ mở–lưu lượng.

Khuyến nghị là một dòng có thật trong lưới, tối đa hóa tổng biên độ chuẩn hóa nhân tần số chuẩn hóa; hòa điểm ưu tiên áp thấp, giới hạn tốc độ nhỏ đủ dùng và nhu cầu khí thấp. Không coi các cực đại riêng của từng biên độ/tần số là một tổ hợp đồng thời khả thi.

Ví dụ lưới tự chọn nhỏ:

```matlab
grid = struct();
grid.pSupply = [3.5 4.5 6]*1e5;
grid.ampH = [0.005 0.010];
grid.ampRoll = [1 2]*pi/180;
grid.ampPitch = [1 2]*pi/180;
grid.frequency = [0.05 0.10];
grid.maxSpeed = [0.02 0.04];
grid.averageAirLimitLpm = 36;
grid.samplesPerCycle = 101;
opt = ghe3_optimize_40lpm(ghe3_defaults(),grid,fullfile(pwd,'tim_40lpm'));
```

Nếu không có cấu hình đạt, `opt.recommended` rỗng. MATLAB có `opt.table`/`opt.feasibleTable`; `opt.columns`, `opt.data`, `opt.feasibleData` dùng được cả Octave.

## Tệp xuất và kiểm thử

`run_ghe3` xuất `trajectory.csv`, `workspace_sampled.csv`, `summary.csv`, `screening_notes.txt`, `results.mat`. Giữ thứ tự cột cũ, nối thêm cột van/áp bình/áp khả dụng/nhu cầu khí và tích phân bảo toàn. Cột khí cấp cũ trong kết quả mới mang nghĩa khí quét được ghi nhận; dùng cột nhu cầu để thiết kế nguồn. Hình thêm `valve_tank.png` bên cạnh hai hình cơ học.

`summary.csv` thêm `average_air_Lpm`, `average_air_demand_Lpm`, `min_tank_pressure_Pa`, `min_demand_tank_pressure_Pa`, `air_supply_feasible` và các kiểm van/bảo toàn. Tệp MAT cũ thiếu mô hình nguồn vẫn xuất được, chỉ số chưa có ghi NaN.

Tìm kiếm xuất `optimizer_40lpm_all.csv`, `optimizer_40lpm_feasible.csv`, `optimizer_40lpm_recommended.csv`, `optimizer_results.mat`, `optimizer_notes.txt`. Áp CSV dùng Pa dư, góc rad.

`test_ghe3` giữ các kiểm khoa học trước đây bằng dữ liệu chuẩn riêng: Jacobian, 200 IK/FK, tĩnh học lệch tâm, năng lượng Lagrange độc lập, hồi quy lực, cân bằng không gian/công ảo. Thêm kiểm bộ mặc định 1000 mm, khóa kín/vùng chết, trễ 25 ms, bảo toàn khí qua rơ-le, đầy/cạn bình, thiếu nguồn, đồng bộ hai tên áp và kiểm lực theo áp khả dụng.

Các kiểm cơ khí vẫn sơ bộ. Ngoài miền Euler ghi NOT ASSESSED. Chưa xác nhận tải ngang/gối dẫn hướng, khung 3D, mỏi, ren, hàn và khớp thật. Một dòng tối ưu hoặc cờ khí đạt không thay các kiểm này.
