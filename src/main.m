function main()
% MAIN Chương trình chính - Bài 6: Quỹ đạo ném xiên và góc ném cùng tầm xa
%   Trình tự:
%       1. Nhập v0, alpha1, g                      (inputParameters)
%       2. Giải sin(2*alpha2) = sin(2*alpha1)      (solveAngleSymbolic)
%       3. Tính T, H, R của từng vật               (calculateProjectile)
%       4. Tính vận tốc lúc chạm đất
%       5. Xuất kết quả và kiểm chứng |R1 - R2|
%       6. Vẽ hai quỹ đạo, lưu hình 300 DPI        (plotTrajectories)
%
%   Cách chạy: chuyển thư mục hiện hành vào src/ rồi gõ  main

    tol = 1e-6;   % Sai số cho phép của |R1 - R2| (m)

    % 1. Nhập dữ liệu
    [v0, alpha1_deg, ~, g] = inputParameters();

    % 2. Giải phương trình tìm góc ném thứ hai bằng Symbolic Math Toolbox
    [alpha2_deg, ~] = solveAngleSymbolic(alpha1_deg, v0, g);
    sameAngle = abs(alpha2_deg - alpha1_deg) < 1e-6;

    % 3. Thông số đặc trưng của hai vật
    [T1, H1, R1] = calculateProjectile(v0, alpha1_deg, g);
    [T2, H2, R2] = calculateProjectile(v0, alpha2_deg, g);

    % 4. Vận tốc tại thời điểm chạm đất
    [vLand1, beta1] = landingVelocity(v0, alpha1_deg, g, T1);
    [vLand2, beta2] = landingVelocity(v0, alpha2_deg, g, T2);

    % 5. Xuất kết quả
    fprintf('==========================================================\n');
    fprintf('   KẾT QUẢ\n');
    fprintf('==========================================================\n');
    fprintf('Dữ liệu đầu vào : v0 = %.2f m/s | alpha1 = %.2f độ | g = %.2f m/s^2\n', ...
        v0, alpha1_deg, g);
    fprintf('Nghiệm Symbolic : alpha2 = %.4f độ\n', alpha2_deg);
    if sameAngle
        fprintf(['Ghi chú         : alpha1 = 45 độ nên hai nghiệm trùng nhau, không có\n' ...
                 '                  góc ném thứ hai phân biệt; tầm xa đạt cực đại v0^2/g.\n']);
    end
    fprintf('----------------------------------------------------------\n');
    fprintf('%-32s %12s %12s\n', 'Thông số', 'Vật 1', 'Vật 2');
    fprintf('%-32s %12.4f %12.4f\n', 'Góc ném (độ)', alpha1_deg, alpha2_deg);
    fprintf('%-32s %12.4f %12.4f\n', 'Thời gian bay T (s)', T1, T2);
    fprintf('%-32s %12.4f %12.4f\n', 'Độ cao cực đại H (m)', H1, H2);
    fprintf('%-32s %12.4f %12.4f\n', 'Tầm xa R (m)', R1, R2);
    fprintf('%-32s %12.4f %12.4f\n', 'Tốc độ chạm đất (m/s)', vLand1, vLand2);
    fprintf('%-32s %12.4f %12.4f\n', 'Góc vận tốc chạm đất (độ)', beta1, beta2);
    fprintf('----------------------------------------------------------\n');

    % Kiểm chứng: hai vật phải có cùng tầm xa trong giới hạn sai số
    dR = abs(R1 - R2);
    if dR <= tol
        verdict = 'ĐẠT';
    else
        verdict = 'KHÔNG ĐẠT';
    end
    fprintf('Kiểm chứng      : |R1 - R2| = %.3e m (cho phép %.0e m) -> %s\n', ...
        dR, tol, verdict);
    fprintf('==========================================================\n');

    % 6. Vẽ quỹ đạo và lưu hình vào thư mục figures/ ở gốc repo
    figDir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    outFile = fullfile(figDir, sprintf('quydao_v0_%g_alpha1_%g.png', v0, alpha1_deg));
    plotTrajectories(v0, alpha1_deg, alpha2_deg, g, outFile);
    fprintf('Đã lưu hình quỹ đạo (300 DPI): %s\n', outFile);
end

function [speed, angle_deg] = landingVelocity(v0, alpha_deg, g, T)
% LANDINGVELOCITY Vận tốc tại thời điểm chạm đất t = T
%   vx(T) = v0*cos(alpha)            (không đổi theo thời gian)
%   vy(T) = v0*sin(alpha) - g*T      (âm: vật đang đi xuống)
%   speed     : Độ lớn vận tốc (m/s)
%   angle_deg : Góc của vectơ vận tốc so với trục Ox (độ), âm khi hướng xuống
    alpha_rad = deg2rad(alpha_deg);
    vx = v0 * cos(alpha_rad);
    vy = v0 * sin(alpha_rad) - g * T;
    speed = sqrt(vx^2 + vy^2);
    angle_deg = rad2deg(atan2(vy, vx));
end
