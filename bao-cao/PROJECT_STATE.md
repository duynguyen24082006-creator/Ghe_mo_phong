# Trạng thái dự án ghế mô phỏng khí nén 3-RPS

Cập nhật: 27/11/2026. Tài liệu bàn giao dựa trên trao đổi của chủ dự án, tệp hiện còn trong kho và hồ sơ tính toán đã lưu. Việc sắp xếp thư mục không phải một lượt kiểm nghiệm lại cơ cấu hoặc phần mềm.

## 1. Mục tiêu và phạm vi hiện tại

Đồ án PBL 2, Trường Đại học Bách khoa – Đại học Đà Nẵng, lớp 24KTOTO1: nghiên cứu, thiết kế ghế mô phỏng lái xe dùng ba xy lanh khí nén; tính động học, lực, sức bền, nguồn khí và điều khiển, hoàn thiện báo cáo năm chương.

Ưu tiên mới nhất trước lượt tổng hợp này: dựng đủ sản phẩm CAD với các chi tiết tách riêng, có tên để kiểm tra, dựa trên STEP mới; chưa bắt buộc nối Simulink ngay. MATLAB/SolidWorks tự động hóa là mục tiêu triển khai trên máy Windows của người dùng, chưa phải công việc đã xác nhận thực thi từ môi trường này.

## 2. Quyết định đã chốt và lý do

| Quyết định | Cơ sở/lý do và giới hạn |
|---|---|
| Ba SC63-500 tác động kép; piston 63 mm, cần 20 mm, hành trình 500 mm | Lựa chọn của chủ dự án; thông số cơ bản đối chiếu catalogue SC. |
| Khớp dưới quay tại đuôi, gá CA; khớp trên cầu/mắt trâu | Thân xy lanh quay **quanh** trục chốt CA; không nghiêng dọc trục chốt. Cần xác nhận chống xoay cần để tương ứng mô hình R-P-S lý tưởng. |
| Áp sau điều áp 3 bar dư | Chế độ khảo sát tiết kiệm khí; phải kiểm tra đồng thời lực và lưu lượng, không suy ra đủ đáp ứng chỉ từ áp suất. |
| Van 5/3 trung tâm kín, mỗi xy lanh một van | Khóa đường khí khi giữ yên có thể giảm cấp khí mới. Khí bị nhốt vẫn phải cân bằng tải; van không thay thế khóa cơ khí chống tụt. |
| Quỹ đạo tham chiếu ±20 mm Heave, ±4° Roll/Pitch, 0,09 Hz | Giảm nhu cầu lưu lượng so với 0,30 Hz. Tính khả thi chỉ thuộc bộ hình học đã tính. |
| Góc 15° là mục tiêu giới hạn thiết kế | Mô phỏng ±4° không chứng minh đạt ±15°. |
| Dùng PA-12L sẵn có, bình 12 L | Tận dụng thiết bị; 40 L/phút là nhãn, chưa xác minh FAD tại áp vận hành hoặc chế độ nhiệt. |
| Giữ nguyên đế STEP mới | Không sửa thanh, giằng, tấm, lỗ hoặc vị trí để ép khớp catalogue. Nếu cần, đề xuất chi tiết chuyển tiếp. |
| Chi tiết CAD riêng và có tên; cụm lắp ráp có thể tháo/tách | Phục vụ kiểm tra, sửa và chế tạo; không hợp nhất cả sản phẩm thành một khối. |
| Lưu CAD/script/BOM/hình vào một PROJECT_DIR đã liên kết trên Windows | Yêu cầu cuối cho công việc tự động hóa CAD; đường dẫn Windows chưa được cung cấp/xác minh. Cây `bao-cao/` hiện tại là nơi quản lý hồ sơ báo cáo trong kho Git, không phải tự đặt PROJECT_DIR CAD. |
| Giữ nội dung báo cáo đã chốt, chỉ sửa phần chịu ảnh hưởng của dữ liệu mới | Tránh viết lại ngoài phạm vi; Chương 5 chưa có số liệu thực nghiệm phải để `[...]`. |

