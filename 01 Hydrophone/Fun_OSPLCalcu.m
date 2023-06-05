%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_OSPLCalcu.m
 * @Brief:      分别计算[全部频段]和[10Hz-1000Hz]的总声压级
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.04
 *------------------------------------------------------------------------------------------
%}

function Struct_Case = Fun_OSPLCalcu(Struct_Case)

% 整个频段[OSPL]
% 未加窗的数据
Linear_Values = 10.^(Struct_Case.FrameFre.Frame_Fre_All(:, 4) / 10);                                                        % 转换为线性值
Total_Energy = sum(Linear_Values);
Struct_Case.OSPL.OSPLALL = 10 * log10(Total_Energy);                                                                        % 全部频段的OSPL

% 加窗的数据
Linear_Values_Window = 10.^(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4) / 10);                                          % 转换为线性值
Total_Energy_Window = sum(Linear_Values_Window);
Struct_Case.OSPL.OSPLALL_Window = 10 * log10(Total_Energy_Window);                                                          % 全部频段的OSPL

% 频段10Hz~1000Hz[OSPL]
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

end