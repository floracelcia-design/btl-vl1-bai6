function [alpha2_deg, R] = chaythudoclap_solveAngleSymbolic(alpha1_deg, v0, g)
% CHAYTHUDOCLAP_SOLVEANGLESYMBOLIC Chạy thử độc lập hàm solveAngleSymbolic
%   chaythudoclap_solveAngleSymbolic                       % chạy bộ ví dụ mẫu, in bảng
%   [alpha2_deg, R] = chaythudoclap_solveAngleSymbolic(alpha1_deg, v0)       % g = 9.81
%   [alpha2_deg, R] = chaythudoclap_solveAngleSymbolic(alpha1_deg, v0, g)
%
%   Phần giải phương trình nằm hoàn toàn trong solveAngleSymbolic.m. File này chỉ
%   gọi lại hàm đó để kiểm tra nhanh, không cần nhập dữ liệu từ bàn phím.

    if nargin == 0
        g = 9.81;
        % Mỗi dòng: [alpha1 (độ), v0 (m/s)]
        cases = [30 20; 45 20; 60 20; 75 30; 37.5 15; 1 20];

        clc;
        [~, ~, info] = solveAngleSymbolic(cases(1, 1), cases(1, 2), g);
        fprintf('Tầm xa ký hiệu       : R(alpha) = %s\n', char(info.R));
        fprintf('Điều kiện cùng tầm xa: %s\n', char(info.equation));
        fprintf('Họ nghiệm tổng quát  :\n');
        for i = 1:numel(info.families)
            fprintf('    alpha2 = %s\n', char(info.families(i)));
        end
        fprintf('\n%8s %8s %10s %12s %12s   %s\n', ...
            'a1 (độ)', 'v0', 'a2 (độ)', 'R (m)', '|R1 - R2|', 'Ghi chú');
        for i = 1:size(cases, 1)
            a1 = cases(i, 1);
            v = cases(i, 2);
            [a2, Rc, info] = solveAngleSymbolic(a1, v, g);
            R2 = v^2 * sind(2*a2) / g;            % kiểm chứng số độc lập
            if info.isDoubleRoot
                note = 'nghiệm kép: hai quỹ đạo trùng nhau, R = Rmax';
            else
                note = 'a1 + a2 = 90 độ';
            end
            fprintf('%8.2f %8.2f %10.4f %12.4f %12.2e   %s\n', a1, v, a2, Rc, abs(Rc - R2), note);
        end
        return;
    end

    if nargin < 3
        g = 9.81;
    end
    [alpha2_deg, R] = solveAngleSymbolic(alpha1_deg, v0, g);
end
