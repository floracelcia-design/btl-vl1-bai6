classdef VL1 < matlab.apps.App
   % Used to locate and load the app's XML configuration file
   properties (Access = public, Constant)
       AppConfigFilename = './VL1.xml'; % File path to the app configuration file containing component layout and settings
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
       end
       % Callback function
       function vquoButton_2Pushed(app, event)
          
       end
       % Value changed function: gcnm1Slider
       function gcnm1SliderValueChanged(app, event)
           value = app.gcnm1Slider.Value; %lấy dữ
           app.gcnm1SliderLabel.Text = "Góc ném α₁ = " + string(value) + "°";
       end
       % Value changing function: gcnm1Slider
       function gcnm1SliderValueChanging(app, event)
           changingValue = event.Value;
           app.gcnm1SliderLabel.Text = "Góc ném α₁ = " + string(changingValue) + "°";
       end
       % Button pushed function: vquoButton
       function vquoButtonPushed(app, event)
% Lay thong so dau vao
alpha = app.gcnm1Slider.Value;
v0 = app.EditField.Value;
g = 9.81;
if ~isfinite(v0) || v0 <= 0 || ...
       ~isfinite(alpha) || alpha <= 0 || alpha >= 90
   uialert(app.UIFigure, ...
       'Nhập v0 > 0 và chọn 0 < góc ném < 90°.', ...
       'Dữ liệu chưa hợp lệ');
   return
end
alpha2 = 90 - alpha;
% Thoi gian bay, tam xa va do cao cua moi vat
T = 2*v0*sind(alpha)/g;
R = v0*cosd(alpha)*T;
H = (v0*sind(alpha))^2/(2*g);
T2 = 2*v0*sind(alpha2)/g;
R2 = v0*cosd(alpha2)*T2;
H2 = (v0*sind(alpha2))^2/(2*g);
% Hai vat duoc nem cung luc, dung chung dong ho
N = 240;
t = linspace(0, max(T, T2), N);
% Vat nao cham dat truoc thi dung tai diem cham dat
t1 = min(t, T);
t2 = min(t, T2);
x1 = v0*cosd(alpha)*t1;
y1 = v0*sind(alpha)*t1 - 0.5*g*t1.^2;
x2 = v0*cosd(alpha2)*t2;
y2 = v0*sind(alpha2)*t2 - 0.5*g*t2.^2;
y1(t >= T) = 0;
y2(t >= T2) = 0;
% Tao hai duong quy dao va hai chat diem rieng
ax = app.UIAxes;
cla(ax);
hold(ax, 'on');
trail1 = animatedline(ax, ...
   'Color', [0.22 0.74 0.97], 'LineWidth', 2);
trail2 = animatedline(ax, ...
   'Color', [1 0.40 0.15], 'LineStyle', '--', 'LineWidth', 2);
trail3 = animatedline(ax, ...
   'Color', [1 1 1], 'LineStyle', '--', 'LineWidth', 2);
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
xlabel(ax, 'Khoảng cách ngang x (m)');
ylabel(ax, 'Độ cao y (m)');
legend(ax, [trail1 trail2], ...
   {sprintf('Vật 1: %.1f°', alpha), ...
    sprintf('Vật 2: %.1f°', alpha2)}, 'Location', 'best');
button = app.vquoButton;
button.Enable = 'off'; %ngăn bấm chạy thêm lần nữa khi animation đang chạy
% Moi vat chi danh dau dinh mot lan trong moi lan chay
tPeak1 = T/2;
tPeak2 = T2/2;
xPeak1 = v0*cosd(alpha)*tPeak1;
xPeak2 = v0*cosd(alpha2)*tPeak2;
peakDrawn1 = false;
peakDrawn2 = false;
xLabelDrawn = false;
legend(ax, 'AutoUpdate', 'off');
split = linspace(0, max(H, H2), N);
for k = 1:N
 
   addpoints(trail1, x1(k), y1(k));
   particle1.XData = x1(k);
   particle1.YData = y1(k);
   addpoints(trail2, x2(k), y2(k));
   particle2.XData = x2(k);
   particle2.YData = y2(k);
   % Danh dau dinh vat 1
   if ~peakDrawn1 && t(k) >= tPeak1
       hold(ax, 'on');
       plot(ax, xPeak1, H, 'o', 'MarkerSize', 10, ...
           'MarkerFaceColor', 'none', ...
           'Color', [0.22 0.74 0.97], ...
           'LineWidth', 2, 'Tag', 'Peak1');
       text(ax, xPeak1, H + 0.03*diff(ax.YLim), ...
           sprintf('t₁ = %.2f s', tPeak1), ...
           'Color', [0.22 0.74 0.97], 'FontSize', 12, ...
           'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'bottom', 'Tag', 'PeakTime1');
      
       hold(ax, 'off');
       peakDrawn1 = true;
   end
   % Danh dau dinh vat 2
   if ~peakDrawn2 && t(k) >= tPeak2
       hold(ax, 'on');
      
       plot(ax, xPeak2, H2, 'o', 'MarkerSize', 10, ...
           'MarkerFaceColor', 'none', ...
           'Color', [1 0.40 0.15], ...
           'LineWidth', 2, 'Tag', 'Peak2');
       text(ax, xPeak2, H2 - 0.03*diff(ax.YLim), ...
           sprintf('t₂ = %.2f s', tPeak2), ...
           'Color', [1 0.40 0.15], 'FontSize', 12, ...
           'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'top', 'Tag', 'PeakTime2');
       hold(ax, 'off');
       peakDrawn2 = true;
      
   end
   if peakDrawn1 && peakDrawn2 && ~xLabelDrawn
       hold(ax, 'on');
      
      
   end
   title(ax, sprintf('Góc %.1f° và %.1f° | t = %.2f s', ...
       alpha, alpha2, t(k)));
   addpoints(trail3, xPeak1, split(k));
   drawnow;
end
if isgraphics(button)
   button.Enable = 'on';
end
       end
       % Button down function: UIAxes
       function UIAxesButtonDown(app, event)
    
       end
   end
   % App creation
   methods (Access = public)
       % Construct app
       function app = VL1(varargin)
           app = app@matlab.apps.App(varargin{:});
           if nargout == 0
               clear app
           end
       end
   end
end