## 3. Phiên bản hình học: tuyệt đối không trộn kết quả

### V0 — các bộ cũ, đã bị thay thế

Đã từng dùng cạnh tam giác 300 mm, tải 1079,1 N; bộ khác dùng người 90 kg + ghế 45 kg; có phiên bản cạnh trên 1000 mm và bán kính đế 420 mm. Các giá trị lưu lượng 32,513 và 108,363 L/phút trong trao đổi trước thuộc bộ khác. Không dùng chúng làm kết quả STEP mới.

### V1 — bộ toán học/báo cáo năm chương đang lưu

- Bán kính khớp đế 420 mm; khớp trên 360 mm: giả thiết thiết kế.
- Cạnh ngoài khung 1000 mm từng là giả thiết; không phải cạnh nối tâm chốt.
- Chiều dài thu hết tâm khớp 731 mm: ước tính; hành trình 500 mm; trung tính 981 mm.
- Cao độ trung tính 979,163418 mm; nghiêng thân khoảng 3,506518° so với đứng theo hình học V1.
- Người 100 kg; phần ghế chuyển động 20 kg giả thiết; tổng 120 kg, trọng lượng 1177,2 N.
- COM trong hệ sàn `[0;0;0.208333333] m`, suy từ người có COM cao 250 mm và COM ghế tại mặt phẳng khớp trên; đều là giả thiết.
- Quán tính tại COM `diag([10 12 8]) kg.m²`: giả thiết.
- Tư thế chủ động `[h;roll;pitch]`; chuyển động phụ `[x;y;yaw]` được giải từ ràng buộc khớp dưới.

Đây là bộ tạo ra kết quả tại mục 5, không phải hình học hai STEP dưới đây.

### V2 — STEP ngày 19/10/2026

`data/CAD_goc/shapr3d_export_2026-10-19_07h47m.step`: 77 khối; tam giác tâm trục xy lanh cạnh khoảng 800 mm, bán kính 461,880216 mm. Thân đứng; tâm chốt dưới cao 64 mm, trên 803,5 mm, chênh 739,5 mm. Kích thước bao khoảng 783,570 × 904,211 × 874 mm.

Bộ hình trong `figures/STEP_2026_10_19_V2/` và helper `prepare_ghe3_STEP_800.m` chỉ thuộc V2. Khoảng cách chốt 739,5 mm không chứng minh chiều dài thu hết hoặc vị trí trung tính.

### V3 — STEP mới ngày 24/11/2026, cơ sở CAD hiện hành

`data/CAD_goc/shapr3d_export_2026-11-24_21h55m.step`: 53 khối.

- Tam giác **tâm nhóm lỗ gá đế** cạnh 900 mm, bán kính khoảng 519,615242 mm.
- Tam giác **tâm trục xy lanh đang đặt trong CAD** cạnh khoảng 899,910800 mm, bán kính 519,563742 mm. Lệch vị trí với tâm nhóm lỗ khoảng 0,102 mm/nhánh; đây là chênh đo bố trí CAD, không phải dung sai chế tạo được chấp nhận.
- Chốt dưới cao 71 mm, chốt trên 810,5 mm: khoảng cách hiện tại 739,5 mm. Thân đang thẳng đứng. Chưa xác nhận đây là thu hết hay trung tính.
- Đế 18 khối: 3 thanh chính, 6 giằng dài, 6 giằng ngắn, 3 tấm gá.
- Bao đế khoảng 920,672626 × 1063,101177 × 40 mm; thanh/giằng cao 30 mm; tấm gá dày 10 mm.
- Tiết diện thanh được kiểm tra trong CAD có diện tích 900 mm², tương ứng 30 × 30 đặc trong mô hình; không tự gọi là thép hộp rỗng.
- Mỗi tấm: 4 lỗ xuyên Ø8,5 theo bước vuông 56 × 56 mm và 18 lỗ xuyên Ø5. Không tự coi là lỗ ren.
- Mặt sàn hiện có dày 10 mm. Một khối rời gần gốc tọa độ cần nhận diện; loại nó khỏi kích thước bao cụm chính khi đo, không tự xóa.
- Bao cụm chính khoảng 920,673 × 1063,101 × 857,5 mm.

