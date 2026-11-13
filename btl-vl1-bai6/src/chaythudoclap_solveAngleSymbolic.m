function [a2_deg, R] = chaythudoclap_solveAngleSymbolic(a1_deg, v0)
% CHAYTHUDOCLAP_SOLVEANGLESYMBOLIC Chay thu ham solveAngleSymbolic
%   chaythudoclap_solveAngleSymbolic              % chay 2 vi du mau
%   [a2_deg, R] = chaythudoclap_solveAngleSymbolic(a1_deg, v0)
%
%   Phan giai phuong trinh nam trong solveAngleSymbolic.m (g = 9.81 m/s^2).

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
   [a2_deg, R] = solveAngleSymbolic(a1_deg, v0);
end
