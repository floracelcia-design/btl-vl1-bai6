function main()
% MAIN Chương trình chính - Bài 6: Quỹ đạo ném xiên và góc ném cùng tầm xa
%   Trình tự:
%       1. Nhập v0, alpha1, g                              (inputParameters)
%       2. Lập phương trình và giải R(alpha1) = R(alpha2)  (solveAngleSymbolic)
%       3. Xuất kết quả Symbolic: R(alpha), họ nghiệm tổng quát, nghiệm vật lý
%       4. Tính T, H, R của từng vật bằng công thức số     (calculateProjectile)
%       5. Tính vận tốc lúc chạm đất
%       6. Kiểm chứng: |R1 - R2| và |R_symbolic - R1|
%       7. Vẽ hai quỹ đạo, lưu hình 300 DPI                (plotTrajectories)
%
%   Cách chạy: chuyển thư mục hiện hành vào src/ rồi gõ  main

    tol = 1e-6;   % Sai số cho phép của |R1 - R2| (m)

    % 1. Nhập dữ liệu
    [v0, alpha1_deg, ~, g] = inputParameters();

    % 2. Giải phương trình tìm góc ném thứ hai bằng Symbolic Math Toolbox
    [alpha2_deg, Rsym, info] = solveAngleSymbolic(alpha1_deg, v0, g);

    % 3. Xuất kết quả Symbolic
    fprintf('==========================================================\n');
    fprintf('   KẾT QUẢ SYMBOLIC\n');
    fprintf('==========================================================\n');
    fprintf('Phương trình chuyển động:\n');
    fprintf('    x(t) = %s\n', char(info.x));
    fprintf('    y(t) = %s\n', char(info.y));
    fprintf('Thời gian bay  : T(alpha) = %s\n', char(info.T));
    fprintf('Tầm xa         : R(alpha) = %s\n', char(info.R));
    fprintf('Điều kiện      : %s\n', char(info.equation));
    fprintf('Họ nghiệm tổng quát của alpha2 (rad):\n');
    for i = 1:numel(info.families)
        fprintf('    alpha2 = %s\n', char(info.families(i)));
    end
    if ~isempty(info.parameters)
        fprintf('    với điều kiện: %s\n', char(info.conditions(1)));
    end
    fprintf('Nghiệm trong (0, 90) độ ứng với alpha1 = %g độ: %s\n', ...
        alpha1_deg, sprintf('%.4f  ', info.roots_deg));
    if info.isDoubleRoot
        fprintf(['=> alpha1 = 45 độ: hai họ nghiệm cho cùng một giá trị (nghiệm kép),\n' ...
                 '   không có góc ném thứ hai phân biệt; tầm xa đạt cực đại v0^2/g.\n']);
    else
        fprintf('=> Góc ném thứ hai: alpha2 = %.4f độ\n', alpha2_deg);
    end

    % 4. Thông số đặc trưng của hai vật (tính số độc lập với phần Symbolic)
    [T1, H1, R1] = calculateProjectile(v0, alpha1_deg, g);
    [T2, H2, R2] = calculateProjectile(v0, alpha2_deg, g);

    % 5. Vận tốc tại thời điểm chạm đất
    [vLand1, beta1] = landingVelocity(v0, alpha1_deg, g, T1);
    [vLand2, beta2] = landingVelocity(v0, alpha2_deg, g, T2);

    % Bảng kết quả số
    fprintf('==========================================================\n');
    fprintf('   KẾT QUẢ SỐ\n');
    fprintf('==========================================================\n');
    fprintf('Dữ liệu đầu vào : v0 = %.2f m/s | alpha1 = %.2f độ | g = %.2f m/s^2\n', ...
        v0, alpha1_deg, g);
    fprintf('----------------------------------------------------------\n');
    fprintf('%-32s %12s %12s\n', 'Thông số', 'Vật 1', 'Vật 2');
    fprintf('%-32s %12.4f %12.4f\n', 'Góc ném (độ)', alpha1_deg, alpha2_deg);
    fprintf('%-32s %12.4f %12.4f\n', 'Thời gian bay T (s)', T1, T2);
    fprintf('%-32s %12.4f %12.4f\n', 'Độ cao cực đại H (m)', H1, H2);
    fprintf('%-32s %12.4f %12.4f\n', 'Tầm xa R (m)', R1, R2);
    fprintf('%-32s %12.4f %12.4f\n', 'Tốc độ chạm đất (m/s)', vLand1, vLand2);
    fprintf('%-32s %12.4f %12.4f\n', 'Góc vận tốc chạm đất (độ)', beta1, beta2);
    fprintf('----------------------------------------------------------\n');

    % 6. Kiểm chứng
    %    (a) hai vật phải có cùng tầm xa trong giới hạn sai số
    %    (b) tầm xa từ biểu thức Symbolic phải khớp công thức số của calculateProjectile
    dR = abs(R1 - R2);
    dRsym = abs(Rsym - R1);
    fprintf('Kiểm chứng (a)  : |R1 - R2| = %.3e m (cho phép %.0e m) -> %s\n', ...
        dR, tol, verdictText(dR <= tol));
    fprintf('Kiểm chứng (b)  : |R_symbolic - R1| = %.3e m -> %s\n', ...
        dRsym, verdictText(dRsym <= tol));
    fprintf('==========================================================\n');

    % 7. Vẽ quỹ đạo và lưu hình vào thư mục figures/ ở gốc repo
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
%   speed     : Độ lớn vận tốc (m/s); theo bảo toàn cơ năng phải bằng v0
%   angle_deg : Góc của vectơ vận tốc so với trục Ox (độ), âm khi hướng xuống
    alpha_rad = deg2rad(alpha_deg);
    vx = v0 * cos(alpha_rad);
    vy = v0 * sin(alpha_rad) - g * T;
    speed = sqrt(vx^2 + vy^2);
    angle_deg = rad2deg(atan2(vy, vx));
end

function s = verdictText(passed)
    if passed
        s = 'ĐẠT';
    else
        s = 'KHÔNG ĐẠT';
    end
end
