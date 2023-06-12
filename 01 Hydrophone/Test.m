%{
 *=======================================================================================
 *========================================【M FILE】=====================================
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Test.m
 * @Brief:      1. 测试代码，用来测试自定义函数
 *
 * @Author:     Haiger
 * @date:       2023.06.03
 *=======================================================================================
%}

clc;
clear;

%% ------------------------------【1 导入数据 / 输入参数】------------------------------
%{
    读取数据
    因数据量过多，导致.xlsx文件中Sheet1无法全部存储完，有部分数据存储在Sheet2中
    故需要读取两次，并进行垂直拼接
%}
FileName_xlsx = 'H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\01 Hydrophone\02 10s\000_NoMotor_Backgroud.xlsx';
DataTable1 = readtable(FileName_xlsx, 'Sheet', 1, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                         % 读取sheet1中的数据
DataTable1.Properties.VariableNames = ["Time", "Pressure"];                     % 设置列属性，需保证垂直拼接的表具有相同变量名称
DataTable2 = readtable(FileName_xlsx, 'Sheet', 2, 'ReadRowNames', false, 'VariableNamingRule', 'preserve');                         % 读取sheet2中的数据
DataTable2.Properties.VariableNames = ["Time", "Pressure"];                     % 设置列属性
Struct_Case.DataTable = [DataTable1; DataTable2];                               % 垂直拼接两个表

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    平衡清零[BalanceZeroing]
    取声压数组均值，即为偏移值
%}
Struct_Case.BalanceZeroing.PressureOffset = mean(Struct_Case.DataTable{:, 2});  % [声压偏移值(Pa)]对声压数组求取平均值，为便于后续平衡清零
Struct_Case.DataTable{:, 2} = Struct_Case.DataTable{:, 2} - Struct_Case.BalanceZeroing.PressureOffset;                              % [平衡清零]

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    读取时域信息[TimeDomainInf]
    [采样时间(相对)]、[声压(Pa)]、[采样点数]、[采样间隔(s)]、[采样频率(Hz)]、[采样总时间(s)]、[声压级(dB)]
%}
Struct_Case.TimeDomainInf.SamplingTime = Struct_Case.DataTable{:, 1};           % [采样时间(相对)]数组
Struct_Case.TimeDomainInf.Pressure = Struct_Case.DataTable{:, 2};               % [声压(Pa)]数组
Struct_Case.TimeDomainInf.SamplingNum = length(Struct_Case.TimeDomainInf.SamplingTime);                                             % [采样点数]
Struct_Case.TimeDomainInf.SamplingInterval = Struct_Case.TimeDomainInf.SamplingTime(2) - Struct_Case.TimeDomainInf.SamplingTime(1); % [采样间隔(s)]
Struct_Case.TimeDomainInf.SamplingFre = 1 / Struct_Case.TimeDomainInf.SamplingInterval;                                             % [采样频率(Hz)]
Struct_Case.TimeDomainInf.SamplingTotalTime = (Struct_Case.TimeDomainInf.SamplingNum - 1) * Struct_Case.TimeDomainInf.SamplingInterval; % [采样总时间(s)]
Struct_Case.TimeDomainInf.Ref_Pressure = 1 * 10^(-6);                           % 参考声压(水中)
Struct_Case.TimeDomainInf.SPL = 20 * log10(abs(Struct_Case.TimeDomainInf.Pressure) ./ Struct_Case.TimeDomainInf.Ref_Pressure);      % [声压级(dB)]数组

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    分帧 + 帧移[FrameTime]
    定义[帧长度(s)]、[帧移(s)]、[帧数目]
%}
Struct_Case.FrameTime.FrameLenth = 1;                                               % [帧长度(s)]
Struct_Case.FrameTime.FrameShift = 0.2;                                             % [帧移(s)]
Struct_Case.FrameTime.FrameNum = 10;                                                % [帧数目]
for i = 1 : Struct_Case.FrameTime.FrameNum                                          % 迭代进行分帧
    LowerIndex = round((Struct_Case.FrameTime.FrameLenth - Struct_Case.FrameTime.FrameShift) * (i - 1) / Struct_Case.TimeDomainInf.SamplingInterval + 1);                               % [帧段]下界
    UpperIndex = round(((Struct_Case.FrameTime.FrameLenth - Struct_Case.FrameTime.FrameShift) * i + Struct_Case.FrameTime.FrameShift) / Struct_Case.TimeDomainInf.SamplingInterval);    % [帧段]上界
    Struct_Case.FrameTime.(['Frame_' num2str(i)]) = Struct_Case.DataTable{ LowerIndex : UpperIndex, :};                              % [帧段]时间列、声压列
    Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 3) = Struct_Case.TimeDomainInf.SPL(LowerIndex : UpperIndex, :);                 % [帧段]声压级列
