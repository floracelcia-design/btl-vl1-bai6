classdef VL1_1 < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './VL1_1.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        EditField                       matlab.ui.control.NumericEditField
        EditFieldLabel                  matlab.ui.control.Label
        vquoButton                      matlab.ui.control.Button
        gcnm1Slider                     matlab.ui.control.Slider
        gcnm1SliderLabel                matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            % Thêm thư mục src/ vào path để gọi solveAngleSymbolic, calculateProjectile
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));
        end

        % Callback function
        function vquoButton_2Pushed(app, event)
            
        end

        % Value changed function: gcnm1Slider
        function gcnm1SliderValueChanged(app, event)
            value = app.gcnm1Slider.Value; 
            app.gcnm1SliderLabel.Text = "Góc ném α₁ = " + string(value) + "°";
        end

        % Value changing function: gcnm1Slider
        function gcnm1SliderValueChanging(app, event)
            changingValue = event.Value;
            app.gcnm1SliderLabel.Text = "Góc ném α₁ = " + string(changingValue) + "°";
        end

        % Button pushed function: vquoButton
        function vquoButtonPushed(app, event)
% Lấy thông số đầu vào
alpha = app.gcnm1Slider.Value;
v0 = app.EditField.Value;
g = 9.81;

if ~isfinite(v0) || v0 <= 0 || ...
        ~isfinite(alpha) || alpha <= 0 || alpha >= 90
    uialert(app.UIFigure, ...
        'Nhập v0 > 0 và chọn 0 < góc ném < 90 độ.', ...
        'Dữ liệu chưa hợp lệ');
    return
end

% Tìm alpha2 bằng symbolic (src/solveAngleSymbolic.m).
% Khi alpha1 = 45 độ hàm trả về alpha2 = alpha1: hai quỹ đạo trùng nhau.
try
    [alpha2, ~] = solveAngleSymbolic(alpha, v0, g);
catch ME
    uialert(app.UIFigure, ...
        sprintf('Không tính được alpha2 bằng symbolic.\n%s', ME.message), ...
        'Lỗi Symbolic Math Toolbox');
    return
end

% Tính các thông số chuyển động (src/calculateProjectile.m)
[T,  H,  R]  = calculateProjectile(v0, alpha,  g);
[T2, H2, R2] = calculateProjectile(v0, alpha2, g); 

% Điểm rơi chung

trungNhau = abs(alpha - alpha2) < 1e-6;

% Hai vật ném cùng lúc, dùng chung đồng hồ
N = 120;
t = linspace(0, max(T, T2), N);

% Vật chạm đất trước thì dừng tại điểm rơi
t1 = min(t, T);
t2 = min(t, T2);

x1 = v0*cosd(alpha)*t1;
y1 = v0*sind(alpha)*t1 - 0.5*g*t1.^2;
x2 = v0*cosd(alpha2)*t2;
y2 = v0*sind(alpha2)*t2 - 0.5*g*t2.^2;

y1(t >= T) = 0;
y2(t >= T2) = 0;

% Tạo hai quỹ đạo, đường mốc đỉnh và hai chất điểm
ax = app.UIAxes;
cla(ax);
hold(ax, 'on');

trail1 = animatedline(ax, ...
    'Color', [0.22 0.74 0.97], 'LineWidth', 2);
trail2 = animatedline(ax, ...
    'Color', [1 0.40 0.15], 'LineStyle', '--', 'LineWidth', 2);



particle1 = plot(ax, 0, 0, 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0.22 0.74 0.97], ...
    'MarkerEdgeColor', [0.22 0.74 0.97]);
particle2 = plot(ax, 0, 0, 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [1 0.40 0.15], ...
    'MarkerEdgeColor', [1 0.40 0.15]);

grid(ax, 'on');
axis(ax, 'normal');
xlim(ax, [0 1.05*max(R, R2)]);
ylim(ax, [0 1.15*max(H, H2)]);
ax.XTickMode = 'auto';
ax.YTickMode = 'auto';
ax.XTickLabelMode = 'auto';
ax.YTickLabelMode = 'auto';


