%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_FrameFreCom.m
 * @Brief:      1. 【帧叠加】分别对[加窗]和[不加窗]的[帧]数据进行叠加
 *              2. 【存储】生成对应的结构体存储信息
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.04
 *------------------------------------------------------------------------------------------
%}

function Struct_Case = Fun_FrameFreCom(Struct_Case)

%% 初始化
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

%% [帧]段叠加
for i = 1 : Struct_Case.FrameTime.FrameNum
    %  [声压]幅值[叠加]
    Struct_Case.FrameFre.Frame_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Fre_All(:, 2) + Struct_Case.FrameFre.(['Frame_Fre_' num2str(i)])(:, 2);                          % 未加窗的数据 
    Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) + Struct_Case.FrameFre.(['Frame_Window_Fre_' num2str(i)])(:, 2);     % 加窗的数据
end

%% [帧]段平均
% 未加窗的数据 
Struct_Case.FrameFre.Frame_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Fre_All(:, 2) / Struct_Case.FrameTime.FrameNum;               % [声压]幅值平均
Struct_Case.FrameFre.Frame_Fre_All(:, 4) = 20 * log10(Struct_Case.FrameFre.Frame_Fre_All(:, 2) ./ Struct_Case.TimeDomainInf.Ref_Pressure);          % 转换为[声压级SPL]，因声压级不可直接加减

% 加窗的数据
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) = Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) / Struct_Case.FrameTime.FrameNum;
Struct_Case.FrameFre.Frame_Window_Fre_All(:, 4) = 20 * log10(Struct_Case.FrameFre.Frame_Window_Fre_All(:, 2) ./ Struct_Case.TimeDomainInf.Ref_Pressure);

end