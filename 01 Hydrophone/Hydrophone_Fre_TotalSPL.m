%{
 *=======================================================================================
 *========================================【M FILE】=====================================
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Hydrophone_Fre_TotalSPL.m
 * @Brief:      1. 显示输入的时域数据，转化为声压级SPL
 *              2. 进行快速傅里叶变换，得到声压级SPL随频率的变化
 *              3. 计算总声压级
 *
 * @Author:     Haiger
 * @date:       2023.05.02
 *=======================================================================================
%}

clc;
clear;

%% ------------------------------【1 导入数据 / 输入参数】------------------------------
%{
    读取输入的时域数据，并转化为声压级SPL
%}

% 读取输入的时域数据[N×2 Table]【采样时间(相对)-声压(Pa)】
Struct_00_Motor_Backgroud = Fun_ImportData('00_Motor_Backgroud.xlsx');      % 00 电机背景噪声
Struct_01_V_0_00 = Fun_ImportData('01_V_0_00.xlsx');                        % 01 航速为0时声压结果
Struct_02_V_1_02 = Fun_ImportData('02_V_1_02.xlsx');                        % 02 航速约为0.2时声压结果
Struct_03_V_2_04 = Fun_ImportData('03_V_2_04.xlsx');                        % 03 航速约为0.4时声压结果
Struct_04_V_3_06 = Fun_ImportData('04_V_3_06.xlsx');                        % 04 航速约为0.6时声压结果
Struct_05_V_4_08 = Fun_ImportData('05_V_4_08.xlsx');                        % 05 航速约为0.8时声压结果
Struct_06_V_5_1 = Fun_ImportData('06_V_5_1.xlsx');                          % 06 航速约为1.0时声压结果

% figure;
% subplot(2, 1, 1);                                                           % 图1.1 [电机背景噪声]时域信号声压图
% Fun_MultiPlot(1, Struct_01_V_0_00.SamplingTime, Struct_01_V_0_00.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false);
% a = mean(Struct_01_V_0_00.Pressure);
% Struct_01_V_0_00.Pressure = Struct_01_V_0_00.Pressure - a;
% Struct_01_V_0_00.SPL = 20 * log10(abs(Struct_01_V_0_00.Pressure) ./ 1 * 10^(-6));     % [声压级(dB)]数组
% subplot(2, 1, 2);                                                           % 图1.1 [电机背景噪声]时域信号声压图
% Fun_MultiPlot(1, Struct_01_V_0_00.SamplingTime, Struct_01_V_0_00.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false);
% 
% figure;
% subplot(2, 1, 1);                                                           % 图1.1 [电机背景噪声]时域信号声压图
% Fun_MultiPlot(1, Struct_02_V_1_02.SamplingTime, Struct_02_V_1_02.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false)
% b = mean(Struct_02_V_1_02.Pressure);
% Struct_02_V_1_02.Pressure = Struct_02_V_1_02.Pressure - b;
% Struct_02_V_1_02.SPL = 20 * log10(abs(Struct_02_V_1_02.Pressure) ./ 1 * 10^(-6));     % [声压级(dB)]数组
% subplot(2, 1, 2);                                                           % 图1.1 [电机背景噪声]时域信号声压图
% Fun_MultiPlot(1, Struct_02_V_1_02.SamplingTime, Struct_02_V_1_02.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false);

% 00 电机背景噪声
figure;
subplot(2, 1, 1);                                                           % 图1.1 [电机背景噪声]时域信号声压图
Fun_MultiPlot(1, Struct_00_Motor_Backgroud.SamplingTime, Struct_00_Motor_Backgroud.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false);

subplot(2, 1, 2);                                                           % 图1.2 [电机背景噪声]时域信号声压级图
Fun_MultiPlot(1, Struct_00_Motor_Backgroud.SamplingTime, Struct_00_Motor_Backgroud.SPL, '相对时间 (s)', '声压级 (dB)', '时域信号声压图', false);

%% 进行快速傅里叶变换，得到声压级SPL随频率的变化
[Struct_00_Motor_Backgroud.SingleSide_FreAxis, Struct_00_Motor_Backgroud.FreDomain_Amp] = Fun_FFT(Struct_00_Motor_Backgroud.SPL, Struct_00_Motor_Backgroud.SamplingNum, Struct_00_Motor_Backgroud.SamplingFre);
[Struct_01_V_0_00.SingleSide_FreAxis, Struct_01_V_0_00.FreDomain_Amp] = Fun_FFT(Struct_01_V_0_00.SPL, Struct_01_V_0_00.SamplingNum, Struct_01_V_0_00.SamplingFre);
[Struct_02_V_1_02.SingleSide_FreAxis, Struct_02_V_1_02.FreDomain_Amp] = Fun_FFT(Struct_02_V_1_02.SPL, Struct_02_V_1_02.SamplingNum, Struct_02_V_1_02.SamplingFre);
[Struct_03_V_2_04.SingleSide_FreAxis, Struct_03_V_2_04.FreDomain_Amp] = Fun_FFT(Struct_03_V_2_04.SPL, Struct_03_V_2_04.SamplingNum, Struct_03_V_2_04.SamplingFre);
[Struct_04_V_3_06.SingleSide_FreAxis, Struct_04_V_3_06.FreDomain_Amp] = Fun_FFT(Struct_04_V_3_06.SPL, Struct_04_V_3_06.SamplingNum, Struct_04_V_3_06.SamplingFre);
[Struct_05_V_4_08.SingleSide_FreAxis, Struct_05_V_4_08.FreDomain_Amp] = Fun_FFT(Struct_05_V_4_08.SPL, Struct_05_V_4_08.SamplingNum, Struct_05_V_4_08.SamplingFre);
[Struct_06_V_5_1.SingleSide_FreAxis, Struct_06_V_5_1.FreDomain_Amp] = Fun_FFT(Struct_06_V_5_1.SPL, Struct_06_V_5_1.SamplingNum, Struct_06_V_5_1.SamplingFre);
figure;                                                                     % 图2.1 声压级频谱图
Fun_MultiPlot(2, Struct_00_Motor_Backgroud.SingleSide_FreAxis, Struct_00_Motor_Backgroud.FreDomain_Amp, '频率 (Hz)', '幅值', '声压级频谱图', true);

%% 计算总声压级OSPL
Struct_00_Motor_Backgroud.OSPL = Fun_OSPLCalcu(Struct_00_Motor_Backgroud.FreDomain_Amp);
Struct_01_V_0_00.OSPL = Fun_OSPLCalcu(Struct_01_V_0_00.FreDomain_Amp);
Struct_02_V_1_02.OSPL = Fun_OSPLCalcu(Struct_02_V_1_02.FreDomain_Amp);
Struct_03_V_2_04.OSPL = Fun_OSPLCalcu(Struct_03_V_2_04.FreDomain_Amp);
Struct_04_V_3_06.OSPL = Fun_OSPLCalcu(Struct_04_V_3_06.FreDomain_Amp);
Struct_05_V_4_08.OSPL = Fun_OSPLCalcu(Struct_05_V_4_08.FreDomain_Amp);
Struct_06_V_5_1.OSPL = Fun_OSPLCalcu(Struct_06_V_5_1.FreDomain_Amp);

%% 绘制不同流速下总声级变化曲线，并进行拟合，计算总声压级(OSPL)正比于速度的多少次方

