%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_FrameCutMove.m
 * @Brief:      1. 【分帧】将导入的数据[分帧]，切片为长度为 t (默认为1s)的帧
 *              2. 【帧移】每帧之间重合部分的长度为 ∆t (默认为0.2s)
 *              3. 【存储】生成对应的结构体存储信息
 * 
 * @Input:      Struct_Case                     工况对应的结构体                   Struct
 *              FrameLenth                      帧长度(s)                          double
 *              FrameShift                      帧移(s)                            double
 *              FrameNum                        帧数目                             int
 * 
 * @Output:     Struct_Case                     工况对应的结构体                   Struct
 * 
 * @Author:     Haiger
 * @date:       2023.06.03
 *------------------------------------------------------------------------------------------
%}

% 分帧[FrameTime]

function Struct_Case = Fun_FrameCutMove(Struct_Case, FrameLenth, FrameShift, FrameNum)

Struct_Case.FrameTime.FrameLenth = FrameLenth;                                      % [帧长度(s)]
Struct_Case.FrameTime.FrameShift = FrameShift;                                      % [帧移(s)]
Struct_Case.FrameTime.FrameNum = FrameNum;                                          % [帧数目]
for i = 1 : Struct_Case.FrameTime.FrameNum                                          % 迭代进行分帧
    LowerIndex = round((Struct_Case.FrameTime.FrameLenth - Struct_Case.FrameTime.FrameShift) * (i - 1) / Struct_Case.TimeDomainInf.SamplingInterval + 1);                               % [帧段]下界
    UpperIndex = round(((Struct_Case.FrameTime.FrameLenth - Struct_Case.FrameTime.FrameShift) * i + Struct_Case.FrameTime.FrameShift) / Struct_Case.TimeDomainInf.SamplingInterval);    % [帧段]上界
    Struct_Case.FrameTime.(['Frame_' num2str(i)]) = Struct_Case.DataTable{ LowerIndex : UpperIndex, :};                              % [帧段]时间列、声压列
    Struct_Case.FrameTime.(['Frame_' num2str(i)])(:, 3) = Struct_Case.TimeDomainInf.SPL(LowerIndex : UpperIndex, :);                 % [帧段]声压级列
end

end