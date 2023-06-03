%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_FFT.m
 * @Brief:      进行快速傅里叶变换
 * 
 * @Input:      TimeDomain_Data                 【时域】数据                          N×1数组
 *              TimeDomain_Data_SamplingNum     【时域】采样点数                      double
 *              TimeDomain_Data_SamplingFre     【时域】采样频率                      double
 * 
 * @Output:     SingleSide_FreAxis              【单边频谱】频率坐标                  (N/2+1)×1数组
 *              FreDomain_Amp                   【单边频谱】幅值                      (N/2+1)×1数组
 * 
 * @Author:     Haiger
 * @date:       2023.05.09
 *------------------------------------------------------------------------------------------
%}

function [SingleSide_FreAxis, FreDomain_Amp] = Fun_FFT(TimeDomain_Data, TimeDomain_Data_SamplingNum, TimeDomain_Data_SamplingFre)

FFT_Origin = fft(TimeDomain_Data, TimeDomain_Data_SamplingNum);             % 对数据进行快速傅里叶变换
Fre_Axis = (0 : (TimeDomain_Data_SamplingNum - 1)) * (TimeDomain_Data_SamplingFre / TimeDomain_Data_SamplingNum);   % 时域坐标转化成频域坐标

% 计算单侧频谱
P2 = abs(FFT_Origin / TimeDomain_Data_SamplingNum);                         % 对幅值进行修正：先除以样本数
P1 = P2(1 : TimeDomain_Data_SamplingNum / 2 + 1);                           % 选取前半部分[单边频谱]
P1(2 : end-1) = 2 * P1(2 : end-1);                                          % 除去首尾两个元素，其余元素赋值乘以2，完成修正
FreDomain_Amp = P1;                                                         % [单边频谱]幅值
SingleSide_FreAxis = Fre_Axis(1 : TimeDomain_Data_SamplingNum / 2 + 1);     % 选取频率坐标前半部分[单边频谱]

end