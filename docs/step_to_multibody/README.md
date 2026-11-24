# Đồng bộ STEP mới → MATLAB R2017b → Simscape Multibody

Áp dụng cho ghế 3-RPS đã cung cấp STEP `shapr3d_export_2026-10-19_07h47m.step`. Đây là hướng dẫn đồng bộ hình học và điều khiển chuyển động; không coi mô hình đã được xuất/chạy bằng SolidWorks hoặc MATLAB R2017b trong môi trường biên soạn.

## 1. Chốt dữ liệu đúng trước khi nối mô hình

| Đại lượng | Bộ MATLAB cũ | STEP đã đo |
|---|---:|---:|
| Bán kính tâm khớp dưới | 420 mm | ≈461,880216 mm |
| Bán kính tâm khớp trên | 360 mm, giả thiết | ≈461,880216 mm tại trạng thái hiện có |
| Cạnh tam giác tâm | 727,461 / 623,538 mm | Cả hai ≈800 mm |
| Thân xy lanh tại tư thế tham chiếu | Nghiêng ≈3,5065° | Đứng thẳng theo CAD Z |
| Khoảng cách tâm chốt trên–dưới | Trung tính giả định 981 mm | 739,50 mm ở vị trí lắp CAD |
| Mốc h | 979,163418 mm trong bộ cũ | 739,50 mm nếu gốc O ở mặt phẳng chốt dưới |

CAD Z của tâm chốt dưới là 64 mm; tâm chốt trên là 803,5 mm. Bởi vậy 739,5 mm là **hiệu hai cao độ khớp**, không phải cao độ đỉnh khung (871 mm), chiều cao bao (874 mm), hoặc chiều dài vỏ xy lanh.

Hành trình 500 mm vẫn là thông số danh nghĩa của SC63-500 đã chọn. STEP một tư thế không tự chứng minh phiên bản xy lanh trong CAD đúng mã đó, cũng không cho biết vị trí thu hết. Chưa gán 739,5 mm thành Lmin hoặc hành trình trung tính. Chiều dài tâm khớp khi thu hết 731 mm của bộ cũ vẫn cần đo/catalogue.

C1/C2/C3 trong [bộ hình CAD](../kich_thuoc_STEP_2026_10_19/README.md) là nhãn đo CAD, không mặc định trùng chân 1 sau, 2 trước trái, 3 trước phải của bộ mã trước. Lập bảng đối chiếu trước khi nối dây tín hiệu.

## 2. Nhập và tổ chức mô hình SolidWorks

### 2.1 STEP có hình học nhưng không có lịch sử thiết kế và Mates đầy đủ

1. Tạo thư mục dự án riêng, giữ STEP gốc.
2. File → Open → chọn STEP. Trong Options, kiểm tra đơn vị là mm.
3. Mô hình có thể mở thành assembly hoặc một part nhiều solid, tùy dữ liệu STEP và thiết lập import/3D Interconnect. Không mặc định chọn Save As SLDASM là đủ để biến một part thành assembly.
4. Nếu là assembly: lưu assembly và các part thành SLDASM/SLDPRT. Nếu dùng tham chiếu STEP/3D Interconnect, quyết định giữ hoặc ngắt liên kết trên bản sao tùy phiên bản; ngắt liên kết không phục hồi các Mates/lịch sử feature đã mất.
5. Nếu là part nhiều solid: kiểm tra Solid Bodies; dùng Insert → Features → Save Bodies, đặt tên các body và chọn Create Assembly nếu chức năng đó có trong phiên bản. Cũng có thể dùng Insert into New Part rồi dựng assembly mới. Có 77 solid đã đọc từ file này, không có nghĩa cơ cấu cần 77 khớp.
6. Chạy Import Diagnostics khi có lỗi bề mặt; kiểm tra lại các tâm/lỗ sau sửa. Không dùng hộp bao để thay thế đo tâm khớp.

### 2.2 Gom theo vật chuyển động cứng