Sau khi thay xy lanh, gá và mắt trâu đúng catalogue, cần đo lại vị trí tâm khớp thực. Chưa cập nhật V3 vào bộ MATLAB chính hoặc bản Word năm chương.

## 4. Tham số khí nén và giả định

| Đại lượng | Giá trị/trạng thái |
|---|---|
| pSupply, regulatorPressure | 300000 Pa dư = 3 bar dư |
| Khí quyển; áp cấp tuyệt đối | 101325 Pa; 401325 Pa |
| Đối áp buồng xả | 50000 Pa dư, giả thiết chưa đo |
| Ma sát Coulomb | 30 N/xy lanh, giả thiết chưa đo |
| Hiệu suất lực | 0,85, giả thiết; phải tránh tính trùng tổn thất đã quy vào ma sát |
| Hệ số tải; hệ số bền | 1,30; 2 — hai vai trò riêng |
| Trễ van | 25 ms giả thiết; có khảo sát 50 ms, chưa chứng thực catalogue |
| Vùng chết vận tốc van | 0,001 m/s trong mô hình nguồn |
| Lưu lượng van danh định | 300 L/phút ở điều kiện mô hình; giả thiết, không phải chứng nhận van đã chọn |
| Máy nén theo nhãn | PA-12L, 750 W, 220 V, 50 Hz, 12 L, 40 L/phút, 8 bar |
| Bình bật/ngắt; ban đầu | 6/8 bar dư; ban đầu 8 bar, giả thiết mô phỏng |
| Giới hạn nhiệt/tỷ lệ chạy cho phép | Chưa biết; tham số duty=1 trong mã không chứng minh máy chạy 100% được |
| Dự phòng lưu lượng | Tiêu chí kế hoạch trung bình ≤36 L/phút khi giả định nguồn 40 |

Đề xuất thiết bị chưa chốt catalogue: ống chính PU ngoài 10 mm, nhánh ngoài 8 mm; sáu tiết lưu một chiều meter-out sát cổng xy lanh; lọc–điều áp AW3000-03; ứng viên van 4V230-08 hoặc TG3522-08C; đầu nối, chia ba nhánh, giảm thanh và van khóa/xả nguồn. Chưa xác minh đường kính trong, cỡ ren, áp–nhiệt, lưu lượng–sụt áp hoặc chính xác chức năng trung tâm kín của các mã van. SC63 catalogue ghi cổng 3/8; phải đối chiếu đầu nối thực.

## 5. Kết quả mô phỏng đã lưu: chỉ V1

Nguồn: `data/MATLAB_3bar_009Hz_V1/`, các tệp `summary.csv`, `validation_geometry.json`; bản trích `data/doi_chieu/evidence.json`.

| Chỉ số | Kết quả |
|---|---:|
| Tần số, biên độ | 0,09 Hz; ±20 mm; Roll/Pitch ±4° |
| Chiều dài yêu cầu min–max | 936,061579–1026,109310 mm |
| Vận tốc piston yêu cầu cực đại | 0,0254751822 m/s |
| Gia tốc dài cực đại | 0,0144538783 m/s² |
| Lực dọc trục yêu cầu min–max | 358,797278–427,987804 N |
| Nén thiết kế cực đại | 556,384145 N |
| Bao lực đẩy/kéo sàng lọc | 645,766397 / 552,304016 N |
| Lưu lượng yêu cầu trung bình | 23,019547 L/phút quy đổi khí quyển |
| Lưu lượng được ghi nhận cấp trung bình | 22,952701 L/phút |
| Đỉnh lưu lượng yêu cầu đồng thời | 25,866355 L/phút |
| Đỉnh lịch sử lưu lượng được ghi nhận cấp | 25,852016 L/phút |
| Áp bình min trong lượt minh họa | 7,283078 bar dư |
| Kiểm tra kéo dài 120 s | Áp min khoảng 6 bar dư theo mô hình |
| Số điểm không gian đạt kiểm tra hình học | 729/729 điểm lấy mẫu, không phải chứng minh miền liên tục |
| Điều kiện Jacobian cực đại | 1,425052 |

