function [a2_deg, R] = solveAngleSymbolic(a1_deg, v0, g)
% SOLVEANGLESYMBOLIC Tim goc nem thu hai a2 co cung tam xa voi goc a1
%   Giai phuong trinh sin(2*a2) = sin(2*a1) bang Symbolic Math Toolbox,
%   sau do loc nghiem trong mien vat ly 0 < a2 < 90 do.
%
%   Cach goi:
%       solveAngleSymbolic                        % hoi a1, v0 tu ban phim
%       [a2_deg, R] = solveAngleSymbolic(a1_deg, v0)      % g = 9.81 m/s^2
%       [a2_deg, R] = solveAngleSymbolic(a1_deg, v0, g)
%   Dau vao:
%       a1_deg : Goc nem thu nhat (do), 0 < a1_deg < 90
%       v0     : Van toc ban dau (m/s), v0 > 0
%       g      : Gia toc trong truong (m/s^2), g > 0 (mac dinh 9.81)
%   Dau ra:
%       a2_deg : Goc nem thu hai (do). Neu a1 = 45 do thi a2 = a1.
%       R      : Tam xa chung cua hai vat (m)
  interactive = (nargin == 0);
  if interactive
      a1_deg = input('Nhap goc nem a1 (do): ');
      v0 = input('Nhap van toc dau v0 (m/s): ');
  elseif nargin == 1
      error('Can truyen ca a1 (do) va v0 (m/s).');
  end
  if nargin < 3
      g = 9.81;
  end
  if ~isnumeric(a1_deg) || ~isscalar(a1_deg)
      error('a1 phai la mot so (do).');
  end
  if a1_deg <= 0 || a1_deg >= 90
      error('a1 phai trong khoang (0, 90) do.');
  end
  if ~isnumeric(v0) || ~isscalar(v0) || v0 <= 0
      error('v0 phai la so duong.');
  end
  if ~isnumeric(g) || ~isscalar(g) || g <= 0
      error('g phai la so duong.');
  end
  syms a2
  a1 = sym(a1_deg) * pi / 180;
  % Buoc 1: giai truc tiep phuong trinh luong giac, loc nghiem trong (0, 90) do
  s = solve(sin(2*a2) == sin(2*a1), a2);
  s_deg = double(s) * 180 / pi;
  s_deg = s_deg(s_deg > 0 & s_deg < 90);
  other = s_deg(abs(s_deg - a1_deg) > 1e-6);
  % Buoc 2: solve chi tra ve mot so nghiem chinh nen co the thieu nghiem thu
  % hai. Khi do dung hai ho nghiem tong quat cua sin(X) = sin(Y):
  %     X = Y + 2*k*pi   hoac   X = pi - Y + 2*k*pi   (k nguyen)
  % voi X = 2*a2, Y = 2*a1, roi quet k de lay nghiem trong (0, 90) do.
  if isempty(other) && abs(a1_deg - 45) > 1e-6
      syms k integer
      fam = [solve(2*a2 == 2*a1 + 2*k*pi, a2); ...
             solve(2*a2 == pi - 2*a1 + 2*k*pi, a2)];
      s_deg = [];
      for kk = -1:1
          s_deg = [s_deg; double(subs(fam, k, kk)) * 180 / pi];
      end
      s_deg = s_deg(s_deg > 0 & s_deg < 90);
      other = s_deg(abs(s_deg - a1_deg) > 1e-6);
  end
  if isempty(other)
      % Chi hop le khi a1 = 45 do (hai nghiem trung nhau)
      if abs(a1_deg - 45) > 1e-6
          error('solveAngleSymbolic:NoSecondRoot', ...
              'Khong tim duoc nghiem thu hai trong khoang (0, 90) do.');
      end
      a2_deg = a1_deg;
      if interactive
          disp('a1 = 45 do: a2 = a1, hai quy dao trung nhau.');
      end
  else
      a2_deg = other(1);
  end
  R = v0^2 * sin(2*deg2rad(a1_deg)) / g;
  if interactive
      fprintf('Goc nem a2 = %.2f do\n', a2_deg);
      fprintf('Tam xa R = %.2f m\n', R);
      if nargout == 0
          clear a2_deg R   % tranh in them "ans = ..." khi goi khong co dau ;
      end
  end
end