- Khung đế và các chi tiết gắn cứng: một nhóm đế.
- Mặt đỡ ghế và các phụ kiện gắn cứng: một nhóm sàn.
- Mỗi chân: nhóm thân xy lanh và nhóm cần piston.
- Bulông, đai ốc, gá cố định đi theo đúng vật chúng gắn, không thêm joint chuyển động cho từng bulông.
- Chỉ Fix khung đế. Các vật chuyển động phải Float và được ràng buộc đúng.
- Subassembly xy lanh cần giải chuyển động tương đối: kiểm tra Solve as Flexible/Make Flexible. Subassembly Rigid có thể làm cơ cấu bị khóa dù các Mates bên trong có vẻ đúng.

### 2.3 Định nghĩa hệ trục và đo tâm

Tạo Reference Geometry → Coordinate System:

- O: trọng tâm tam giác ba tâm chốt dưới, tại CAD Z=64 mm.
- Z: lên trên.
- X/Y: chọn theo CAD trước, sau đó đối chiếu hướng trước/trái của ghế thật.
- P: tâm tam giác khớp trên, gắn với mặt ghế; ở tư thế CAD ban đầu các trục song song O nếu đúng dữ liệu đo.

Một Coordinate System mới chỉ định nghĩa frame, **không tự dời mọi body hoặc đổi gốc assembly**. Có thể giữ nguyên gốc CAD, tạo frame O và P tương ứng bằng Rigid Transform trong Multibody rồi đo chuyển động giữa O và P. Không kéo từng chi tiết về gốc riêng làm mất lắp ráp.

Để đo đúng:

1. Hiển thị Temporary Axes hoặc tạo Reference Axis từ mặt trụ.
2. Tạo Reference Point tại giao trục chốt với trục xy lanh; đo tâm khớp, không đo bề mặt ngoài.
3. Dùng Evaluate → Measure để lấy tọa độ XYZ từng điểm theo cùng hệ trục.
4. Bán kính là khoảng cách tâm tam giác đến tâm chốt, không phải bán kính vỏ, cạnh ngoài khung hoặc cạnh tấm ghế.
5. Lấy Ai trong hệ P và Bi trong hệ O. Không lấy tọa độ khớp trên trong hệ thế giới rồi dùng nguyên làm Ai trong hệ ghế.

Dữ liệu quy về O của file này, m, thứ tự CAD C1,C2,C3:

```
B ≈ [-0.230940108   0.461880216  -0.230940108
      0.400000000   0.000000000  -0.400000000
      0             0             0           ]
A ≈ B
q_CAD = [0.7395;0;0]
L_CAD = [0.7395;0.7395;0.7395]
```

### 2.4 Lấy Lmin, stroke, khối lượng và quán tính

- L_CAD: đo giữa hai tâm chốt của cùng chân tại tư thế đang lắp.
- Lmin: cấu hình thu hết đã xác nhận; đo lại khoảng cách tâm ở cấu hình này.
- Lmax: cấu hình duỗi hết đã xác nhận. Stroke = Lmax−Lmin nếu không thay cấu hình gá/ăn ren.
- Hành trình hiện tại: L_CAD−Lmin sau khi Lmin đã xác nhận.
- Chiều dài thân: đo riêng phần vỏ/nắp; không dùng để thay cho Lmin hoặc stroke.
- Evaluate → Mass Properties: gán vật liệu/mật độ đúng cho từng cụm trước khi tin khối lượng; STEP có hình không đồng nghĩa có vật liệu đúng.
- Lấy COM trong hệ gắn với body cần mô phỏng, và tensor quán tính tại COM. Kiểm tra đơn vị kg·mm² hoặc kg·m²; đổi kg·mm² sang kg·m² bằng hệ số 10^-6.
- Không nhập thẳng Products of Inertia của một hệ trục vào tensor hệ khác khi chưa đối chiếu dấu và phép quay.

Giả thiết người 100 kg, ghế 20 kg, COM=[0;0;0,208333] m, I=diag([10 12 8]) kg·m² vẫn là giả thiết của bộ cũ. Không coi vừa đổi rb/rp là đã cập nhật động lực học. Nếu CAD đã có khối lượng mặt ghế, không cộng thêm cả 120 kg như một tải mới rồi tính trùng ghế. Mã cũ bỏ qua khối lượng chân; Multibody nhập quán tính chân thật sẽ cho lực khác.