end

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    加窗[FrameTime]
    汉宁窗
%}
Struct_Case.FrameTime.FramePointNum = round(height(Struct_Case.FrameTime.Frame_1(:, 2)));
Struct_Case.FrameTime.FrameWindow = hann(Struct_Case.FrameTime.FramePointNum);
for i = 1 : Struct_Case.FrameTime.FrameNum
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 1) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 1);
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 2) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 2) .* Struct_Case.FrameTime.FrameWindow;
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 3) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 3) .* Struct_Case.FrameTime.FrameWindow;                               % 对第3列[声压级]数据[加窗]
end

%% ------------------------------【2 快速傅里叶变换】------------------------------
%{
    快速傅里叶变换及修正[FrameFre]
    分别对加窗数据和不加窗数据
%}
Fre_Axis = (0 : (Struct_Case.FrameTime.FramePointNum - 1)) * (Struct_Case.TimeDomainInf.SamplingFre / Struct_Case.FrameTime.FramePointNum); % 时域坐标转化成频域坐标
SingleSide_FreAxis = Fre_Axis(1 : Struct_Case.FrameTime.FramePointNum / 2 + 1);                                                     % 选取频率坐标前半部分[单边频谱]

% 未加窗的数据
for i = 1 : Struct_Case.FrameTime.FrameNum
    % [声压]
    FFT_Origin = fft(Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 2), Struct_Case.FrameTime.FramePointNum);                     % 对数据进行快速傅里叶变换
    P2 = abs(FFT_Origin / Struct_Case.FrameTime.FramePointNum);                                                                     % 对幅值进行修正：先除以样本数
    P1 = P2(1 : Struct_Case.FrameTime.FramePointNum / 2 + 1);                                                                       % 选取前半部分[单边频谱]
    P1(2 : end-1) = 2 * P1(2 : end-1);                                                                                              % 除去首尾两个元素，其余元素赋值乘以2，完成修正
    
    % [声压级]
    FFT_Origin_SPL = fft(Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 3), Struct_Case.FrameTime.FramePointNum);                 % 对数据进行快速傅里叶变换
    P2_SPL = abs(FFT_Origin_SPL / Struct_Case.FrameTime.FramePointNum);                                                             % 对幅值进行修正：先除以样本数
    P1_SPL = P2_SPL(1 : Struct_Case.FrameTime.FramePointNum / 2 + 1);                                                               % 选取前半部分[单边频谱]
    P1_SPL(2 : end-1) = 2 * P1_SPL(2 : end-1);                                                                                      % 除去首尾两个元素，其余元素赋值乘以2，完成修正

    Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 1) = SingleSide_FreAxis;                                                    % 频率列
    Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 2) = P1;                                                                    % [声压]幅值
    Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 3) = P1_SPL;                                                                % [声压级SPL]幅值(通过傅里叶变换得到)
    Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 4) = 20 * log10(P1 ./ Struct_Case.TimeDomainInf.Ref_Pressure);              % [声压级SPL]幅值(通过[声压]转换得到)【推荐】
end

% 加窗的数据
for i = 1 : Struct_Case.FrameTime.FrameNum
    % [声压]
    FFT_Origin_Window = fft(Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 2), Struct_Case.FrameTime.FramePointNum);       % 对数据进行快速傅里叶变换
    P2_Window = abs(FFT_Origin_Window / Struct_Case.FrameTime.FramePointNum);                                                       % 对幅值进行修正：先除以样本数
    P1_Window = P2_Window(1 : Struct_Case.FrameTime.FramePointNum / 2 + 1);                                                         % 选取前半部分[单边频谱]
    P1_Window(2 : end-1) = 2 * P1_Window(2 : end-1);                                                                                % 除去首尾两个元素，其余元素赋值乘以2，完成修正
    
    % [声压级]
    FFT_Origin_Window_SPL = fft(Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 3), Struct_Case.FrameTime.FramePointNum);   % 对数据进行快速傅里叶变换
    P2_Window_SPL = abs(FFT_Origin_Window_SPL / Struct_Case.FrameTime.FramePointNum);                                               % 对幅值进行修正：先除以样本数
    P1_Window_SPL = P2_Window_SPL(1 : Struct_Case.FrameTime.FramePointNum / 2 + 1);                                                 % 选取前半部分[单边频谱]
    P1_Window_SPL(2 : end-1) = 2 * P1_Window_SPL(2 : end-1);                                                                        % 除去首尾两个元素，其余元素赋值乘以2，完成修正

    Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 1) = SingleSide_FreAxis;                                             % 频率列
    Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 2) = P1_Window;                                                      % [声压]幅值
    Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 3) = P1_Window_SPL;                                                  % [声压级SPL]幅值(通过傅里叶变换得到)
    Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 4) = 20 * log10(P1_Window ./ Struct_Case.TimeDomainInf.Ref_Pressure);% [声压级SPL]幅值(通过[声压]转换得到)【推荐】