Hồ sơ lưu ghi 31 nhóm kiểm thử lõi trên GNU Octave 9.4.0, cùng kiểm tra hình học/kịch bản; chưa chạy trực tiếp MATLAB R2017b. Các nhóm kiểm thử tham khảo Simulink và STEP có báo cáo riêng trong `reviews/kiem-thu-da-co/`.

`actualMotionSolved=false`; `trajectoryAchieved=NaN` nghĩa là **chưa đánh giá** chuyển động thực. Đường suy hành trình từ khí chỉ là proxy sàng lọc. Không cắt vận tốc hoặc xóa nhu cầu khí rồi tuyên bố ghế đã bám quỹ đạo ban đầu.

## 6. Công thức và nguồn truy xuất

Các biểu thức dưới đây ghi lại mô hình đã dùng hoặc được đề xuất, không tự gán là trích nguyên văn bài báo. Nguồn mã nằm trong các thư mục `data/` tương ứng; dùng đúng phiên bản trước khi đối chiếu.

### 6.1 Hình học và động học

Theo hình học tam giác đều: `R = a/√3` (m). Trọng lượng: `W = m g` (N), với m kg, g=9,81 m/s². Nguồn: hình học cơ bản và `ghe3_defaults.m`.

Ở bố trí trung tính đồng hướng V1: `h0 = √(L0² − (rb−rp)²)`; `β0 = asin(|rb−rp|/L0)` (rad). Đây là quan hệ tự suy từ tam giác vuông, không áp dụng cho mọi hướng bố trí.

Trong `ghe3_geometry.m`: `R = Rz(ψ) Ry(θ) Rx(φ)`; `Di = c + R Ai − Bi`; `Li = ||Di||`; ràng buộc `Tiᵀ Di = 0`. Ai/Bi là tâm khớp trên/dưới (m), Ti là trục chốt dưới đơn vị, c là tâm sàn (m). Giải `[x,y,ψ]` thụ động; không đặt chúng bằng 0 trong mọi tư thế.

Hành trình tuyệt đối `si = Li − Lmin`, độ dời so với trung tính `ΔLi = Li − Li0` (m). Phải phân biệt hai đại lượng.

Theo vi phân động học: `Ldot = J qdot`; `Lddot = J qddot + Jdot qdot`, q=[h,φ,θ]ᵀ. J phải bao gồm đạo hàm chuyển động phụ. Nguồn: `ghe3_geometry.m`, `ghe3_simulate.m`. `ghe3_fk.m` giải Newton cục bộ, không chứng minh nghiệm duy nhất.

### 6.2 Lực

Newton–Euler tại COM: `F = m(aG − g_world) − Fexternal`; `M = Iworld α + ω×(Iworld ω) − Mexternal`; `Q = JvGᵀF + EᵀM`; `Jᵀf = Q`. Nguồn: `ghe3_forces.m`. F/f tính N, M Nm, aG m/s², I kg.m². Các chân coi không khối lượng, khớp lý tưởng; phản lực ngang được giải riêng. Không chia tải đều cho mọi tư thế.

Diện tích `A = πD²/4`, `Ar = πd²/4`, `Aa = A−Ar` (m²). Bao lực đang dùng: `Fđẩy = η(pS A − pE Aa) − Fc`; `Fkéo = η(pS Aa − pE A) − Fc`. pS/pE là áp dư Pa, Fc N. Nguồn: `ghe3_strength.m`; η và Fc chưa nhận dạng thực nghiệm.