## 3. Tạo Mates đúng 3-RPS

Mỗi nhánh có chuỗi:

`Đế → Revolute R → thân → Prismatic P → cần → Spherical S → mặt ghế`

| Khớp mục tiêu | Cách tạo ràng buộc CAD | Điều phải để tự do |
|---|---|---|
| R | Concentric quanh chốt CA + định vị dọc trục bằng mặt/Width phù hợp | Quay quanh chốt; không Lock rotation của chốt này |
| P | Đồng trục cần/thân + khóa quay tương đối bằng thiết kế chống xoay hoặc các mặt phẳng tham chiếu phù hợp | Tịnh tiến dọc trục; không mate khoảng cách dọc trục cố định |
| S | Coincident giữa hai điểm tâm khớp cầu | Ba quay tương đối; không ép thêm trục/plane song song |

Trong SolidWorks đây là tổ hợp Mates tạo bậc tự do, không nhất thiết là ba nút tên Revolute/Prismatic/Spherical. Coincident giữa hai **điểm** khác Coincident giữa hai mặt phẳng. Chọn sai đối tượng có thể khóa thêm bậc tự do.

Concentric đơn thuần thường còn cả tịnh tiến và quay dọc trục. Nếu nó được xuất thành Cylindrical Joint, cơ cấu không còn đúng giả thiết P một DOF. Xy lanh khí nén cần tròn không có chống xoay thực có thể có tự do quay; phải kiểm chứng phần cứng thay vì khóa quay tùy ý để ép mô hình thành 3-RPS.

Để hai khung nối qua ba chân, không Fix mặt ghế vào ground; không thêm một mate giữa mặt ghế và ground chỉ để tránh nó rơi trong CAD. Mô hình lý tưởng có ba DOF độc lập trước khi đặt ba chuyển động P. Đếm bậc tự do là kiểm tra topology, không chứng minh mọi tư thế đều tránh singularity.

## 4. Simscape Multibody Link và smimport

### 4.1 Cài đúng phiên bản

Trên Windows, đối chiếu MATLAB R2017b, bản SolidWorks và kiến trúc 64-bit theo bảng hỗ trợ của MathWorks. Không mặc định plugin R2017b hỗ trợ SolidWorks đời mới. Môi trường biên soạn không truy cập được trang tài liệu trực tuyến để xác nhận bảng phiên bản cụ thể; dùng bộ cài/tài liệu chính thức phù hợp máy bạn.

Với bộ cài chính thức có script installaddon.m:

```matlab
% Ví dụ tên gói; dùng đúng file bạn đã tải từ MathWorks.
installaddon('smlink.r2017b.win64.zip');
smlink_linksw;
```

`installaddon` ở quy trình này là script đi kèm hướng dẫn cài Link, không tự giả định mọi MATLAB đã có sẵn. Sau đăng ký, mở SolidWorks → Tools → Add-Ins, bật Simscape Multibody Link. Nếu không thấy menu, kiểm tra đăng ký, bitness và tương thích phiên bản trước khi sửa model.

### 4.2 Xuất và nhập

1. Mở assembly đã lưu, rebuild và kiểm tra chuyển động.
2. Tools → Simscape Multibody Link → Export → Simscape Multibody (tên menu có thể khác giữa phiên bản).
3. Xuất vào một thư mục riêng, ví dụ `D:\PBL2\CAD_export`.
4. Giữ XML và tất cả hình học được sinh ra. Quy trình Link thường dùng XML và STL; không tự coi R2017b hỗ trợ trực tiếp mọi định dạng CAD của bản mới.
5. Trong MATLAB:

```matlab
cd('D:\PBL2\CAD_export');
smimport('Ghe_3RPS.xml');
```

Tên model và file dữ liệu thường theo tên XML, ví dụ `Ghe_3RPS.slx`, `Ghe_3RPS_DataFile.m`. Kiểm tra các file thực được tạo. Script dữ liệu chứa struct `smiData` với transform/quán tính và metadata; XML không tự trở thành một mô hình khí nén.

Trong R2017b dùng `help smimport` hoặc `doc smimport` để kiểm đúng các tùy chọn của bản đang cài. Không dùng tùy chọn import của bản mới mà chưa kiểm.

