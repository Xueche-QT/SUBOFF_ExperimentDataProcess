%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_FrameCutMove.m
 * @Brief:      1. 【加窗】对导入的数据[加窗]，默认为汉宁窗
 *              2. 【存储】生成对应的结构体存储信息
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.03
 *------------------------------------------------------------------------------------------
%}

% 加窗[FrameTime]

function Struct_Case = Fun_Window(Struct_Case)

Struct_Case.FrameTime.FramePointNum = round(height(Struct_Case.FrameTime.Frame_1(:, 2)));
Struct_Case.FrameTime.FrameWindow = hann(Struct_Case.FrameTime.FramePointNum);
for i = 1 : Struct_Case.FrameTime.FrameNum
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 1) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 1);
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 2) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 2) .* Struct_Case.FrameTime.FrameWindow;
    Struct_Case.FrameTime.(['Frame_Window_' num2str(i)])(:, 3) = Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 3) .* Struct_Case.FrameTime.FrameWindow;                               % 对第3列[声压级]数据[加窗]
end

end