### 6.3 Lưu lượng và bình chứa

Ước lượng động học khí cấp mỗi nhánh: `Qi = 60000 [(pS+patm)/patm] [A max(vi,0) + Aa max(−vi,0)]` (L/phút quy đổi khí quyển cùng nhiệt độ). Tổng `Qtotal=ΣQi`; trung bình `Qavg=(1/T)∫Qtotal dt`. Nguồn: `ghe3_simulate.m`, `ghe3_air_supply.m`. Không tính toàn hành trình 500 mm mỗi chu kỳ khi quỹ đạo chỉ đi một phần hành trình.

Bảo toàn khí đẳng nhiệt: `dpTank/dt = (patm/VT)(Qcompressor − Qdemand)`; Q ở m³/s quy đổi khí quyển, VT m³, p Pa. Đổi L/phút sang m³/s bằng chia 60000. Cần phân biệt lượng yêu cầu với lượng cấp được. Nguồn: `ghe3_air_supply.m` và kiểm thử bảo toàn.

Lượng khí tự do lý tưởng từ hai mức áp: `Vfree = VT (phi−plo)/patm` (m³). Bình 12 L từ 8 xuống 6 bar dư chứa khoảng 23,686 L khí quy đổi có thể sử dụng giữa hai ngưỡng. Đây là đệm ngắn hạn, không bù thiếu lưu lượng trung bình vô hạn.

Tỷ lệ chạy cân bằng lý tưởng `d = Qavg/QFAD`; nếu tạm lấy QFAD=40 thì V1 có d≈57,55%. Không phải tỷ lệ chạy nhiệt được nhà sản xuất cho phép và chưa xét đủ tổn thất.

### 6.4 Sức bền: chỉ là điều kiện kiểm tra

Euler: `Pcr = π² E I/(K Le)²`; độ mảnh `λ = K Le/√(I/A)`; `Irod=πd⁴/64`. E Pa, I m⁴, Le m, Pcr N. Nguồn: `ghe3_strength.m`. Chỉ dùng Euler khi thỏa miền đàn hồi/độ mảnh. Hồ sơ V1 ghi cần chưa đạt điều kiện áp dụng Euler; không kết luận ổn định đạt.

Chốt: `τ=Rjoint/(n πdp²/4)`; ép mặt `σb=Rjoint/(nb dp t)` (Pa). Cần lực tổng gồm phản lực ngang, số mặt cắt thực, đường kính và vật liệu đúng. Nguồn: `ghe3_strength.m`.

Dầm minh họa V1: `I=[B H³−(B−2t)(H−2t)³]/12`; tải giữa nhịp gối đơn `Mmax=Pℓ/4`, `δ=Pℓ³/(48 E I)`. Không đại diện khung đế 30×30 đặc V3. Nguồn: `ghe3_strength.m`, giả thiết dầm đơn.

Thân xy lanh trong mã được sàng lọc theo ứng suất Lamé/von Mises với bề dày và vật liệu giả thiết. Catalogue cho thân hợp kim nhôm, không chứng thực Fy=250 MPa hoặc dày 5 mm. Không coi kiểm tra này là chứng nhận SC63 thực.

### 6.5 Điều khiển và mô hình cần phát triển

Reference nghiêng cơ bản dùng `HLP(s)=ωc/(s+ωc)` với ωc=0,5 rad/s là lựa chọn minh họa; liên hệ phối hợp nghiêng theo quy ước dấu `θr≈−asin(k ax/g)`, `φr≈asin(k ay/(g cosθr))`, k minh họa 0,5. Nguồn: `data/simulink_reference/`; chưa phải bộ điều khiển được chỉnh định. Không coi công thức này là nguyên văn IEEETVT_2008.pdf.