### 4.3 Rà topology sau import

- Tìm ba Revolute, ba Prismatic, ba Spherical theo đúng nhánh.
- Mates có thể được ghép thành joint khác hoặc constraint; không coi một mate luôn xuất thành đúng một block.
- Kiểm điểm tâm của hai frame mỗi joint trùng nhau tại cấu hình lắp, và trục z của Prismatic dọc thân xy lanh.
- Kiểm trục R tiếp tuyến vòng khớp dưới, không nhầm song song thân.
- Nhóm các chi tiết gắn cứng thành đúng rigid body; tránh một cơ cấu bulông giả tự chuyển động.
- Dùng frame O/P và Transform Sensor để đo tư thế tương đối. So sánh theo đúng thứ tự Euler của thuật toán Rz(yaw)*Ry(pitch)*Rx(roll).

Kiểm mạng có World Frame, Mechanism Configuration với trọng lực [0 0 −9,81] m/s² và Solver Configuration phù hợp; không thêm trùng tùy tiện nếu import đã tạo.

## 5. Cập nhật mã MATLAB từ STEP

### 5.1 Dùng bản sao, chưa thay defaults cũ

Trong gói đi kèm:

```matlab
[pCAD,cad] = prepare_ghe3_STEP_800();
[L0,J0,g0] = ghe3_geometry(cad.qAtCAD,pCAD);
disp(1000*L0);
disp(J0);
```

Hàm cập nhật rb/rp≈0,461880216 m, thứ tự CAD C1/C2/C3 và h tham chiếu CAD 0,7395 m. Nó không ghi đè `ghe3_defaults.m` hoặc tự đổi Word/prompt.

Lmin, stroke và cạnh ngoài khung trong bản sao được đặt NaN **có chủ đích** để chặn mô phỏng đầy đủ với thông số cũ chưa xác nhận. Hàm hình học không cần các đại lượng đó nên vẫn kiểm được IK/Jacobi. Không gọi `ghe3_validate`/`ghe3_simulate` với bản sao này trước khi bổ sung các số đo còn thiếu. Sau khi đối chiếu đúng SC63-500, có thể nhập lại stroke danh nghĩa 0,5 m cùng Lmin đo đúng.

COM/quán tính/khối lượng kế thừa chỉ để cấu trúc có đủ trường; chưa coi động lực học đã nhận dạng theo CAD.

### 5.2 Vì sao không cần sửa tay công thức Jacobi?

Vòng kín và đạo hàm được tính lại từ geometry parameters:

```
D_i = c + R*A_i − B_i
L_i = norm(D_i)
T_i' * D_i = 0
Ldot = J(q)*qdot
Lddot = J(q)*qddot + Jdot*qdot
```

Trong đó điểm/tịnh tiến/L có đơn vị m; q=[h;Roll;Pitch], góc rad; vận tốc chân m/s, gia tốc m/s². Ba ràng buộc chốt giải x,y,yaw phụ. Các cột Jacobi theo h và theo góc có đơn vị khác nhau; dùng số điều kiện đã chuẩn hóa trong bộ mã.

Với thứ tự CAD C1/C2/C3, tại cấu hình đứng thẳng đang đo:

```
J_CAD ≈ [1   0.400000   0.230940
         1   0.000000  -0.461880
         1  -0.400000   0.230940]
```

Đây là kết quả tại đúng tư thế này, không thay thế hàm J(q) cho mọi tư thế. Tệp `test_ghe3_STEP_geometry.m` kiểm Jacobi sai phân, closure, FK và mapping tọa độ khớp.

### 5.3 Đồng bộ đủ biến

Ngoài rb/rp, cần rà: góc đặt tam giác, thứ tự chân, hướng chốt R, tọa độ khớp trong body, h tham chiếu, Lmin/Lmax, các giới hạn, COM, tensor I, khối lượng, điểm đặt ngoại lực.

Nếu CAD sau này không phải tam giác đều hoặc trục R không còn tiếp tuyến nằm ngang, hàm geometry hiện tại không mô tả đúng bằng cách chỉ đổi hai bán kính. Phải mở rộng code để nhận B/A/hingeAxes thực, rồi suy và kiểm ràng buộc tương ứng.

