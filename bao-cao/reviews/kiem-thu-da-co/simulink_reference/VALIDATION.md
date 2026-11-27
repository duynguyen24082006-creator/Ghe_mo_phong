# Phạm vi kiểm tra

Bản hướng dẫn và ví dụ mới, dựng lại theo yêu cầu chỉ cần hướng dẫn và mô hình tham khảo. Không phải khôi phục nguyên gói vòng kín cũ.

- 9 nhóm kiểm tra hàm số đã qua bằng GNU Octave 9.4.0; xem test_report.txt.
- Kiểm tra trung tính 981 mm; dấu ga/phanh/lái; giới hạn tham chiếu ±4°; trễ van không chuyển sớm và thời gian giữ trạng thái.
- Mã builder và S-function được Octave đọc cú pháp; chưa được MATLAB/Simulink mở hoặc compile.
- Tệp MDL được viết ở định dạng văn bản tham khảo, chưa được trình nạp Simulink xác nhận.
- API hướng tới R2017b; cần Ctrl+D/Update Diagram trên máy đích.
- Không có kết quả chuyển động thật, áp suất hai buồng, lưu lượng hoặc cảm giác người được kiểm chứng trong các ví dụ.
- Phản hồi trong testbench van là tín hiệu lập sẵn, không phải nghiệm vật lý.
- core/ lấy nguyên từ MATLAB_PBL2_CA_3bar_009Hz.zip đã có trên GitHub.
- Không đưa lại các kết quả/nhật ký của gói vòng kín cũ khi chưa khôi phục được tệp đó.

Dòng `ignoring const execution_exception& while preparing to exit` xuất hiện khi Octave đóng trong môi trường này; lệnh kiểm thử trả mã 0 và các assert đã qua.
