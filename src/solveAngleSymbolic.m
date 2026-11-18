function [alpha2_deg, R, info] = solveAngleSymbolic(alpha1_deg, v0, g)
% SOLVEANGLESYMBOLIC Tìm góc ném alpha2 cho cùng tầm xa với góc alpha1 (Symbolic Math Toolbox)
%
%   [alpha2_deg, R]       = solveAngleSymbolic(alpha1_deg, v0)      % g = 9.81 m/s^2
%   [alpha2_deg, R, info] = solveAngleSymbolic(alpha1_deg, v0, g)
%
%   Đầu vào:
%       alpha1_deg : Góc ném của vật 1 (độ), 0 < alpha1_deg < 90
%       v0         : Vận tốc ban đầu chung của hai vật (m/s), v0 > 0
%       g          : Gia tốc trọng trường (m/s^2), g > 0, mặc định 9.81
%   Đầu ra:
%       alpha2_deg : Góc ném của vật 2 (độ). Khi alpha1 = 45 độ, phương trình có
%                    nghiệm kép nên alpha2 = alpha1 (info.isDoubleRoot = true).
%       R          : Tầm xa chung của hai vật (m), có được bằng cách thay số vào
%                    biểu thức ký hiệu R(alpha) tìm ở bước B3.
%       info       : struct chứa kết quả ký hiệu để xuất ra màn hình và đưa vào báo cáo
%                    .x, .y         phương trình chuyển động x(t), y(t)
%                    .T, .R         thời gian bay T(alpha) và tầm xa R(alpha)
%                    .equation      phương trình R(alpha1) = R(alpha2)
%                    .families      các họ nghiệm tổng quát alpha2(alpha1, k)
%                    .parameters    tham số của họ nghiệm (k)
%                    .conditions    điều kiện của tham số (k nguyên)
%                    .roots_deg     mọi nghiệm thuộc (0, 90) độ ứng với alpha1 đã cho
%                    .isDoubleRoot  true khi hai nghiệm trùng nhau (alpha1 = 45 độ)
%
%   Các bước tính (mục 3.2 của báo cáo):
%       B1. Khai báo biến ký hiệu.
%       B2. Lập phương trình chuyển động x(t), y(t).
%       B3. Giải y(t) = 0, bỏ nghiệm t = 0 -> thời gian bay T; tầm xa R = x(T).
%       B4. Lập điều kiện cùng tầm xa R(alpha1) = R(alpha2).
%       B5. Giải bằng solve(..., 'ReturnConditions', true) để có ĐỦ các họ nghiệm.
%       B6. Thay alpha1 (dạng chính xác), duyệt k, giữ nghiệm 0 < alpha2 < 90 độ.
%       B7. Loại nghiệm trùng alpha1 -> alpha2; xử lý nghiệm kép alpha1 = 45 độ.
%       B8. Thay v0, g vào R(alpha) để được tầm xa chung.
%   Bước kiểm chứng số |R1 - R2| nằm trong main.m và runTests.m.

    % ----- Kiểm tra dữ liệu đầu vào -----
    if nargin < 2
        error('solveAngleSymbolic:NotEnoughInputs', ...
            'Cần truyền alpha1_deg (độ) và v0 (m/s). Chạy main để nhập dữ liệu từ bàn phím.');
    end
    if nargin < 3 || isempty(g)
        g = 9.81;
    end
    if ~isFiniteRealScalar(alpha1_deg) || alpha1_deg <= 0 || alpha1_deg >= 90
        error('solveAngleSymbolic:InvalidAngle', ...
            'alpha1 phải là một số thực trong khoảng (0, 90) độ.');
    end
    if ~isFiniteRealScalar(v0) || v0 <= 0
        error('solveAngleSymbolic:InvalidSpeed', 'v0 phải là một số thực dương (m/s).');
    end
    if ~isFiniteRealScalar(g) || g <= 0
        error('solveAngleSymbolic:InvalidGravity', 'g phải là một số thực dương (m/s^2).');
    end
    tolDeg = 1e-9;   % ngưỡng so sánh hai góc (độ) sau khi đổi nghiệm chính xác sang số thực

    % ----- B1. Biến ký hiệu -----
    % Dùng sym(...) thay cho syms: tên ký hiệu 'v0', 'g' không đè lên đối số số v0, g
    % của hàm, và MATLAB biết chắc alpha là biến chứ không phải hàm alpha() có sẵn.
    t      = sym('t', 'real');          % thời gian (s)
    alpha  = sym('alpha', 'real');      % góc ném tổng quát (rad)
    alpha1 = sym('alpha1', 'real');     % góc ném vật 1 (rad)
    alpha2 = sym('alpha2', 'real');     % góc ném vật 2 (rad) - ẩn cần tìm
    v0s    = sym('v0', 'positive');     % vận tốc ban đầu (m/s)
    gs     = sym('g', 'positive');      % gia tốc trọng trường (m/s^2)
    % Các giả thiết 'real'/'positive' được lưu chung trong Symbolic engine;
    % xóa chúng khi hàm kết thúc (kể cả khi có lỗi) để không ảnh hưởng nơi khác.
    cleanupObj = onCleanup(@() clearAssumptions([t; alpha; alpha1; alpha2; v0s; gs])); %#ok<NASGU>

    % ----- B2. Phương trình chuyển động (gốc O tại điểm ném, Ox nằm ngang, Oy hướng lên) -----
    x = v0s*cos(alpha)*t;
    y = v0s*sin(alpha)*t - gs*t^2/2;

    % ----- B3. Thời gian bay T và tầm xa R -----
    tRoots = solve(y == 0, t);          % hai nghiệm: t = 0 (lúc ném) và t = T (lúc chạm đất)
    T = sym([]);
    for i = 1:numel(tRoots)
        if ~isequal(tRoots(i), sym(0))  % bỏ nghiệm t = 0
            T = [T; tRoots(i)]; %#ok<AGROW>
        end
    end
    if numel(T) ~= 1
        error('solveAngleSymbolic:FlightTime', 'Không xác định được duy nhất thời gian bay T.');
    end
    Rexpr = combine(subs(x, t, T), 'sincos');   % 2 v0^2 sin(a)cos(a)/g -> v0^2 sin(2a)/g

    % ----- B4. Điều kiện hai vật có cùng tầm xa -----
    equation = subs(Rexpr, alpha, alpha1) == subs(Rexpr, alpha, alpha2);

    % ----- B5. Giải ký hiệu, lấy ĐỦ các họ nghiệm -----
    % Nếu không bật 'ReturnConditions', solve chỉ trả về một vài nghiệm chính của
    % phương trình lượng giác và có thể bỏ sót alpha2 = 90 - alpha1.
    [families, params, conds] = solve(equation, alpha2, 'ReturnConditions', true);
    if isempty(families)
        error('solveAngleSymbolic:NoSolution', 'solve không trả về nghiệm nào.');
    end
    if numel(params) > 1
        error('solveAngleSymbolic:UnexpectedForm', ...
            'solve trả về nhiều hơn một tham số (%s), cần kiểm tra lại.', char(params));
    end
    if isempty(conds)
        conds = sym(true);
    end

    % ----- B6. Thay alpha1 dạng chính xác, chọn k để 0 < alpha2 < 90 độ -----
    alpha1Exact = sym(alpha1_deg) * sym(pi) / 180;   % đổi độ -> rad, không làm tròn
    knownVars = [alpha1; v0s; gs];
    knownVals = [alpha1Exact; sym(v0); sym(g)];
    if isempty(params)
        kRange = 0;          % solve trả về tập nghiệm hữu hạn, không có tham số k
    else
        % Mỗi họ có dạng alpha2 = c + k*pi (Chương 2) còn miền (0, pi/2) chỉ rộng pi/2,
        % nên mỗi họ có tối đa một nghiệm trong miền. Duyệt k = -3..3 là đủ rộng;
        % bước B7 kiểm tra lại tập nghiệm thu được, sai dạng thì báo lỗi.
        kRange = -3:3;
    end
    rootsDeg = zeros(1, 0);
    for i = 1:numel(families)
        cond_i = conds(min(i, numel(conds)));
        for k = kRange
            if isempty(params)
                vars = knownVars;
                vals = knownVals;
            else
                vars = [knownVars; params(:)];
                vals = [knownVals; sym(k)];
            end
            if ~isAlways(subs(cond_i, vars, vals), 'Unknown', 'false')
                continue;                       % giá trị k không thỏa điều kiện của họ nghiệm
            end
            a2Deg = double(subs(families(i), vars, vals)) * 180 / pi;
            if isreal(a2Deg) && a2Deg > 0 && a2Deg < 90
                rootsDeg(end+1) = a2Deg; %#ok<AGROW>
            end
        end
    end

    % ----- B7. Chọn góc ném thứ hai -----
    rootsDeg = uniquetol(rootsDeg, tolDeg, 'DataScale', 1);   % gộp nghiệm trùng giữa hai họ
    isAlpha1 = abs(rootsDeg - alpha1_deg) <= tolDeg;
    if ~any(isAlpha1) || numel(rootsDeg) > 2
        % Theo Chương 2, tập nghiệm trong (0, 90) độ phải là {alpha1, 90 - alpha1}
        error('solveAngleSymbolic:UnexpectedRoots', ...
            'Tập nghiệm trong (0, 90) độ không đúng dạng {alpha1, 90 - alpha1}: %s', ...
            mat2str(rootsDeg, 10));
    end
    others = rootsDeg(~isAlpha1);
    isDoubleRoot = isempty(others);             % chỉ xảy ra khi alpha1 = 45 độ
    % Nghiệm kép <=> F'(alpha2) = 0 tại alpha2 = alpha1, với F = R(alpha1) - R(alpha2).
    % Kiểm tra điều kiện này để không nhầm "solve bỏ sót nghiệm" thành nghiệm kép.
    F  = lhs(equation) - rhs(equation);
    dF = double(subs(diff(F, alpha2), [alpha2; knownVars], [alpha1Exact; knownVals]));
    if isDoubleRoot && abs(dF) > 1e-8 * v0^2 / g
        error('solveAngleSymbolic:MissingRoot', ...
            'Chỉ tìm được alpha2 = alpha1 = %g độ nhưng đây không phải nghiệm kép.', alpha1_deg);
    end
    if isDoubleRoot
        alpha2_deg = alpha1_deg;
    else
        alpha2_deg = others;
    end

    % ----- B8. Tầm xa chung: thay số vào biểu thức ký hiệu R(alpha) -----
    R = double(subs(Rexpr, [alpha; v0s; gs], [alpha1Exact; sym(v0); sym(g)]));

    info = struct('x', x, 'y', y, 'T', T, 'R', Rexpr, 'equation', equation, ...
        'families', families, 'parameters', params, 'conditions', conds, ...
        'roots_deg', rootsDeg, 'isDoubleRoot', isDoubleRoot);
end

function tf = isFiniteRealScalar(value)
% Số thực hữu hạn, một phần tử (loại chuỗi, số phức, mảng, NaN, Inf)
    tf = isnumeric(value) && isscalar(value) && isreal(value) && isfinite(value);
end

function clearAssumptions(vars)
% Xóa giả thiết đã đặt cho các biến ký hiệu
    for i = 1:numel(vars)
        assume(vars(i), 'clear');
    end
end
