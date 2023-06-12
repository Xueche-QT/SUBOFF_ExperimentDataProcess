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
 * @date:       2023.06.03
 *=======================================================================================
%}

clc;
clear;

%% ------------------------------【1 导入数据 / 输入参数】------------------------------
%{
    调用[Fun_ImportData_Cutting]自定义函数
    1. 【导入】导入长度为 T (默认为10s)的[水听器数据]，并读取时域信息
    2. 【平衡清零】求取数据中均值(偏移值)，进行平衡清零

    调用[Fun_FrameCutMove]自定义函数([Fun_ImportData_Cutting]内部调用)
    3. 【分帧 + 帧移】调用[Fun_FrameCutMove]自定义函数完成
        【分帧】将导入的数据[分帧]，切片为长度为 t (默认为1s)的帧
        【帧移】每帧之间重合部分的长度为 ∆t (默认为0.2s)

    调用[Fun_Window]自定义函数([Fun_ImportData_Cutting]内部调用)
    4. 【加窗】调用[Fun_Window]自定义函数对每段[帧]添加窗函数
    3. 【存储】生成对应的结构体存储信息
%}

% 读取输入的时域数据[N×2 Table]【采样时间(相对)-声压(Pa)】
Struct_000_NoMotor_Backgroud = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\000_NoMotor_Backgroud.xlsx');% 000 无电机背景噪声
Struct_001_Motor_Backgroud = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\001_Motor_Backgroud.xlsx');    % 001 电机背景噪声
Struct_01_V_0_00 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\01_V_0_00.xlsx');                        % 01 航速为0时
Struct_02_V_1_02 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\02_V_1_02.xlsx');                        % 02 航速约为0.2时
Struct_03_V_2_04 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\03_V_2_04.xlsx');                        % 03 航速约为0.4时
Struct_04_V_3_06 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\04_V_3_06.xlsx');                        % 04 航速约为0.6时
Struct_05_V_4_08 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\05_V_4_08.xlsx');                        % 05 航速约为0.8时
Struct_06_V_5_10 = Fun_ImportData_Cutting('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\06_V_5_10.xlsx');                        % 06 航速约为1.0时

% % 00 电机背景噪声
% figure;
% subplot(2, 1, 1);                                                           % 图1.1 [电机背景噪声]时域信号声压图
% Fun_MultiPlot(1, Struct_00_Motor_Backgroud.SamplingTime, Struct_00_Motor_Backgroud.Pressure, '相对时间 (s)', '声压 (Pa)', '时域信号声压图', false);
% 
% subplot(2, 1, 2);                                                           % 图1.2 [电机背景噪声]时域信号声压级图
% Fun_MultiPlot(1, Struct_00_Motor_Backgroud.SamplingTime, Struct_00_Motor_Backgroud.SPL, '相对时间 (s)', '声压级 (dB)', '时域信号声压图', false);

%% ------------------------------【2 快速傅里叶变换】------------------------------
%{
    调用[Fun_FFT]自定义函数
    1. 【FFT】分别对[加窗]和[不加窗]的[帧]数据进行快速傅里叶变换和修正

    调用[Fun_FrameCutMove]自定义函数([Fun_FFT]内部调用)
    2. 【帧叠加】分别对[加窗]和[不加窗]的[帧]数据进行叠加

    3. 【存储】生成对应的结构体存储信息
%}
Struct_000_NoMotor_Backgroud = Fun_FFT(Struct_000_NoMotor_Backgroud);       % 000 无电机背景噪声
Struct_001_Motor_Backgroud = Fun_FFT(Struct_001_Motor_Backgroud);           % 001 电机背景噪声
Struct_01_V_0_00 = Fun_FFT(Struct_01_V_0_00);                               % 01 航速为0时
Struct_02_V_1_02 = Fun_FFT(Struct_02_V_1_02);                               % 02 航速约为0.2时
Struct_03_V_2_04 = Fun_FFT(Struct_03_V_2_04);                               % 03 航速约为0.4时
Struct_04_V_3_06 = Fun_FFT(Struct_04_V_3_06);                               % 04 航速约为0.6时
Struct_05_V_4_08 = Fun_FFT(Struct_05_V_4_08);                               % 05 航速约为0.8时
Struct_06_V_5_10 = Fun_FFT(Struct_06_V_5_10);                               % 06 航速约为1.0时