Không dùng lại lưu lượng 23,019547 L/phút hoặc lực của bộ 420/360 mm như kết quả của STEP mới. Phải tính lại sau khi xác nhận đầy đủ hình học và quỹ đạo/giới hạn.

## 6. Nối ba Prismatic Joint với MATLAB/Simulink

### 6.1 Chiều dài chân không tự bằng tọa độ joint

Đọc/sense tọa độ từng Prismatic tại đúng tư thế CAD và xác nhận chiều dương z. Quy đổi chung:

```
qJoint_i = qJointAtCAD_i + axisSign_i*(L_i − Lcad_i)
```

Tất cả chiều dài và qJoint tính bằng m; axisSign là +1 hoặc −1. Với file này Lcad_i=0,7395 m. qJointAtCAD do frame của model nhập quyết định, không tự gán 0 hoặc 250 mm.

Ví dụ CHỈ khi đã xác nhận ba joint đều đọc 0 ở CAD và cùng chiều dương làm dài chân:

```matlab
qJointAtCAD = [0;0;0];
axisSign = [1;1;1];
q_cmd = ghe3_joint_command(L, cad.LatCAD, qJointAtCAD, axisSign);
```

Nếu zero được dựng đúng tại thu hết, có thể dùng stroke L−Lmin. Không áp dụng cách đó khi zero chỉ là vị trí assembly đang mở. Đặc biệt không nối thẳng L=0,7395 vào một joint zero tại CAD=0: model sẽ bị yêu cầu dịch thêm 739,5 mm.

### 6.2 Cấu hình joint để chạy động học cưỡng bức

Với từng Prismatic:

- Actuation → Motion: Provided by Input.
- Actuation → Force: Automatically Computed (bài chuyển động cưỡng bức).
- Sensing: bật Position và Velocity nếu có, để kiểm tra.
- Các R/S để chuyển động thụ động; không thêm lệnh tư thế mặt ghế vào ground.

Chuỗi nối:

`L_ref(3) → đổi tọa độ/offset/dấu → Demux → 3 Simulink-PS Converter → cổng q của 3 Prismatic`

R2017b theo cách chuẩn này nhận **vị trí** tại q. Nếu đầu ra code là vận tốc, tích phân với điều kiện đầu đúng để tạo vị trí; không đưa m/s vào cổng vị trí. Nếu đầu ra đã là L, không tích phân thêm.

Cấp đủ ba chuyển động P độc lập cho cơ cấu có ba DOF là phù hợp. Không đồng thời cưỡng bức thêm h/Roll/Pitch hoặc x/y/yaw của mặt ghế: đó là các kết quả của cùng vòng kín.

### 6.3 Simulink-PS Converter và đạo hàm

Ở mỗi converter:

1. Input signal unit: `m` cho q Prismatic; không để mặc định dimensionless.
2. Trong Input Handling / Filtering and Derivatives của R2017b, chọn `Filter input, derivatives calculated`.
3. Dùng lọc bậc hai nếu khối/joint yêu cầu cả đạo hàm một và hai. Kiểm tra đúng các lựa chọn trong Help của block cài trên máy.
4. Hằng số thời gian khởi đầu có thể thử khoảng 0,01–0,05 s cho bài chuyển chậm; đây là tham số tuning, không phải thông số van hoặc cảm giác người đã xác nhận.
5. Kiểm điều kiện đầu của bộ lọc; đầu ra ban đầu phải khớp qJointAtCAD. Không giả định bộ lọc mặc định bắt đầu ở một giá trị khác 0 đúng như CAD.

Lọc làm tín hiệu tới joint khác tín hiệu gốc. Hãy so vị trí sensed với tín hiệu thực sau xử lý, không chỉ với L trước lọc. Ba bộ lọc có thể làm tư thế thực khác quỹ đạo IK gốc.

Nếu đã có qJoint, qJointdot, qJointddot trơn và nhất quán, có thể dùng lựa chọn cung cấp đạo hàm nếu converter R2017b của bạn hỗ trợ. Với hệ số dấu không đổi: qJointdot=axisSign*Ldot và qJointddot=axisSign*Lddot. Không đưa đạo hàm 0 cho một quỹ đạo đang chạy.