end

figure;
subplot(2, 1, 1);
plot(Struct_Case.FrameTime.Frame_1(:, 1), Struct_Case.FrameTime.Frame_1(:, 2));
subplot(2, 1, 2);
plot(Struct_Case.FrameTime.Frame_1(:, 1), Struct_Case.FrameTime.Frame_1(:, 3));

figure;
subplot(2, 1, 1);
semilogx(Struct_Case.FrameFre.Frame_Fre_1(:, 1), Struct_Case.FrameFre.Frame_Fre_1(:, 2));
grid on;
subplot(2, 1, 2);
semilogx(Struct_Case.FrameFre.Frame_Fre_1(:, 1), Struct_Case.FrameFre.Frame_Fre_1(:, 4));
grid on;

figure;
subplot(2, 1, 1);
plot(Struct_Case.FrameTime.Frame_Window_1(:, 1), Struct_Case.FrameTime.Frame_Window_1(:, 2));
subplot(2, 1, 2);
plot(Struct_Case.FrameTime.Frame_Window_1(:, 1), Struct_Case.FrameTime.Frame_Window_1(:, 3));

figure;
subplot(2, 1, 1);
semilogx(Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1), Struct_Case.FrameFre.Frame_Window_Fre_1(:, 2));
grid on;
subplot(2, 1, 2);
semilogx(Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1), Struct_Case.FrameFre.Frame_Window_Fre_1(:, 4));
grid on;

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    [帧]叠加[FrameFre]
    将[声压]幅值进行叠加
%}

% 初始化
% 未加窗的数据
Struct_Case.FrameFre.Frame_Fre_All(:, 1) = Struct_Case.FrameFre.Frame_Fre_1(:, 1);                                                  % 频率列
Struct_Case.FrameFre.Frame_Fre_All(:, 2) = zeros(height(Struct_Case.FrameFre.Frame_Fre_1(:, 1)), 1);                                % [声压]幅值[叠加]列初始化
Struct_Case.FrameFre.Frame_Fre_All(:, 3) = zeros(height(Struct_Case.FrameFre.Frame_Fre_1(:, 1)), 1);                                % [声压级SPL]幅值(通过傅里叶变换得到)[叠加]列初始化
Struct_Case.FrameFre.Frame_Fre_All(:, 4) = zeros(height(Struct_Case.FrameFre.Frame_Fre_1(:, 1)), 1);                                % [声压级SPL]幅值(通过[声压]转换得到)【推荐】[叠加]列初始化

% 加窗的数据
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 1) = Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1);                                    % 频率列
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) = zeros(height(Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1)), 1);                  % [声压]幅值[叠加]列初始化
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 3) = zeros(height(Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1)), 1);                  % [声压级SPL]幅值(通过傅里叶变换得到)[叠加]列初始化
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4) = zeros(height(Struct_Case.FrameFre.Frame_Window_Fre_1(:, 1)), 1);                  % [声压级SPL]幅值(通过[声压]转换得到)【推荐】[叠加]列初始化

% [帧]段叠加
for i = 1 : Struct_Case.FrameTime.FrameNum
    %  [声压]幅值[叠加]
    Struct_Case.FrameFre.Frame_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Fre_All(:, 2) + Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 2);                          % 未加窗的数据 
    Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) + Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 2);     % 加窗的数据
end

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    [帧]段平均[FrameFre]
    转换为[声压级SPL]
%}

% 未加窗的数据 
Struct_Case.FrameFre.Frame_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Fre_All(:, 2) / Struct_Case.FrameTime.FrameNum;               % [声压]幅值平均
Struct_Case.FrameFre.Frame_Fre_All(:, 4) = 20 * log10(Struct_Case.FrameFre.Frame_Fre_All(:, 2) ./ Struct_Case.TimeDomainInf.Ref_Pressure);          % 转换为[声压级SPL]，因声压级不可直接加减

% 加窗的数据
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) / Struct_Case.FrameTime.FrameNum;
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4) = 20 * log10(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) ./ Struct_Case.TimeDomainInf.Ref_Pressure);

figure;
subplot(2, 1, 1);
semilogx(Struct_Case.FrameFre.Frame_Fre_All(:, 1), Struct_Case.FrameFre.Frame_Fre_All(:, 2));
grid on;
subplot(2, 1, 2);
semilogx(Struct_Case.FrameFre.Frame_Fre_All(:, 1), Struct_Case.FrameFre.Frame_Fre_All(:, 4));
grid on;

figure;
subplot(2, 1, 1);
semilogx(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 1), Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2));
grid on;
subplot(2, 1, 2);
semilogx(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 1), Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4));
grid on;