Mô hình buồng khí **mới đề xuất, chưa giải đầy đủ**: `VA=VA0+A s`, `VB=VB0+Aa(S−s)`; đẳng nhiệt `pdotA=(RT mdotA−pA A sdot)/VA`, `pdotB=(RT mdotB+pB Aa sdot)/VB`. pA/pB tuyệt đối Pa; mdot kg/s; V m³; R hằng số khí riêng; T K. Cần nối với dòng qua van và phương trình động lực học để dự đoán chuyển động thật.

Ánh xạ hành trình sang khớp Simscape: `qJoint=qJointCAD+sign·(L−LCAD)`; đơn vị m. Nguồn: helper `ghe3_joint_command.m`; phải xác minh dấu và trạng thái lắp ráp, không mặc định chiều dài toàn xy lanh là tọa độ Prismatic.

## 7. Nguồn và mức xác minh

1. **Catalogue SC**: `data/catalogue_thiet_ke/SC-Series-Cylinder-202409280439123036.pdf`. Đã đối chiếu trước đó: trang PDF 1/in 34 bảng lực; PDF 2/in 35 đặc tính; PDF 3/in 36 kích thước/vật liệu; PDF 8/in 41 mã phụ kiện; PDF 9/in 42 gá CA. SC63: cần 20 mm, ren đầu M16×1,5, cổng 3/8. CA F-SC63CA: DE14, DC34, DD46,5, S74, T56 mm. Không đánh đồng DQ20 với đường kính chốt.
2. **Mắt trâu**: CSV tham chiếu F-M16X150U chép từ ảnh người dùng, không phải PDF catalogue đã xác minh. Lỗ cầu PC16, ren M16×1,5; cần xác nhận mã, tải và kích thước lắp thực. CA lỗ14, mắt trâu lỗ16, CAD có mặt trụ26: chưa thể coi tương thích nếu chưa phân loại chốt/bạc/mặt lắp.
3. **Bảng bán hàng**: `san_pham_tudonghoadanang.xlsx`; hỗ trợ tìm ứng viên, không thay catalogue lưu lượng hoặc sơ đồ chức năng van.
4. **STEP gốc**: hai tệp trong `data/CAD_goc/`. Kích thước V3 nêu trên lấy từ hồ sơ đo CAD; chưa phải bản vẽ chế tạo có dung sai. SHA256 V3: `da7c03660a8b31c90ae9e02cbdfadd69a9cadd8a7f966f67d9602cca6ef1beec`.
5. **Kết quả mã**: `summary.csv`, MAT/CSV và báo cáo kiểm thử trong gói V1; chi tiết đại lượng trích tại `data/doi_chieu/evidence.json`. Không gán kết quả MATLAB thành kết quả bài báo.
6. **Tài liệu học thuật đã gửi trong lịch sử**: 5079-Bài báo-14708-3-10-20230831.pdf; 10494.pdf; 13902.pdf; ame01_finalfullpaper.pdf; Dynamicmodelingandperformanceanalysisofthe3-PRRU1T2Rparallelmanipulatorwithoutparasiticmotion.pdf; IEEETVT_2008.pdf; Parallel_Mechanisms_and_Robots.pdf; Implementation_of_Decoupled_Model-Based_Controller.pdf; GiaoTrinhHeThongTruyenDongThuyLucVaKhiNen.pdf. Chưa tìm thấy đầy đủ trong bộ tệp hiện tại để mở lại kiểm chứng trang/công thức. Cần cung cấp lại khi rà trích dẫn; không tự điền số trang. Cơ cấu 3-PRRU không chứng minh trực tiếp cơ cấu 3-RPS này.

## 8. Đã làm xong và bằng chứng

- Bản Word năm chương hiện có trong `report/`; dữ liệu nền V1, chưa đồng bộ V3.
- Bộ MATLAB 3 bar/0,09 Hz cùng số liệu và báo cáo kiểm thử Octave được lưu; không phải chứng nhận chạy MATLAB R2017b.
- Hướng dẫn và mô hình tham khảo Simulink `.mdl`, mã tạo `.slx`; chưa xác minh biên dịch/chạy Simulink thật.
- Hình kích thước STEP V2; hồ sơ phân tích STEP V3 và catalogue SC.
- Các prompt tự động hóa COM, yêu cầu tách chi tiết, lưu một thư mục đã được thảo luận. Prompt không tương đương thao tác SolidWorks đã chạy.
- Thư mục `bao-cao/` đã gom hồ sơ theo yêu cầu. Bản gốc ngoài cây vẫn giữ để bảo toàn đường dẫn và lịch sử.

