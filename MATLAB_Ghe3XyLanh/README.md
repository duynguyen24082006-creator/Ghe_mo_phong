# MATLAB: ghế mô phỏng khí nén ba chân 3-RPS

Chương trình dùng ba chân **R-P-S**: khớp quay một trục R ở đế, xy lanh khí nén P, khớp cầu S ở bàn ghế. Ba điểm gắn trên mỗi bàn tạo tam giác đều. Giả thiết bổ sung: **trục ba khớp R nằm ngang và tiếp tuyến đường tròn đế**. Cần kiểm tra hướng trục này trên bản vẽ thật; khớp R hướng khác cần đổi phương trình ràng buộc. Mô hình không có dẫn hướng trung tâm.

Kích thước, tải, vật liệu, áp suất và hành trình mặc định chỉ là **số liệu minh họa**. Chiều dài tâm chốt khi thu 380 mm và hành trình 200 mm để chừa khoảng cho thân/nắp và đầu lắp; chưa đối chiếu một mã xy lanh cụ thể. Chương trình tính ngoại tuyến; dữ liệu xuất không phải lệnh chạy van hoặc điều khiển ghế thật.

## Chạy trên MATLAB

Giải nén toàn bộ thư mục vào cùng một nơi, chọn nó làm Current Folder rồi chạy:

```matlab
r = run_ghe3();     % Nhập số liệu qua các hộp thoại rồi tính và vẽ
test_ghe3;          % Kiểm tra thuật toán, không cần toolbox
```

Các hộp thoại chia thành hình học/tải, quán tính, khí nén, quỹ đạo, cần piston, khớp/ống và dầm. Giữ giá trị sẵn có để chạy ví dụ. Nhấn Cancel dừng mô phỏng. Tensor quán tính nhập dạng `[10 0 0; 0 12 0; 0 0 8]`; các vectơ nhập dạng `[0 0 300]`. Bộ nhập chỉ chấp nhận số và ma trận số, không chạy biểu thức tùy ý. Không có MATLAB Desktop thì chuyển sang nhập ở Command Window; Enter giữ giá trị cũ.

Chạy lại tự động bằng bộ tham số đã lưu hoặc chỉnh trực tiếp:

```matlab
p = ghe3_defaults();
p.massPerson = 75;             % kg
p.massSeat = 45;               % kg: toàn bộ bộ phận chuyển động, chưa gồm người
p.boreDiameter = 0.063;        % m
p.pSupply = 0.60e6;            % Pa, áp dư
p = ghe3_validate(p);          % Tự tính p.mass = massPerson + massSeat
r = run_ghe3(false,p,fullfile(pwd,'ket_qua_cua_toi'));
% false: không hỏi số liệu, không mở hình; dùng được MATLAB batch hoặc Octave.
```

Nếu muốn nhập ở console nhưng vẫn vẽ sau khi tính:

```matlab
p = ghe3_input(ghe3_defaults(),'console');
r = run_ghe3(false,p);
ghe3_plot(r,fullfile(pwd,'ket_qua'));
```

Khuyến nghị MATLAB R2018b trở lên. Đã kiểm tra tính toán không giao diện bằng GNU Octave 9.4.0. Không cần Optimization, Robotics hay Symbolic Toolbox. MATLAB có giao diện và tính năng xuất hình chưa được chạy trong máy kiểm tra này.

## Tham số và đơn vị

Trong cấu trúc `p`, tất cả đại lượng dùng SI: m, kg, s, rad, N, Pa. Hộp thoại đổi sang mm, độ, MPa hoặc GPa khi cần và ghi đơn vị ngay trong nhãn. Ba xy lanh cùng loại; thông số áp dụng giống nhau cho cả ba chân.