### 6.4 Khởi động từ đúng cấu hình CAD

1. Chưa cấp quỹ đạo cũ; đặt ba q_cmd bằng qJointAtCAD.
2. Ctrl+D, mở Mechanics Explorer, kiểm tâm khớp và pose O→P.
3. Thử một thay đổi nhỏ sau khi kiểm tra chiều và khoảng hành trình cho phép. Đừng bắt đầu bằng ±20 mm/±4° khi chưa biết CAD đang gần điểm thu hết hay không.
4. Quỹ đạo phải bắt đầu từ CAD pose với vận tốc/gia tốc phù hợp. Benchmark cũ có Roll=4° ngay tại t=0; không nối trực tiếp nó vào CAD đang Roll=0.
5. Dùng ramp trơn/đa thức bậc năm và kiểm toàn quỹ đạo trong stroke/joint limits. Không cắt riêng từng hành trình rồi nói tư thế vẫn đúng.

Ban đầu có thể dùng ode15s, MaxStep≈0,001–0,005 s, RelTol≈1e-4 đến 1e-5 để thử; điều chỉnh theo stiffness, bộ lọc và kết quả hội tụ. Đây là cấu hình gợi ý, chưa chạy kiểm trên model nhập của bạn. State Targets ban đầu phải nhất quán; chỉ đặt High Priority cho các tọa độ độc lập cần thiết, không ép High mọi joint thụ động.

## 7. Vòng kín và lỗi thường gặp trên cơ cấu song song

| Hiện tượng | Kiểm tra trước |
|---|---|
| Mặt ghế không chạy hoặc assembly fully fixed | Fix/Float và subassembly Rigid/Flexible |
| Không assemble hoặc redundant constraints | Mate trùng, upper plate bị Fix, thêm joint nối plate-ground, vừa ép ba P vừa ép pose plate |
| Prismatic thành Cylindrical | Concentric còn cho rod quay; xem yêu cầu chống xoay thực |
| Khớp gãy/hình tách nhau | Frame joint không đặt tại tâm, nhầm Ai hệ body với điểm thế giới, sai offset/dấu |
| Chuyển động lớn gấp 1000 | mm/m sai hoặc đổi đơn vị hai lần |
| Thiếu đạo hàm motion input | Converter chưa lọc/cung cấp đạo hàm, tín hiệu bậc không trơn |
| Input m/s vào q | Đang cấp vận tốc vào cổng vị trí |
| Algebraic loop | Vòng sensor→đại số→actuation có direct feedthrough; xác định nguyên nhân trước khi thêm delay |
| Force khác MATLAB cũ | COM/I/mass khác, chân có quán tính, joint friction, filter hoặc quỹ đạo sau lọc khác |

Nên dựng/kiểm từng chân R–P–S trước, rồi đóng vòng. Khi cần chẩn đoán, mở tạm một kết nối thụ động trên bản sao để xác định khớp/mate trùng; khôi phục topology đầy đủ sau sửa. Không mặc định xóa Spherical hoặc thay Weld chỉ vì solver báo lỗi.

Không thêm compliance tùy tiện để che sai vị trí frame. Nếu cơ cấu thật có mềm/độ rơ, đó là một mô hình vật lý bổ sung phải có tham số. Một delay hoặc Unit Delay cũng thay đổi bộ điều khiển, không phải thuốc chữa mọi lỗi algebraic loop.

## 8. Động học cưỡng bức khác động lực học khí nén

Cấp q cho Prismatic cho phép xem chuyển động 3D và tính lực cần để ép chuyển động. Nó không chứng minh PA-12L/van/áp 3 bar tạo được chuyển động đó.

Khi phát triển mô hình khí nén:

- Motion: Automatically Computed.
- Force: Provided by Input từ lực hai buồng đã trừ tổn thất được mô hình hóa.
- Sensing q/velocity → phản hồi điều khiển van.
- Phải giải áp suất hai buồng, dòng van, bình và cơ cấu liên kết.
- Không vừa ép q vừa đưa một luật lực độc lập rồi coi là cùng bài chuyển động tự do.