## 9. Dang dở và thứ tự thực hiện tiếp

1. Xác định PROJECT_DIR thực trên Windows và kiểm tra kết nối chỉ đọc tới MATLAB/SolidWorks đang mở. Người dùng báo MATLAB AutomationServer/COM đã hoạt động; môi trường Linux này chưa xác minh phiên Windows.
2. Đo/định danh đế V3, giữ nguyên 18 khối; xác định vai trò các lỗ và khối rời.
3. Xác nhận đầy đủ catalogue xy lanh, CA, mắt trâu/chốt/bạc; tính chuỗi kích thước thu hết và vị trí lắp. Không ép scale thiết bị tiêu chuẩn.
4. Dựng assembly và từng Part có tên, BOM và exploded view; chưa có tập SLDPRT/SLDASM mới được xác minh.
5. Chốt tâm khớp cuối, hướng chốt, chống xoay cần, COM/quán tính từ vật liệu đúng; cập nhật MATLAB rồi chạy lại. Không sao chép kết quả V1 sang V3.
6. Chỉ sửa các phần Word chịu ảnh hưởng; bổ sung catalogue và nguồn đã kiểm chứng.
7. Khi chuyển sang mô phỏng thật: mô hình hai buồng, phản hồi vị trí/áp, trễ van, ma sát, giới hạn và chiến lược an toàn; xuất Multibody và kiểm tra DOF/vòng kín.
8. Đo FAD, áp hai buồng, rò rỉ, ma sát, thời gian trễ, nhiệt máy nén; hoàn thiện Chương 5 bằng số liệu thật.

## 10. Điểm chưa chắc chắn và rủi ro kết luận

- Chưa xác định Lmin/catalogue đầy đủ và độ vươn ren; 731 mm là giả thiết, 739,5 mm là khoảng cách đo ở một tư thế.
- Chưa xác định lực ngang, mô-men cho phép, ổn định cần, mỏi, chốt/tai gá và an toàn chống tụt cho tải người.
- Chưa xác định độ cứng/tính nén khí bị nhốt, khí trong ống, thể tích chết, nhiệt, rò rỉ và dòng sai chiều khi chuyển van.
- Không biết FAD thật, giới hạn chạy liên tục/nhiệt PA-12L. Áp 6–8 bar trong bình khác áp 3 bar sau điều áp.
- Chưa có phép đo chuyển động thực, không có kết luận ghế thật đã đạt.
- Gói lịch sử `Ghe3_Simulink_ClosedLoop_R2017b.zip` từng được nhắc nhưng chưa tìm thấy bản byte tương ứng hiện tại; không dùng các số liệu tuyên bố cũ làm bằng chứng. Gói hướng dẫn tham khảo hiện có là sản phẩm khác, có giới hạn riêng.
- “prompt cho word” từng là tên nội dung trong hội thoại; chưa xác minh có tệp riêng đã lưu. Các yêu cầu hình học mới hơn phải được ưu tiên.

## 11. Quy tắc quản lý từ đây

`report/`: bản thảo; `data/`: dữ liệu gốc, catalogue, mã và kết quả; `figures/`: hình; `reviews/`: từng lượt review riêng. Mỗi kết quả phải ghi phiên bản hình học, tham số và nguồn. Không xóa dữ liệu gốc; không dùng hình V2 minh họa V3 mà không ghi rõ. Kiểm tra manifest SHA256 khi bàn giao. Muốn chuyển hẳn các đường dẫn cũ cần sửa và kiểm thử các tham chiếu liên quan trước.
