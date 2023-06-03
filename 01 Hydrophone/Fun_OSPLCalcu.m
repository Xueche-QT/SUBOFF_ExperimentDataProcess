%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_OSPLCalcu.m
 * @Brief:      计算总声压级
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

function OSPL = Fun_OSPLCalcu(FreDomain_Amp)
linear_values = 10.^(FreDomain_Amp / 10);               % 转换为线性值
total_energy = sum(linear_values);                      % 计算总能量
OSPL = 10 * log10(total_energy);                        % 转换回对数值(dB)
end