%% ------------------------------【3 总声压级OSPL】------------------------------
%{
    调用[Fun_OSPLCalcu]自定义函数
    1. 【总声压级】分别对加窗和不加窗计算总声压级
    2. 【存储】生成对应的结构体存储信息
%}
Struct_000_NoMotor_Backgroud = Fun_OSPLCalcu(Struct_000_NoMotor_Backgroud); % 000 无电机背景噪声
Struct_001_Motor_Backgroud = Fun_OSPLCalcu(Struct_001_Motor_Backgroud);     % 001 电机背景噪声
Struct_01_V_0_00 = Fun_OSPLCalcu(Struct_01_V_0_00);                         % 01 航速为0时
Struct_02_V_1_02 = Fun_OSPLCalcu(Struct_02_V_1_02);                         % 02 航速约为0.2时
Struct_03_V_2_04 = Fun_OSPLCalcu(Struct_03_V_2_04);                         % 03 航速约为0.4时
Struct_04_V_3_06 = Fun_OSPLCalcu(Struct_04_V_3_06);                         % 04 航速约为0.6时
Struct_05_V_4_08 = Fun_OSPLCalcu(Struct_05_V_4_08);                         % 05 航速约为0.8时
Struct_06_V_5_10 = Fun_OSPLCalcu(Struct_06_V_5_10);                         % 06 航速约为1.0时

%% ------------------------------【4 三分之一倍频程】------------------------------
Struct_000_NoMotor_Backgroud = Fun_OneThirdOctave(Struct_000_NoMotor_Backgroud); % 000 无电机背景噪声
Struct_001_Motor_Backgroud = Fun_OneThirdOctave(Struct_001_Motor_Backgroud);     % 001 电机背景噪声
Struct_01_V_0_00 = Fun_OneThirdOctave(Struct_01_V_0_00);                         % 01 航速为0时
Struct_02_V_1_02 = Fun_OneThirdOctave(Struct_02_V_1_02);                         % 02 航速约为0.2时
Struct_03_V_2_04 = Fun_OneThirdOctave(Struct_03_V_2_04);                         % 03 航速约为0.4时
Struct_04_V_3_06 = Fun_OneThirdOctave(Struct_04_V_3_06);                         % 04 航速约为0.6时
Struct_05_V_4_08 = Fun_OneThirdOctave(Struct_05_V_4_08);                         % 05 航速约为0.8时
Struct_06_V_5_10 = Fun_OneThirdOctave(Struct_06_V_5_10);                         % 06 航速约为1.0时

%% ------------------------------【5 仿真数据】------------------------------
%{
    为1~2KHz声压级频谱，按上面的格式进行转换
%}
Struct_Simulation.DataTable = readtable('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\03 Simulation\DATA', 'ReadRowNames', false, 'VariableNamingRule', 'preserve');
Struct_Simulation.TimeDomainInf.Ref_Pressure = 1 * 10^(-6);
Struct_Simulation.FrameFre.Frame_Fre_All(:, 1) = Struct_Simulation.DataTable{:, 1};
Struct_Simulation.FrameFre.Frame_Fre_All(:, 2) = Struct_Simulation.TimeDomainInf.Ref_Pressure * 10.^(Struct_Simulation.DataTable{:, 2} ./ 20);
Struct_Simulation.FrameFre.Frame_Fre_All(:, 4) = Struct_Simulation.DataTable{:, 2};

Struct_Simulation.FrameFre.Frame_Window_Fre_All(:, 1) = Struct_Simulation.FrameFre.Frame_Fre_All(:, 1);
Struct_Simulation.FrameFre.Frame_Window_Fre_All(:, 2) = Struct_Simulation.FrameFre.Frame_Fre_All(:, 2);
Struct_Simulation.FrameFre.Frame_Window_Fre_All(:, 4) = Struct_Simulation.FrameFre.Frame_Fre_All(:, 4);
Struct_Simulation = Fun_OSPLCalcu(Struct_Simulation);
Struct_Simulation = Fun_OneThirdOctave(Struct_Simulation);
Output_SimOctaveCen_Window = [Struct_Simulation.Octave.Center_Fre', Struct_Simulation.Octave.SPLValue_Window'];

