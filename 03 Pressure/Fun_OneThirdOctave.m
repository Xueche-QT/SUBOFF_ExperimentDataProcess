%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_OneThirdOctave.m
 * @Brief:      1. 【FFT】分别对[加窗]和[不加窗]的[帧]数据进行快速傅里叶变换和修正
 *              2. 【帧叠加】调用[Fun_FrameCutMove]自定义函数完成
 *                 分别对[加窗]和[不加窗]的[帧]数据进行叠加
 *              3. 【存储】生成对应的结构体存储信息
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.03
 *------------------------------------------------------------------------------------------
%}


function Struct_Case = Fun_OneThirdOctave(Struct_Case)

%% 求取三分之一倍频程的频带[Octave]
Struct_Case.Octave.End_Fre = 1000.0;                                                                  % 结束频率(Hz)
Struct_Case.Octave.Base = 10;                                                                           % 基数
Struct_Case.Octave.Factor = 2^(1/3);                                                                    % 三分之一倍频程因子

% 计算中心频率
i = -20;                                                                                                % 迭代因子
Struct_Case.Octave.Center_Fre = 1000 * (10^(1 / 10))^(i);                                               % 中心频率计算公式
while Struct_Case.Octave.Center_Fre(end) < Struct_Case.Octave.End_Fre                                  % 迭代
    i = i + 1;
    Struct_Case.Octave.Center_Fre = [Struct_Case.Octave.Center_Fre, 1000 * (10^(1 / 10))^(i)];
end

% 计算频率界限
Struct_Case.Octave.LowerBound = Struct_Case.Octave.Center_Fre * 2^(-1 / 6);                             % 下界
Struct_Case.Octave.UpperBound = Struct_Case.Octave.Center_Fre * 2^(1 / 6);                              % 上界

% 将中心频率和频率界限组合成一个矩阵，每行是一个三分之一倍频程[下界 中心频率 上界]
Struct_Case.Octave.OctaveBands = [Struct_Case.Octave.LowerBound', Struct_Case.Octave.Center_Fre', Struct_Case.Octave.UpperBound'];

%% 倍频程声压幅值和声压级
Struct_Case.Octave.RMSValue = zeros(size(Struct_Case.Octave.Center_Fre));                               % 初始化[无窗函数]数组存储每个三分之一倍频程带的RMS值(声压)
Struct_Case.Octave.SPLValue = zeros(size(Struct_Case.Octave.Center_Fre));                               % 初始化[无窗函数]数组存储每个三分之一倍频程带的SPL值(声压级)

Struct_Case.Octave.RMSValue_Window = zeros(size(Struct_Case.Octave.Center_Fre));                        % 初始化[加窗函数]数组存储每个三分之一倍频程带的RMS值(声压)
Struct_Case.Octave.SPLValue_Window = zeros(size(Struct_Case.Octave.Center_Fre));                        % 初始化[加窗函数]数组存储每个三分之一倍频程带的SPL值(声压级)

% 对每个三分之一倍频程带进行循环
for i = 1 : length(Struct_Case.Octave.Center_Fre)
    % 查找各个三分之一倍频带内所包含的[谱线]
    Indices = (Struct_Case.FrameFre.Frame_Fre_All(:, 1) >= Struct_Case.Octave.LowerBound(i)) & (Struct_Case.FrameFre.Frame_Fre_All(:, 1) <= Struct_Case.Octave.UpperBound(i));
    P_Band = Struct_Case.FrameFre.Frame_Fre_All(Indices, 2);                                            % [无窗函数]指定频段内的声压值
    P_Band_Window = Struct_Case.FrameFre.Frame_Window_Fre_All(Indices, 2);                              % [加窗函数]指定频段内的声压值

    Struct_Case.Octave.RMSValue(i) = sqrt(mean(P_Band.^2));                                             % [无窗函数]指定频段的RMS值(声压)
    Struct_Case.Octave.RMSValue_Window(i) = sqrt(mean(P_Band_Window.^2));                               % [加窗函数]指定频段的RMS值(声压)

    Struct_Case.Octave.SPLValue(i) = 20 * log10(Struct_Case.Octave.RMSValue(i) / Struct_Case.TimeDomainInf.Ref_Pressure);                 % [无窗函数]指定频段的SPL值(声压级)
    Struct_Case.Octave.SPLValue_Window(i) = 20 * log10(Struct_Case.Octave.RMSValue_Window(i) / Struct_Case.TimeDomainInf.Ref_Pressure);   % [加窗函数]指定频段的SPL值(声压级)
end

%% 倍频程图[Octave]

% 计算每个柱形的宽度
Struct_Case.Octave.BoundWidth = Struct_Case.Octave.UpperBound - Struct_Case.Octave.LowerBound;

figure;
subplot(2, 1, 1);
hold on;
for i = 1 : length(Struct_Case.Octave.Center_Fre)
    bar(Struct_Case.Octave.Center_Fre(i), Struct_Case.Octave.SPLValue(i), 'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'k', 'LineWidth', 1, 'BarWidth', Struct_Case.Octave.BoundWidth(i))
end
hold off;
set(gca, 'XScale', 'log');  % 将x轴设置为对数刻度
xlabel('频率 (Hz)');
ylabel('声压级 (dB)');
xlim([(Struct_Case.Octave.LowerBound(1) - 1) Struct_Case.Octave.UpperBound(end)]);
title('[无窗函数]三分之一倍频程声压级图');

subplot(2, 1, 2);
hold on;
for i = 1 : length(Struct_Case.Octave.Center_Fre)
    bar(Struct_Case.Octave.Center_Fre(i), Struct_Case.Octave.SPLValue_Window(i), 'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'k', 'LineWidth', 1, 'BarWidth', Struct_Case.Octave.BoundWidth(i))
end
hold off;
set(gca, 'XScale', 'log');  % 将x轴设置为对数刻度
xlabel('频率 (Hz)');
ylabel('声压级 (dB)');
xlim([(Struct_Case.Octave.LowerBound(1) - 1) Struct_Case.Octave.UpperBound(end)]);
title('[加窗函数]三分之一倍频程声压级图');

end