# Ví dụ và hướng dẫn Simulink

Đọc [hướng dẫn thao tác](HUONG_DAN_MATLAB_SIMULINK.md).

Sau khi tải ZIP và giải nén, trong MATLAB chạy:

```matlab
p = ghe3_reference_init();
open_system('ghe3_ik_reference.mdl');
% Hoặc tạo hai model SLX:
build_ghe3_reference;
```

Ví dụ chỉ mô phỏng tín hiệu tham chiếu và logic van; chưa có plant khí nén liên kết. Xem [phạm vi kiểm tra](VALIDATION.md).