%% ------------------------------【3 总声压级OSPL】------------------------------
%{
    整个频段[OSPL]
    分别对加窗数据和不加窗数据
%}
% 未加窗的数据
Linear_Values = 10.^(Struct_Case.FrameFre.Frame_Fre_All(:, 4) / 10);                                                        % 转换为线性值
Total_Energy = sum(Linear_Values);
Struct_Case.OSPL.OSPLALL = 10 * log10(Total_Energy);                                                                        % 全部频段的OSPL

% 加窗的数据
Linear_Values_Window = 10.^(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4) / 10);                                          % 转换为线性值
Total_Energy_Window = sum(Linear_Values_Window);
Struct_Case.OSPL.OSPLALL_Window = 10 * log10(Total_Energy_Window);                                                          % 全部频段的OSPL

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    频段10Hz~1000Hz[OSPL]
    分别对加窗数据和不加窗数据
%}
% 未加窗的数据
% 因计算得到的频率是浮点数，接近整数，例如10Hz(9.9999999Hz)，故这儿使用9.99作为逻辑判断值
Struct_Case.FrameFre.Frame_Fre_PartialIndex = (Struct_Case.FrameFre.Frame_Fre_All(:, 1) >= 9.99) & (Struct_Case.FrameFre.Frame_Fre_All(:, 1) <= 1000); % 筛选出频率在10Hz~1000Hz范围内的索引
Struct_Case.FrameFre.Frame_Fre_Partial = Struct_Case.FrameFre.Frame_Fre_All(Struct_Case.FrameFre.Frame_Fre_PartialIndex, :);                           % 得到10Hz~1000Hz频段的计算结果

Linear_Values_Partial = 10.^(Struct_Case.FrameFre.Frame_Fre_Partial(:, 4) / 10);                                            % 转换为线性值
Total_Energy_Partial = sum(Linear_Values_Partial);
Struct_Case.OSPL.OSPLPartial = 10 * log10(Total_Energy_Partial);                                                            % 部分频段10Hz~1000Hz的OSPL

% 加窗的数据
Struct_Case.FrameFre.Frame_Window_Fre_PartialIndex = (Struct_Case.FrameFre.Frame_Window_Fre_All(:, 1) >= 9.99) & (Struct_Case.FrameFre.Frame_Window_Fre_All(:, 1) <= 1000);    % 筛选出频率在10Hz~1000Hz范围内的索引
Struct_Case.FrameFre.Frame_Window_Fre_Partial = Struct_Case.FrameFre.Frame_Window_Fre_All(Struct_Case.FrameFre.Frame_Window_Fre_PartialIndex, :);                              % 得到10Hz~1000Hz频段的计算结果

Linear_Values_Window_Partial = 10.^(Struct_Case.FrameFre.Frame_Window_Fre_Partial(:, 4) / 10);                              % 转换为线性值
Total_Energy_Window_Partial = sum(Linear_Values_Window_Partial);
Struct_Case.OSPL.OSPLPartial_Window = 10 * log10(Total_Energy_Window_Partial);                                              % 部分频段10Hz~1000Hz的OSPL

%% ------------------------------【4 三分之一倍频程】------------------------------
%{
    求取三分之一倍频程的频带[Octave]
    中心频率范围为1~100kHz
%}

Struct_Case.Octave.End_Fre = 1000.0;                                                                    % 结束频率(Hz)
Struct_Case.Octave.Base = 10;                                                                           % 基数
Struct_Case.Octave.Factor = 2^(1/3);                                                                    % 三分之一倍频程因子

% 计算中心频率
i = -20;                                                                                                % 迭代因子
Struct_Case.Octave.Center_Fre = 1000 * (10^(1 / 10))^(i);                                               % 中心频率计算公式
while Struct_Case.Octave.Center_Fre(end) <= Struct_Case.Octave.End_Fre                                  % 迭代
    i = i + 1;
    Struct_Case.Octave.Center_Fre = [Struct_Case.Octave.Center_Fre, 1000 * (10^(1 / 10))^(i)];
end

% 计算频率界限
Struct_Case.Octave.LowerBound = Struct_Case.Octave.Center_Fre * 2^(-1 / 6);                             % 下界
Struct_Case.Octave.UpperBound = Struct_Case.Octave.Center_Fre * 2^(1 / 6);                              % 上界

% 将中心频率和频率界限组合成一个矩阵，每行是一个三分之一倍频程[下界 中心频率 上界]
Struct_Case.Octave.OctaveBands = [Struct_Case.Octave.LowerBound', Struct_Case.Octave.Center_Fre', Struct_Case.Octave.UpperBound'];

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    倍频程声压幅值和声压级
    分别对加窗数据和不加窗数据
%}

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

% -------------------------------------------------------------------------------------------------------------------------------------------------------
%{
    倍频程图[Octave]
    分别对加窗数据和不加窗数据
%}

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