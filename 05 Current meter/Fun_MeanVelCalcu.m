%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_MeanVelCalcu.m
 * @Brief:      1. 筛选出置信度较高的采样数据
 *              2. 计算平均速度
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.04
 *------------------------------------------------------------------------------------------
%}

function Struct_Case = Fun_MeanVelCalcu(FileName_txt)

Struct_Case.DataTable = readtable(FileName_txt, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                                   % 导入流速仪文件
Indice_ReduceError = (Struct_Case.DataTable{:, 15} >= 90) & (Struct_Case.DataTable{:, 16} >= 90) & (Struct_Case.DataTable{:, 17} >= 90);    % 筛选置信度较高的采样点
Struct_Case.DataTableReduceError = Struct_Case.DataTable{Indice_ReduceError, :};
% Struct_Case.ResultantVelocity = sqrt(Struct_Case.DataTableReduceError(:, 3).^2 + Struct_Case.DataTableReduceError(:, 4).^2 + Struct_Case.DataTableReduceError(:, 5).^2);
Struct_Case.ResultantVelocity = sqrt(Struct_Case.DataTableReduceError(:, 3).^2 + Struct_Case.DataTableReduceError(:, 4).^2);
Struct_Case.MeanVelocity = mean(Struct_Case.ResultantVelocity);

end