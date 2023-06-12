%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_FFT.m
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

% 快速傅里叶变换及修正[FrameFre]

function Struct_Case = Fun_FFT(Struct_Case)

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

Struct_Case = Fun_FrameFreCom(Struct_Case);                                                                 % 【帧叠加】调用[Fun_FrameCutMove]自定义函数
end