title(ax, sprintf('Đồ thị quỹ đạo | góc %.1f độ và %.1f độ', alpha, alpha2));
subtitle(ax, sprintf( ...
    'H1 = %.2f m | H2 = %.2f m | T1 = %.2f s | T2 = %.2f s | R = %.2f m', ...
    H, H2, T, T2, R));

if trungNhau
    text(ax, 0.5, 0.96, ...
        'alpha1 = alpha2 = 45 độ: hai quỹ đạo trùng nhau', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'Color', 'w', ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.15 0.15 0.15], ...
        'Margin', 4);
end



button = app.vquoButton;
button.Enable = 'off';

% Đánh dấu đỉnh của từng vật một lần
tPeak1 = T/2;
tPeak2 = T2/2;
xPeak1 = v0*cosd(alpha)*tPeak1;
xPeak2 = v0*cosd(alpha2)*tPeak2;
peakDrawn1 = false;
peakDrawn2 = false;
Rdrawn = false;
legend(ax, [trail1 trail2], ...
    {sprintf('Quỹ đạo vật 1'), ...
    sprintf('Quỹ đạo vật 2')}, ...
    'Location', 'northeast', 'AutoUpdate', 'on');
for k = 1:N
    addpoints(trail1, x1(k), y1(k));
    particle1.XData = x1(k);
    particle1.YData = y1(k);

    addpoints(trail2, x2(k), y2(k));
    particle2.XData = x2(k);
    particle2.YData = y2(k);

    % Đánh dấu đỉnh vật 1
    if ~peakDrawn1 && t(k) >= tPeak1
        hold(ax, 'on');
        plot(ax, xPeak1, H, 'o', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'none', ...
            'Color', [0.22 0.74 0.97], ...
            'LineWidth', 2, 'Tag', 'Peak1', ...
            'DisplayName', sprintf('Vật 1 đạt Hmax %.2f s', tPeak1));
        text(ax, xPeak1, H + 0.03*diff(ax.YLim), ...
            sprintf('t1 = %.2f s', tPeak1), ...
            'Color', [0.22 0.74 0.97], 'FontSize', 12, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'Tag', 'PeakTime1');
        % hold(ax, 'off');
        peakDrawn1 = true;
    end

    % Đánh dấu đỉnh vật 2
    if ~peakDrawn2 && t(k) >= tPeak2
        hold(ax, 'on');
        plot(ax, xPeak2, H2, 'o', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'none', ...
            'Color', [1 0.40 0.15], ...
            'LineWidth', 2, 'Tag', 'Peak2', ...
            'DisplayName', sprintf('Vật 2 đạt Hmax %.2f s', tPeak2));
        text(ax, xPeak2, H2 - 0.03*diff(ax.YLim), ...
            sprintf('t2 = %.2f s', tPeak2), ...
            'Color', [1 0.40 0.15], 'FontSize', 12, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', 'Tag', 'PeakTime2');
        % hold(ax, 'off');
        peakDrawn2 = true;
    end
    if ~Rdrawn && t(k) == max(T,T2)
        hold(ax,"on");
        % Đánh dấu điểm rơi (R, 0)
        plot(ax, R, 0, 'd', ...
            'MarkerSize', 9, ...
            'MarkerFaceColor', [1 0.75 0.2], ...
            'MarkerEdgeColor', [1 0.75 0.2], ...
            'Tag', 'LandingPoint', ...
            'DisplayName', sprintf('Tầm xa cực đại %.2f m', R));
        text(ax, R, 0.02*max(H, H2), ...
            sprintf('(R, 0), R = %.2f m', R), ...
            'Color', [1 0.75 0.2], ...
            'FontSize', 10, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom');
        Rdrawn = true;
    end
    drawnow;
end


if isgraphics(button)
    button.Enable = 'on';
end

% Tự động lưu đúng đồ thị đang hiện trong app (UIAxes) vào figures/, 300 DPI
try
    figDir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    outFile = fullfile(figDir, sprintf('app_v0_%g_alpha1_%g.png', v0, alpha));
    exportgraphics(app.UIAxes, outFile, 'Resolution', 300);
catch ME
    if isgraphics(app.UIFigure)
        uialert(app.UIFigure, ...
            sprintf('Không lưu được ảnh.\n%s', ME.message), 'Lỗi lưu ảnh');
    end
end

        
        end

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event)
      
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = VL1_1(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end