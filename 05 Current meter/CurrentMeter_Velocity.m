%{
 *=======================================================================================
 *========================================【M FILE】=====================================
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       CurrentMeter_Velocity.m
 * @Brief:      1. 筛选出置信度较高的采样数据
 *              2. 计算平均速度
 *
 * @Author:     Haiger
 * @date:       2023.06.06
 *=======================================================================================
%}

clc;
clear;

Struct_02_V_1 = Fun_MeanVelCalcu('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\02_V_1.txt');
Struct_03_V_2 = Fun_MeanVelCalcu('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\03_V_2.txt');
Struct_04_V_3 = Fun_MeanVelCalcu('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\04_V_3.txt');
Struct_05_V_4 = Fun_MeanVelCalcu('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\05_V_4.txt');
Struct_06_V_5 = Fun_MeanVelCalcu('H:\02 Experiment_Project\01 SUBOFF_Experiment\02 Code\02 Data\05 Current meter\06_V_5.txt');
