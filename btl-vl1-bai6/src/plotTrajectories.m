function fig = plotTrajectories(v0, alpha1_deg, alpha2_deg, g, outFile)
% PLOTTRAJECTORIES Vẽ quỹ đạo của hai vật ném xiên trên cùng một hệ trục tọa độ
%   fig = plotTrajectories(v0, alpha1_deg, alpha2_deg, g)
%   fig = plotTrajectories(v0, alpha1_deg, alpha2_deg, g, outFile)
%
%   Đầu vào:
%       v0         : Vận tốc ban đầu chung của hai vật (m/s)
%       alpha1_deg : Góc ném của vật 1 (độ)
%       alpha2_deg : Góc ném của vật 2 (độ)
%       g          : Gia tốc trọng trường (m/s^2)
%       outFile    : (Tùy chọn) Đường dẫn file PNG để lưu hình ở 300 DPI
%   Đầu ra:
%       fig        : Handle của figure đã vẽ
%
%   Hai trục dùng cùng một tỉ lệ (axis equal) để hình dạng quỹ đạo không bị méo.

    if nargin < 5
        outFile = '';
    end

    % 1. Tính quỹ đạo và thông số đặc trưng của từng vật
    [T1, H1, R1, x1, y1] = calculateProjectile(v0, alpha1_deg, g);
    [T2, H2, R2, x2, y2] = calculateProjectile(v0, alpha2_deg, g);
    sameAngle = abs(alpha1_deg - alpha2_deg) < 1e-6;   % trường hợp alpha1 = 45 độ

    color1 = [0.00 0.45 0.74];   % xanh dương
    color2 = [0.85 0.33 0.10];   % cam đỏ

    % 2. Vẽ hai quỹ đạo
    fig = figure('Color', 'w', 'Name', 'Quy dao nem xien', ...
        'Units', 'pixels', 'Position', [100 100 900 520]);
    ax = axes('Parent', fig);
    hold(ax, 'on');
    h1 = plot(ax, x1, y1, '-', 'Color', color1, 'LineWidth', 2);
    h2 = plot(ax, x2, y2, '--', 'Color', color2, 'LineWidth', 2);

    % 3. Đánh dấu các điểm đặc trưng
    %    Đỉnh quỹ đạo: x = R/2 (quỹ đạo đối xứng qua đỉnh), y = H
    plot(ax, R1/2, H1, 'o', 'Color', color1, 'MarkerFaceColor', color1, 'MarkerSize', 7);
    plot(ax, R2/2, H2, 's', 'Color', color2, 'MarkerFaceColor', color2, 'MarkerSize', 7);
    hThrow = plot(ax, 0, 0, '^', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
    hLand = plot(ax, [R1 R2], [0 0], 'v', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

    % 4. Trục tọa độ: cùng tỉ lệ, có tên và đơn vị
    Hmax = max(H1, H2);
    grid(ax, 'on');
    box(ax, 'on');
    axis(ax, 'equal');
    xlim(ax, [0, 1.05 * max(R1, R2)]);
    ylim(ax, [0, 1.20 * Hmax]);
    xlabel(ax, 'Tầm xa x (m)');
    ylabel(ax, 'Độ cao y (m)');
    title(ax, {'Quỹ đạo ném xiên', ...
        sprintf('v_0 = %.2f m/s, g = %.2f m/s^2, R = %.2f m', v0, g, R1)});

    % 5. Ghi chú độ cao cực đại tại đỉnh mỗi quỹ đạo
    dy = 0.03 * Hmax;
    if sameAngle
        text(R1/2, H1 + dy, sprintf('H_1 = H_2 = %.2f m', H1), 'Parent', ax, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    else
        text(R1/2, H1 + dy, sprintf('H_1 = %.2f m', H1), 'Parent', ax, ...
            'Color', color1, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        text(R2/2, H2 + dy, sprintf('H_2 = %.2f m', H2), 'Parent', ax, ...
            'Color', color2, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end

    % 6. Chú giải: góc ném và thời gian bay của từng vật
    %    (đặt ngoài vùng vẽ để không che quỹ đạo)
    legend(ax, [h1, h2, hThrow, hLand], { ...
        sprintf('Vật 1: \\alpha_1 = %.2f°, T_1 = %.2f s', alpha1_deg, T1), ...
        sprintf('Vật 2: \\alpha_2 = %.2f°, T_2 = %.2f s', alpha2_deg, T2), ...
        'Vị trí ném', 'Vị trí rơi'}, 'Location', 'eastoutside');
    hold(ax, 'off');

    % 7. Lưu hình 300 DPI (nếu có yêu cầu)
    if ~isempty(outFile)
        try
            exportgraphics(fig, outFile, 'Resolution', 300);   % MATLAB R2020a trở lên
        catch
            print(fig, outFile, '-dpng', '-r300');             % phiên bản cũ hơn
        end
    end
end
