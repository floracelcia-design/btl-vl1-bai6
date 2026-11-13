function solveAngleSymbolic()
  a1_deg = input('Nhap goc nem a1 (do): ');
  v0 = input('Nhap van toc dau v0 (m/s): ');
  g = 9.81;
  if ~isnumeric(a1_deg) || ~isscalar(a1_deg)
      error('a1 phai la mot so (do).');
  end
  if a1_deg <= 0 || a1_deg >= 90
      error('a1 phai trong khoang (0, 90) do.');
  end
  if ~isnumeric(v0) || ~isscalar(v0) || v0 <= 0
      error('v0 phai la so duong.');
  end
  syms a2
  a1 = sym(a1_deg) * pi / 180;
  s = solve(sin(2*a2) == sin(2*a1), a2);
  s_deg = double(rad2deg(s));
  s_deg = s_deg(s_deg > 0 & s_deg < 90);
  other = s_deg(abs(s_deg - a1_deg) > 1e-6);
  if isempty(other)
      a2_deg = a1_deg;
      disp('a1 = 45 do: a2 = a1, hai quy dao trung nhau.');
  else
      a2_deg = other(1);
  end
  R = v0^2 * sin(2*deg2rad(a1_deg)) / g;
  fprintf('Goc nem a2 = %.2f do\n', a2_deg);
  fprintf('Tam xa R = %.2f m\n', R);
end