Các kết quả cũ `actualMotionSolved=false` không được đổi thành true chỉ vì có hoạt ảnh Mechanics Explorer.

## 9. Parametric link: đổi gì không cần export lại?

| Loại thay đổi | Có thể cập nhật trong MATLAB? | Lưu ý |
|---|---|---|
| Biên độ, tần số, thời gian quỹ đạo | Có | Chạy init, update/run; kiểm giới hạn và điểm đầu |
| Offset/sign tọa độ actuator | Có sau hiệu chuẩn | Không thay hình học thật |
| Rigid Transform do bạn tham số hóa | Có | Vị trí joint, body và geometry phải cùng nhất quán |
| Khối lượng/COM/I nhập thủ công bằng biến | Có | Đồng bộ hệ trục/đơn vị, tránh tính trùng CAD mass |
| Kích thước Solid dựng bằng primitive | Có | Dimension phải thực sự tham chiếu biến |
| Lỗ, mặt cắt, chiều dày hay chiều dài part CAD nhập STL/STEP | Không tự sửa từ Workspace | Cần sửa CAD và xuất lại, hoặc tái dựng hình học tham số |

Điều khiển hành trình làm rod trượt so với thân; không cần xuất lại CAD mỗi thời điểm. Nhưng thay bán kính vòng gá hoặc chiều dài vỏ thật là thay thiết kế, không phải chỉ thay tín hiệu chạy.

Ví dụ cấu hình riêng:

```matlab
[pCAD,cad] = prepare_ghe3_STEP_800();
mdl = 'Ghe_3RPS';  % thay ten model thuc
load_system(mdl);
ws = get_param(mdl,'ModelWorkspace');
assignin(ws,'pCAD',pCAD);
assignin(ws,'cad',cad);
```

Việc gán biến chỉ có tác dụng nếu parameter của block thực sự dùng biểu thức đó. Một block đang dùng `smiData.RigidTransform(17).translation` sẽ không tự đổi khi bạn thay pCAD.rb.

Lựa chọn quản lý:

- Giữ DataFile gốc và tạo script init riêng.
- Chạy DataFile trước rồi mới override có kiểm soát, hoặc chuyển parameter block sang cấu hình tự quản lý.
- Xem ID/name của từng RigidTransform/Solid; không hardcode sửa index 17 nếu chưa biết nó là frame nào.
- Giá trị translation/COM trong DataFile thường có comment mm; block cũng có unit. Nếu block dùng mm thì 0,2 m phải nhập 200 mm, không phải 0,2.
- Một RigidTransform nhập có thể là transform giữa hai frame local, không phải trực tiếp O→Bi; không gán tọa độ global vào bừa.
- Nếu thay tham số hình học/cấu trúc, tắt Fast Restart khi cần và Update Diagram/chạy lại; Mechanics Explorer không tự sửa mesh CAD theo một biến chưa liên kết.

## 10. Kiểm chứng mức đồng bộ

Không hứa “khớp 100%” chỉ từ một lần animation. Hãy lập các kiểm tra:

1. Ở CAD pose: ba L bằng 739,5 mm, khớp cảm biến sau mapping.
2. Frame O/P đúng mốc, không nhầm đỉnh khung với tâm chốt.
3. Tín hiệu một chân nhỏ: đúng chiều z và đúng scale mm/m.
4. So L sensed với L sau đổi offset/dấu/lọc.
5. Dùng ghe3_fk từ L sensed để so với pose đo của platform.
6. So cả x,y,yaw phụ, không chỉ Roll/Pitch.
7. Kiểm stroke, joint angle, singularity và va chạm hình học trên toàn quỹ đạo đã chọn.
8. Đặt dung sai đối chiếu cụ thể, ví dụ 0,1 mm cho một bài kiểm số nếu phù hợp; không coi đó là dung sai chế tạo của thiết kế.

Tệp helper kèm theo đã được kiểm số độc lập; xem test_report.txt. Chưa chạy SolidWorks export, smimport, converter hay joint actuation thực trên MATLAB R2017b. Các đường dẫn thư viện/menu có thể khác theo release; Help cục bộ của bản cài là nguồn xác nhận cuối cùng.