Modify_Struct_Simulation = Struct_Simulation;
Modify_Struct_Simulation.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_Simulation.FrameFre.Frame_Window_Fre_All(:, 4) + 7.6726;
Modify_Struct_Simulation = Fun_OSPLCalcu(Modify_Struct_Simulation);
Modify_Struct_Simulation = Fun_OneThirdOctave(Modify_Struct_Simulation);
Output_ModifySimOctaveCen_Window = [Modify_Struct_Simulation.Octave.Center_Fre', Modify_Struct_Simulation.Octave.SPLValue_Window'];


%% ------------------------------【6 图谱绘制】------------------------------
figure;
subplot(2, 1, 1);
Fun_MultiPlot(2, Struct_06_V_5_10.FrameFre.Frame_Fre_All(:, 1), Struct_06_V_5_10.FrameFre.Frame_Fre_All(:, 4), '频率 (s)', '声压级 (dB)', '【1m/s】[无窗]全频段声压级', true);
subplot(2, 1, 2);
Fun_MultiPlot(2, Struct_06_V_5_10.FrameFre.Frame_Window_Fre_All(:, 1), Struct_06_V_5_10.FrameFre.Frame_Window_Fre_All(:, 4), '频率 (s)', '声压级 (dB)', '【1m/s】[加窗]全频段声压级', true);

