
clear;
clc;

FileName_txt = 'H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\02_V_1.txt';                                 % 流速仪文件路径
Struct_Case.DataTable = readtable(FileName_txt, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                                   % 导入流速仪文件
Indice_ReduceError = (Struct_Case.DataTable{:, 15} >= 95) & (Struct_Case.DataTable{:, 16} >= 95) & (Struct_Case.DataTable{:, 17} >= 95);    % 筛选置信度较高的采样点
Struct_Case.DataTableReduceError = Struct_Case.DataTable{Indice_ReduceError, :};
Struct_Case.ResultantVelocity = sqrt(Struct_Case.DataTableReduceError(:, 3).^2 + Struct_Case.DataTableReduceError(:, 4).^2 + Struct_Case.DataTableReduceError(:, 5).^2);
Struct_Case.MeanVelocity = mean(Struct_Case.ResultantVelocity);