| Nhóm | Trường `p` | Ý nghĩa |
|---|---|---|
| Tam giác | `rb`, `rp` | Bán kính tâm khớp, không phải cạnh; cạnh = √3 lần bán kính |
| Hướng tam giác | `baseAngle`, `platformAngle` | Góc pha các điểm gắn trong hệ đế và hệ bàn; ví dụ bằng 0 |
| Kích thước | `h0`, `Lmin`, `stroke` | Cao độ gốc O; chiều dài tâm chốt lúc thu; hành trình |
| Tải | `massPerson`, `massSeat`, `com`, `inertia` | Khối lượng người/phần chuyển động; COM chung trong hệ bàn; tensor tại COM chung trong trục bàn |
| Ngoại lực | `Fexternal`, `Mexternal` | Lực và mô men tác dụng tại COM, biểu diễn trong hệ thế giới |
| Khí nén | `boreDiameter`, `rodDiameter`, `pSupply`, `pExhaust`, `pAtm` | Đường kính piston/cần, áp cấp/áp xả **dư**, áp khí quyển **tuyệt đối** |
| Giới hạn catalog | `ratedPressure`, `maxSpeed`, `maxJointAngle` | Giá trị nhập từ nhà sản xuất; áp 0,8 MPa mặc định chỉ giả định |
| Tổn hao | `efficiency`, `friction` | Hiệu suất phần tổn hao chưa gồm ma sát Coulomb; ma sát trừ riêng để tránh đếm lại |
| Quỹ đạo | `ampH`, `ampRoll`, `ampPitch`, `frequency`, `duration`, `dt` | Biên độ, tần số, thời gian, bước lấy mẫu |
| Giới hạn số | `maxPoseAngle`, `maxCondition`, `workspaceSamples` | Góc tư thế, điều kiện Jacobian đã chuẩn hóa, số điểm mỗi trục lưới |
| Hệ số | `loadFactor`, `nStrength` | Hệ số tăng tải dự phòng và hệ số an toàn vật liệu, đều ≥1; gia tốc được tính trước khi nhân tải |
| Cần | `rodE`, `rodFy`, `rodEccentricity`, `rodUnsupportedBase`, `rodK` | E, giới hạn chảy, lệch tâm, chiều dài cần tự do lúc thu, hệ số liên kết ổn định |
| Chốt/tai | `pinDiameter`, `pinShearPlanes`, `pinFy`, `pinPlateThickness`, `pinBearingPlates`, `pinPlateFy` | Hình học và vật liệu chốt/tai, số mặt cắt/số tai thực sự cùng nhận tải |
| Ống | `cylinderWall`, `cylinderFy` | Chiều dày ống và giới hạn chảy vật liệu ống |
| Dầm | `beamSpan`, `beamWidth`, `beamHeight`, `beamWall`, `beamFy`, `beamE` | Dầm hộp minh họa kê hai đầu, chịu một lực tập trung giữa nhịp |

`maxJointAngle` được mô hình bằng góc giữa trục chân và phương **+z của đế / +z của bàn**, không phải góc thay đổi so với tư thế ban đầu. Đây là quy ước nón giới hạn đơn giản; giới hạn thật của khớp R và S phải lấy theo catalog và bản vẽ. `rodUnsupportedBase + (L-Lmin)` là chiều dài cần tự do, **không phải chiều dài toàn xy lanh**. Quán tính mặc định không được tự suy ra từ khối lượng người; cần đo hoặc lấy từ CAD cụm chuyển động, áp dụng định lý trục song song để quy về COM chung.

## Động học, lực và chuyển động phụ

Tọa độ độc lập là `q = [h; roll; pitch]`. Động học 3-RPS có chuyển động phụ `x`, `y`, `yaw`; không được mặc định cả ba bằng 0 khi ghế nghiêng. Mỗi chân phải thỏa `t_i'*(c + R*a_i - b_i) = 0`, với `t_i` là trục R tiếp tuyến. `ghe3_geometry` giải ba ràng buộc trên nhánh gần tư thế ban đầu rồi lấy đạo hàm ẩn để tính Jacobian chính xác `J = dL/dq`. Với tam giác cùng hướng ở ví dụ:

```text
yaw = atan2(sin(pitch)*sin(roll), cos(pitch)+cos(roll))
R = Rz(yaw)*Ry(pitch)*Rx(roll)
x = rp/2*(R11-R22),  y = -rp*R21,  c = [x;y;h]
L_i = norm(c + R*a_i - b_i)
Ldot = J*qdot
```

Chỉ số điều kiện dùng `Js = J*diag([rp,1,1])/rp`, tránh so trực tiếp cột m/m với cột m/rad. Đồng thời theo dõi điều kiện Jacobian ràng buộc thụ động sau khi chuẩn hóa các tọa độ x/y bằng `rp`; cả hai phải dưới `maxCondition`. Bài toán thuận `ghe3_fk` dùng Newton có giảm bước và tắt dần, cần dự đoán `q0`; chỉ trả về **nhánh cục bộ gần `q0`**, không chứng minh nghiệm duy nhất cho toàn cơ cấu. Luôn đọc `info.converged` và `info.residual`.

Lực tính theo Newton–Euler của toàn bộ cụm chuyển động tại COM, gồm trọng lực, quán tính quay, gia tốc COM và ngoại lực; khối lượng/quán tính riêng các chân chưa được đưa vào. `J'*f=Q`, quy ước `f>0` là nén. Ngoài lực dọc trục `f`, mỗi chân có lực ngang `lambda*t_i`. Phần dư cân bằng 6 chiều cho phép khôi phục `lambda` rồi kiểm tra công ảo bằng 0. Mô men đòi hỏi ở khớp R đế xấp xỉ `norm((P_i-B_i) × (lambda_i*t_i))`; không thể coi chân 3-RPS là thanh chỉ chịu kéo/nén.

Gia tốc cần và gia tốc COM dùng đạo hàm hướng trung tâm của Jacobian theo vận tốc tư thế, bước nhỏ có kiểm tra đối chiếu sai phân độc lập. Quy tắc này không bao gồm động lực học khí nén.

## Phạm vi kiểm tra khí nén và độ bền

Lực khả dụng khi duỗi là `eta*(pS*A-pE*Aann)-friction`; khi thu là `eta*(pS*Aann-pE*A)-friction`. Hai áp suất dùng cùng mốc **áp dư**. Kiểm tra lực theo tải động nhân `loadFactor`, không nhân hệ số này lần nữa vào quỹ đạo.

