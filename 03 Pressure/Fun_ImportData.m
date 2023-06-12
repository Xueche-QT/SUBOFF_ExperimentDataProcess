%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_ImportData.m
 * @Brief:      导入[水听器数据]，生成对应的结构体存储信息
 * 
 * @Input:      FileName_xlsx                   输入文件名(xlsx)                    字符串
 * 
 * @Output:     Struct_Case                     工况对应的结构体                    Struct
 * 
 * @Author:     Haiger
 * @date:       2023.05.09
 *------------------------------------------------------------------------------------------
%}

function Struct_Case = Fun_ImportData(FileName_xlsx)

Struct_Case.DataTable = readtable(FileName_xlsx, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');
Struct_Case.SamplingTime = Struct_Case.DataTable{:, 1};                         % [采样时间(相对)]数组
Struct_Case.Pressure = Struct_Case.DataTable{:, 2};                             % [声压(Pa)]数组
Struct_Case.SamplingNum = length(Struct_Case.SamplingTime);                     % [采样点数]
Struct_Case.SamplingInterval = Struct_Case.SamplingTime(2) - Struct_Case.SamplingTime(1);                               % [采样间隔(s)]
Struct_Case.SamplingFre = 1 / Struct_Case.SamplingInterval;                     % [采样频率(Hz)]

Ref_Pressure = 1 * 10^(-6);                                                     % 参考声压(水中)
Struct_Case.SPL = 20 * log10(abs(Struct_Case.Pressure) ./ Ref_Pressure);        % [声压级(dB)]数组
end