figure;
Fun_MultiPlot(2, Struct_000_NoMotor_Backgroud.FrameFre.Frame_Fre_Partial(:, 1), Struct_000_NoMotor_Backgroud.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
hold on;
Fun_MultiPlot(2, Struct_01_V_0_00.FrameFre.Frame_Fre_Partial(:, 1), Struct_01_V_0_00.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_02_V_1_02.FrameFre.Frame_Fre_Partial(:, 1), Struct_02_V_1_02.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_03_V_2_04.FrameFre.Frame_Fre_Partial(:, 1), Struct_03_V_2_04.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_04_V_3_06.FrameFre.Frame_Fre_Partial(:, 1), Struct_04_V_3_06.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_05_V_4_08.FrameFre.Frame_Fre_Partial(:, 1), Struct_05_V_4_08.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_06_V_5_10.FrameFre.Frame_Fre_Partial(:, 1), Struct_06_V_5_10.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
Fun_MultiPlot(2, Struct_Simulation.FrameFre.Frame_Fre_Partial(:, 1), Struct_Simulation.FrameFre.Frame_Fre_Partial(:, 4), '频率 (s)', '声压级 (dB)', '[无窗]全频段声压级', true);
hold off;
legend('NoMotor', 'V_0_00', 'V_1_02', 'V_2_04', 'V_3_06', 'V_4_08', 'V_5_10', 'Struct_Simulation');

%% ------------------------------【7 数据修改】------------------------------
Modify_Struct_000_NoMotor_Backgroud = Struct_000_NoMotor_Backgroud;
Modify_Struct_02_V_1_02 = Struct_02_V_1_02;
Modify_Struct_03_V_2_04 = Struct_03_V_2_04;
Modify_Struct_04_V_3_06 = Struct_04_V_3_06;
Modify_Struct_05_V_4_08 = Struct_05_V_4_08;
Modify_Struct_06_V_5_10 = Struct_06_V_5_10;

Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_All(:, 4);
Modify_Struct_02_V_1_02.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_02_V_1_02.FrameFre.Frame_Window_Fre_All(:, 4);
Modify_Struct_03_V_2_04.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_03_V_2_04.FrameFre.Frame_Window_Fre_All(:, 4) - 5;
Modify_Struct_04_V_3_06.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_04_V_3_06.FrameFre.Frame_Window_Fre_All(:, 4) - 3;
Modify_Struct_05_V_4_08.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_05_V_4_08.FrameFre.Frame_Window_Fre_All(:, 4) - 3;
Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_All(:, 4) = Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_All(:, 4);

Modify_Struct_000_NoMotor_Backgroud = Fun_OSPLCalcu(Modify_Struct_000_NoMotor_Backgroud); % 000 无电机背景噪声
Modify_Struct_02_V_1_02 = Fun_OSPLCalcu(Modify_Struct_02_V_1_02);
Modify_Struct_03_V_2_04 = Fun_OSPLCalcu(Modify_Struct_03_V_2_04);
Modify_Struct_04_V_3_06 = Fun_OSPLCalcu(Modify_Struct_04_V_3_06);
Modify_Struct_05_V_4_08 = Fun_OSPLCalcu(Modify_Struct_05_V_4_08);
Modify_Struct_06_V_5_10 = Fun_OSPLCalcu(Modify_Struct_06_V_5_10);

Modify_Struct_000_NoMotor_Backgroud = Fun_OneThirdOctave(Modify_Struct_000_NoMotor_Backgroud); % 000 无电机背景噪声
Modify_Struct_02_V_1_02 = Fun_OneThirdOctave(Modify_Struct_02_V_1_02);
Modify_Struct_03_V_2_04 = Fun_OneThirdOctave(Modify_Struct_03_V_2_04);
Modify_Struct_04_V_3_06 = Fun_OneThirdOctave(Modify_Struct_04_V_3_06);
Modify_Struct_05_V_4_08 = Fun_OneThirdOctave(Modify_Struct_05_V_4_08);
Modify_Struct_06_V_5_10 = Fun_OneThirdOctave(Modify_Struct_06_V_5_10);

Output_FrePartial_Window = [Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_Partial(:, 1), Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_Partial(:, 4), Modify_Struct_02_V_1_02.FrameFre.Frame_Window_Fre_Partial(:, 4), Modify_Struct_03_V_2_04.FrameFre.Frame_Window_Fre_Partial(:, 4), Modify_Struct_04_V_3_06.FrameFre.Frame_Window_Fre_Partial(:, 4), Modify_Struct_05_V_4_08.FrameFre.Frame_Window_Fre_Partial(:, 4), Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_Partial(:, 4)];
writematrix(Output_FrePartial_Window, 'H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\04 MATLAB Data\Output_FrePartial_Window.xlsx');

Output_Fre_Window = [Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_All(11 : end, 1), Modify_Struct_000_NoMotor_Backgroud.FrameFre.Frame_Window_Fre_All(11 : end, 4), Modify_Struct_02_V_1_02.FrameFre.Frame_Window_Fre_All(11 : end, 4), Modify_Struct_03_V_2_04.FrameFre.Frame_Window_Fre_All(11 : end, 4), Modify_Struct_04_V_3_06.FrameFre.Frame_Window_Fre_All(11 : end, 4), Modify_Struct_05_V_4_08.FrameFre.Frame_Window_Fre_All(11 : end, 4), Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_All(11 : end, 4)];
writematrix(Output_Fre_Window, 'H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\04 MATLAB Data\Output_Fre_Window.xlsx');

Output_OctaveCen_Window = [Modify_Struct_000_NoMotor_Backgroud.Octave.Center_Fre', Modify_Struct_000_NoMotor_Backgroud.Octave.SPLValue_Window', Modify_Struct_02_V_1_02.Octave.SPLValue_Window', Modify_Struct_03_V_2_04.Octave.SPLValue_Window', Modify_Struct_04_V_3_06.Octave.SPLValue_Window', Modify_Struct_05_V_4_08.Octave.SPLValue_Window', Modify_Struct_06_V_5_10.Octave.SPLValue_Window'];
writematrix(Output_OctaveCen_Window, 'H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\04 MATLAB Data\Output_OctaveCen_Window.xlsx');

for i = 1 : 2 :  length(Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_Partial(:, 1))
    fprintf("%f, ", Modify_Struct_06_V_5_10.FrameFre.Frame_Window_Fre_Partial(i, 4));
end

for i = 1 : 1 :  length(Struct_Simulation.Octave.SPLValue_Window)
    fprintf("%f\n", Struct_Simulation.Octave.SPLValue_Window(i));
end

OSPL_Modify_Struct_000_NoMotor_Backgroud = 20 * log10(sum(Modify_Struct_000_NoMotor_Backgroud.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));
OSPL_Modify_Struct_02_V_1_02 = 20 * log10(sum(Modify_Struct_02_V_1_02.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));
OSPL_Modify_Struct_03_V_2_04 = 20 * log10(sum(Modify_Struct_03_V_2_04.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));
OSPL_Modify_Struct_04_V_3_06 = 20 * log10(sum(Modify_Struct_04_V_3_06.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));
OSPL_Modify_Struct_05_V_4_08 = 20 * log10(sum(Modify_Struct_05_V_4_08.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));
OSPL_Modify_Struct_06_V_5_10 = 20 * log10(sum(Modify_Struct_06_V_5_10.Octave.RMSValue_Window(1, 4:end-1)) / (1 * 10^(-6)));