Lưu lượng là thể tích quét buồng cấp theo chiều vận tốc, quy đổi về thể tích ở áp khí quyển bằng **áp tuyệt đối** `(pSupply+pAtm)/pAtm`, giả thiết cùng nhiệt độ. Tổng lấy tại **cùng thời điểm** của ba chân. Kết quả L/min này không tự động là NL/min ở nhiệt độ chuẩn khác; chưa có nạp thể tích chết/ban đầu, rò khí, động lực học áp buồng, van và lưu lượng xả. Không dùng trực tiếp làm công suất máy nén cuối cùng.

Kiểm tra cần gồm kéo/nén, uốn lệch tâm và một sàng lọc lực ngang theo giả thiết công xôn: giả thiết toàn bộ lực ngang truyền lên đầu cần tự do như công xôn. Mô hình gối piston/bạc thật có thể khác. Kiểm Euler chỉ hiện kết quả khi độ mảnh ≥ `pi*sqrt(E/fy)`; ranh giới này gần đúng và cần xác nhận giới hạn tỉ lệ của vật liệu. Ngoài miền đó chương trình ghi **NOT ASSESSED**, không coi là đạt. Khi tải nén lớn hơn 0,3 tải Euler, cần phân tích bậc hai. Không suy ra ổn định toàn xy lanh từ kiểm cần.

Chốt kiểm cắt và ép mặt theo hợp lực `sqrt(f^2+lambda^2)`; lực dọc trục chốt R và bộ phận chặn chốt vẫn phải kiểm riêng. Ống dùng Lamé thành dày có hai đầu kín ở áp cấp; nắp, ren, cổng và gioăng chưa được kiểm. Dầm minh họa chỉ là một dầm hộp kê hai đầu với tải giữa nhịp `loadFactor*max(abs(m*(g+hddot)))`; chưa thay thế mô hình khung thật, tải lệch tâm hay gia tốc quay COM.

Không có kết luận chứng nhận an toàn toàn ghế. Còn thiếu kiểm mỏi, liên kết/hàn, khung 3D, giới hạn tải ngang/gối dẫn hướng và tải cho phép của nhà sản xuất, áp quá độ, mất khí và cơ cấu chặn cơ khí. Xác nhận hướng trục R thật trước khi dùng tính toán cho chế tạo.

## Tệp xuất và kết quả minh họa

Thư mục `ket_qua/` có:

- `trajectory.csv`: tư thế, chuyển động phụ, chiều dài/vận tốc/gia tốc, lực dọc trục/lực ngang, mô men đế, lưu lượng và cờ kiểm từng thời điểm; đơn vị nằm trong tên cột.
- `workspace_sampled.csv`: lưới tư thế lấy mẫu và các kiểm hình học. Đây là **lưới khảo sát**, không phải chứng minh toàn bộ miền liên tục hoặc khả năng chịu tải trên cả miền.
- `summary.csv`: cực trị số dùng đối chiếu; `screening_notes.txt`: trạng thái và phần chưa đánh giá.
- `results.mat`: biến `r` chứa mọi kết quả, `r.p` là tham số đã dùng và `r.strength` là kiểm sơ bộ.
- Hai hình PNG được thêm khi chạy giao diện: `kinematics_forces.png`, `workspace_flow.png`.

Ví dụ 135 kg, xy lanh Ø63/25 mm, áp cấp dư 0,6 MPa, tần số 0,3 Hz, biên độ nâng 20 mm và nghiêng 4°: chiều dài khoảng 445,06–522,71 mm, tốc độ lớn nhất 0,07360 m/s, lực dọc trục 376,93–514,24 N; tổng khí quy đổi cực đại đồng thời 168,11 L/min theo giả thiết trên. Có chuyển động phụ ngang đến 0,4385 mm và yaw đến 0,06984°. Cần mặc định nằm ngoài miền áp dụng Euler; ổn định vẫn **chưa được đánh giá**.

## Kiểm chứng

`test_ghe3` kiểm Jacobian với sai phân độc lập; 200 tư thế ngẫu nhiên động học ngược/thuận; cân bằng đối xứng và COM lệch tâm theo nghiệm giải tích; đóng ràng buộc RPS và chuyển động phụ theo công thức đóng; cân bằng không gian/công ảo; phương trình Lagrange từ năng lượng tính độc lập; một bộ hồi quy động lực học do chương trình Python độc lập cung cấp; đạo hàm quỹ đạo; dữ liệu sai; miền áp dụng Euler; trường hợp áp suất thấp phải không đạt. Không mở hình hoặc truyền lệnh tới phần cứng.

Trước khi chạy ghế thật cần có bộ điều khiển van, đo vị trí và áp buồng, quỹ đạo chuyển tiếp êm có giới hạn gia tốc/giật, liên động và dừng khẩn; quỹ đạo sin hiện tại chỉ là phép thử ngoại tuyến và bắt đầu với vận tốc có thể khác 0.
