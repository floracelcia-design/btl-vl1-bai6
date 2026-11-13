function [v0, alpha1_deg, alpha1_rad, g] = inputParameters()
% INPUTPARAMETERS Nhập và kiểm tra tính hợp lệ của các thông số đầu vào
%   Đầu ra:
%       v0         : Vận tốc ban đầu (m/s), v0 > 0
%       alpha1_deg : Góc ném ban đầu (độ), 0 < alpha1_deg < 90
%       alpha1_rad : Góc ném ban đầu (radian)
%       g          : Gia tốc trọng trường (m/s^2), g > 0
   fprintf('==========================================================\n');
   fprintf('   NHẬP THÔNG SỐ BÀI TOÁN NÉM XIÊN TRONG TRỌNG TRƯỜNG\n');
   fprintf('==========================================================\n');
   % 1. Nhập và kiểm tra vận tốc ban đầu v0 (m/s)
   while true
       v0 = input('1. Nhập vận tốc ban đầu v0 (m/s) [v0 > 0]: ');
       if isnumeric(v0) && isscalar(v0) && isreal(v0) && ~isnan(v0) && isfinite(v0) && v0 > 0
           break;
       else
           fprintf('   [LỖI] Dữ liệu không hợp lệ! Vận tốc v0 phải là một số thực dương.\n\n');
       end
   end
   % 2. Nhập và kiểm tra góc ném ban đầu alpha1 (độ)
   while true
       alpha1_deg = input('2. Nhập góc ném alpha1 (độ) [0 < alpha1 < 90]: ');
       if isnumeric(alpha1_deg) && isscalar(alpha1_deg) && isreal(alpha1_deg) ...
               && ~isnan(alpha1_deg) && isfinite(alpha1_deg) && alpha1_deg > 0 && alpha1_deg < 90
           break;
       else
           fprintf('   [LỖI] Dữ liệu không hợp lệ! Góc ném phải nằm trong khoảng (0, 90) độ.\n\n');
       end
   end
   % 3. Nhập và kiểm tra gia tốc trọng trường g (m/s^2)
   while true
       g_in = input('3. Nhập gia tốc trọng trường g (m/s^2) [Nhấn Enter để dùng mặc định 9.81]: ');
       if isempty(g_in)
           g = 9.81;
           fprintf('   -> Đã chọn giá trị mặc định: g = 9.81 m/s^2.\n');
           break;
       elseif isnumeric(g_in) && isscalar(g_in) && isreal(g_in) && ~isnan(g_in) && isfinite(g_in) && g_in > 0
           g = g_in;
           break;
       else
           fprintf('   [LỖI] Dữ liệu không hợp lệ! Gia tốc g phải là một số thực dương.\n\n');
       end
   end
   % Quy đổi góc sang radian để thống nhất với các module khác (TV1, TV4, TV6)
   alpha1_rad = deg2rad(alpha1_deg);
   fprintf('----------------------------------------------------------\n');
   fprintf('   [THÀNH CÔNG] Đã ghi nhận: v0 = %.2f m/s | alpha1 = %.2f độ (%.4f rad) | g = %.2f m/s^2\n', ...
           v0, alpha1_deg, alpha1_rad, g);
   fprintf('==========================================================\n\n');
end
