function [a2_deg, R] = chaythudoclap_solveAngleSymbolic(a1_deg, v0)
  
   if nargin == 0
       clc;
       disp('--- Vi du 1: Binh thuong (a1 = 30, v0 = 20) ---');
       [a2, R1] = chaythudoclap_solveAngleSymbolic(30, 20);
       fprintf('a2 = %.2f do, R = %.2f m\n\n', a2, R1);
       disp('--- Vi du 2: Dac biet (a1 = 45, v0 = 20) ---');
       [a2, R1] = chaythudoclap_solveAngleSymbolic(45, 20);
       fprintf('a2 = %.2f do, R = %.2f m\n', a2, R1);
       disp('a2 = a1: hai quy dao trung nhau, tam xa lon nhat.');
       return;
   end
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
   else
       a2_deg = other(1);
   end
   R = v0^2 * sin(2*deg2rad(a1_deg)) / g;
end
