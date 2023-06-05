%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_ImportData_Cutting.m
 * @Brief:      1. 【导入】导入长度为 T (默认为10s)的[水听器数据]，并读取时域信息
 *              2. 【平衡清零】求取数据中均值(偏移值)，进行平衡清零
 *              3. 【分帧 + 帧移】调用[Fun_FrameCutMove]自定义函数完成
 *                  【分帧】将导入的数据[分帧]，切片为长度为 t (默认为1s)的帧
 *                  【帧移】每帧之间重合部分的长度为 ∆t (默认为0.2s)
 *              4. 【加窗】调用[Fun_Window]自定义函数对每段[帧]添加窗函数
 *              5. 【存储】生成对应的结构体存储信息
 * 
 * @Input:      FileName_xlsx                   输入文件名(xlsx)                    字符串
 * 
 * @Output:     Struct_Case                     工况对应的结构体                    Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.03
 *------------------------------------------------------------------------------------------
%}

function Struct_Case = Fun_ImportData_Cutting(FileName_xlsx)

DataTable1 = readtable(FileName_xlsx, 'Sheet', 1, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                         % 读取sheet1中的数据
DataTable1.Properties.VariableNames = ["Time", "Pressure"];                     % 设置列属性，需保证垂直拼接的表具有相同变量名称
DataTable2 = readtable(FileName_xlsx, 'Sheet', 2, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                         % 读取sheet2中的数据
DataTable2.Properties.VariableNames = ["Time", "Pressure"];                     % 设置列属性
Struct_Case.DataTable = [DataTable1; DataTable2];                               % 垂直拼接两个表

% 平衡清零[BalanceZeroing]
Struct_Case.BalanceZeroing.PressureOffset = mean(Struct_Case.DataTable{:, 2});  % [声压偏移值(Pa)]对声压数组求取平均值，为便于后续平衡清零
Struct_Case.DataTable{:, 2} = Struct_Case.DataTable{:, 2} - Struct_Case.BalanceZeroing.PressureOffset;                              % [平衡清零]


% 读取时域信息[TimeDomainInf]并存储在结构体中
Struct_Case.TimeDomainInf.SamplingTime = Struct_Case.DataTable{:, 1};           % [采样时间(相对)]数组
Struct_Case.TimeDomainInf.Pressure = Struct_Case.DataTable{:, 2};               % [声压(Pa)]数组
Struct_Case.TimeDomainInf.SamplingNum = length(Struct_Case.TimeDomainInf.SamplingTime);                                             % [采样点数]
Struct_Case.TimeDomainInf.SamplingInterval = Struct_Case.TimeDomainInf.SamplingTime(2) - Struct_Case.TimeDomainInf.SamplingTime(1); % [采样间隔(s)]
Struct_Case.TimeDomainInf.SamplingFre = 1 / Struct_Case.TimeDomainInf.SamplingInterval;                                             % [采样频率(Hz)]
Struct_Case.TimeDomainInf.SamplingTotalTime = (Struct_Case.TimeDomainInf.SamplingNum - 1) * Struct_Case.TimeDomainInf.SamplingInterval; % [采样总时间(s)]
Struct_Case.TimeDomainInf.Ref_Pressure = 1 * 10^(-6);                           % 参考声压(水中)
Struct_Case.TimeDomainInf.SPL = 20 * log10(abs(Struct_Case.TimeDomainInf.Pressure) ./ Struct_Case.TimeDomainInf.Ref_Pressure);      % [声压级(dB)]数组

Struct_Case = Fun_FrameCutMove(Struct_Case, 1, 0.2, 10);                        % 调用自定义函数[Fun_FrameCutMove]完成【分帧】和【帧移】

Struct_Case = Fun_Window(Struct_Case);                                          % 调用自定义函数[Fun_Window]完成【加窗】

end