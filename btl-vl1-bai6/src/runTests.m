function runTests()
%% 1. UNIT TESTING
%% 2. INTEGRATION TESTING
fprintf('\n====================================\n');
fprintf('       INTEGRATION TESTING\n');
fprintf('====================================\n');
fprintf('       KIEM THU BAI TOAN NEM XIEN\n');
g = 9.81;
tol = 1e-6;
% Du lieu 8 ca kiem thu
v0_test = [20 20 20 15 30 20 -5 20];
alpha1_test = [30 60 45 37.5 75 1 30 90];
alpha2_expected = [60 30 45 52.5 15 89 NaN NaN];
Range_expected = [35.3119 35.3119 40.7747 ...
                 22.1543 45.8716 1.4230 NaN NaN];
n = 8;
%% 2. TAO 8 TRUONG HOP KIEM THU
TestCase = (1:n)';
V0 = v0_test';
Alpha1 = alpha1_test';
Alpha2 = NaN(n,1);
Range1 = NaN(n,1);
Range2 = NaN(n,1);
Error = NaN(n,1);
AngleError = NaN(n,1);
Status = strings(n,1);
%% 3. TINH TOAN VA KIEM THU
for i = 1:n
   if i <= 6
       try
           % Goi ham solveAngleSymbolic
           [Alpha2(i), ~] = solveAngleSymbolic( ...
               Alpha1(i), V0(i), g);
           % Goi ham calculateProjectile
           [~, ~, Range1(i)] = calculateProjectile( ...
               V0(i), Alpha1(i), g);
           [~, ~, Range2(i)] = calculateProjectile( ...
               V0(i), Alpha2(i), g);
           % Tinh sai so tam nem
           Error(i) = abs(Range1(i)-Range2(i));
           % Tinh sai so dieu kien goc
           AngleError(i) = abs( ...
               Alpha1(i)+Alpha2(i)-90);
           % Kiem tra ket qua
           if Error(i) <= tol && ...
                   AngleError(i) <= tol && ...
                   abs(Alpha2(i)-alpha2_expected(i)) <= tol && ...
                   abs(Range1(i)-Range_expected(i)) <= 1e-3
               Status(i) = "PASS";
           else
               Status(i) = "FAIL";
           end
       catch ME
           fprintf('TC%02d - Loi: %s\n',i,ME.message);
           Status(i) = "FAIL";
       end
  
   else
       % TC07 - TC08: Kiem tra du lieu khong hop le
       % Ket qua mong doi: CA HAI ham deu tu choi du lieu (bao loi kiem tra
       % dau vao). Loi he thong cua MATLAB (ma loi 'MATLAB:...', vi du goi
       % sai so tham so) khong duoc tinh la tu choi hop le.
       solveRejected = false;
       calcRejected = false;
       % Kiem tra ham solveAngleSymbolic
       try
           solveAngleSymbolic(Alpha1(i), V0(i), g);
       catch ME
           fprintf('TC%02d - solveAngleSymbolic: %s\n', ...
               i, ME.message);
           solveRejected = ~strncmp(ME.identifier, 'MATLAB:', 7);
       end
       % Kiem tra ham calculateProjectile
       try
           calculateProjectile(V0(i), Alpha1(i), g);
       catch ME
           fprintf('TC%02d - calculateProjectile: %s\n', ...
               i, ME.message);
           calcRejected = ~strncmp(ME.identifier, 'MATLAB:', 7);
       end
       % PASS khi ca hai ham deu bao loi dau vao; nguoc lai la FAIL
       if solveRejected && calcRejected
           Status(i) = "PASS";
       else
           Status(i) = "FAIL";
       end
   end
end
%% 4. XUAT BANG KET QUA
Expected = strings(n,1);
Actual = strings(n,1);
for i = 1:6
   Expected(i) = sprintf('a2=%.4f; R=%.4f', ...
       alpha2_expected(i),Range_expected(i));
   Actual(i) = sprintf('a2=%.4f; R1=%.4f; R2=%.4f', ...
       Alpha2(i),Range1(i),Range2(i));
end
Expected(7) = "Bao loi van toc am";
Actual(7) = "Kiem tra hai ham";
Expected(8) = "Bao loi goc 90 do";
Actual(8) = "Kiem tra hai ham";
TestTable = table(TestCase,V0,Alpha1,Alpha2,...
   Expected,Actual,Range1,Range2,Error,...
   AngleError,Status);
fprintf('\n========== BANG 8 CA KIEM THU ==========\n');
disp(TestTable);
%% 5. BAO CAO PASS / FAIL
passCount = sum(Status == "PASS");
failCount = sum(Status == "FAIL");
fprintf('\n========== BAO CAO PASS/FAIL ==========\n');
fprintf('Tong so ca kiem thu: %d\n',n);
fprintf('So ca PASS: %d\n',passCount);
fprintf('So ca FAIL: %d\n',failCount);
fprintf('Ty le PASS: %.2f%%\n',passCount/n*100);
fprintf('Ty le FAIL: %.2f%%\n',failCount/n*100);
%% 6. PHAN TICH SAI SO
% Chi phan tich cac ca tinh toan PASS
validCases = find(Status(1:6) == "PASS");
fprintf('\n========== PHAN 6: PHAN TICH SAI SO ==========\n');
if ~isempty(validCases)
   RangeError = abs( ...
       Range1(validCases)-Range2(validCases));
   MaxError = max(RangeError);
   MeanError = mean(RangeError);
   fprintf('So ca kiem thu hop le: %d\n', ...
       length(validCases));
   fprintf('Sai so tung ca (m):\n');
   for i = 1:length(validCases)
       fprintf('TC%02d: %.15e m\n', ...
           validCases(i),RangeError(i));
   end
   fprintf('\nSai so lon nhat: %.15e m\n',MaxError);
   fprintf('Sai so trung binh: %.15e m\n',MeanError);
   fprintf('Sai so cho phep: %.15e m\n',tol);
else
   fprintf('Khong co ca PASS de phan tich sai so.\n');
end
%% 7. TIM CAC GOC ALPHA2 CO CUNG TAM NEM
fprintf('\n========== CAC GOC TIM DUOC ==========\n');
for i = 1:6
   if Status(i) == "PASS"
       fprintf('TC%02d: Alpha2 = %.4f do: PASS\n',...
           i,Alpha2(i));
   else
       fprintf('TC%02d: FAIL\n',i);
   end
end
