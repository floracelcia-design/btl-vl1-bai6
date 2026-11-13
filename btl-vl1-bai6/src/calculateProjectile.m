   function [T, H, R, x, y, t] = calculateProjectile(v0, alpha_deg, g)
% CALCULATEPROJECTILE Tính thông số đặc trưng (T, H, R) và tạo 500 điểm tọa độ quỹ đạo
%   Đầu vào:
%       v0        : Vận tốc ban đầu (m/s)
%       alpha_deg : Góc ném (độ)
%       g         : Gia tốc trọng trường (m/s^2)
%   Đầu ra:
%       T         : Thời gian bay tổng cộng (s)
%       H         : Độ cao cực đại (m)
%       R         : Tầm bay xa trên mặt phẳng ngang (m)
%       x, y      : Vector hàng (1x500) chứa tọa độ ngang và đứng của quỹ đạo (m)
%       t         : Vector hàng (1x500) chứa các mốc thời gian tương ứng (s)
   % Kiểm tra an toàn đầu vào (phòng trường hợp gọi hàm trực tiếp không qua inputParameters)
   if v0 <= 0 || alpha_deg <= 0 || alpha_deg >= 90 || g <= 0
       error('calculateProjectile:InvalidInput', ...
             'Thông số đầu vào không hợp lệ (Yêu cầu: v0 > 0, 0 < alpha < 90, g > 0).');
   end
   % 1. Chuyển đổi góc từ độ sang radian
   alpha_rad = deg2rad(alpha_deg);
   % 2. Tính các thông số đặc trưng của chuyển động ném xiên
   T = (2 * v0 * sin(alpha_rad)) / g;          % Thời gian bay (s)
   H = (v0^2 * (sin(alpha_rad))^2) / (2 * g);  % Độ cao cực đại (m)
   R = (v0^2 * sin(2 * alpha_rad)) / g;        % Tầm bay xa (m)
   % 3. Khởi tạo 500 điểm rời rạc phục vụ vẽ quỹ đạo mượt
   N = 500;
   t = linspace(0, T, N);                      % Chia đều thời gian từ 0 đến T thành 500 điểm
   % 4. Tính tọa độ (x, y) theo phương trình tham số thời gian
   x = (v0 * cos(alpha_rad)) .* t;
   y = (v0 * sin(alpha_rad)) .* t - 0.5 * g .* (t.^2);
   % Khử sai số dấu phẩy động tại điểm chạm đất cuối cùng (đảm bảo y(end) = 0 tuyệt đối)
   y(end) = 0;
end
