%{
 *------------------------------------------------------------------------------------------
 *---------------------------------------【Fun FILE】---------------------------------------
 * Copyright 流体力学与声学技术实验室
 * ALL right reserved.See COPYRIGHT for detailed Information.
 *
 * @File:       Fun_MultiPlot.m
 * @Brief:      选择不同类型的图像绘制
 * 
 * @Input:      Plot_Selection                  绘图函数选择                          N×1数组
 *                  1   plot                    坐标轴为线性
 *                  2   semilogx                横坐标为对数
 *              X_Series                        横轴数据                              N×1double
 *              Y_Series                        纵轴数据                              N×1double
 *              XLabel                          横轴标签                              字符串
 *              YLabel                          纵轴标签                              字符串
 *              Title                           图谱标题                              字符串
 *              Grid_Option                     判断是否加载网格线                    bool
 *                  true    grid on             加载网格线
 *                  flase   grid off            不加载网格线
 * 
 * @Output:     
 * 
 * @Author:     Haiger
 * @date:       2023.05.09
 *------------------------------------------------------------------------------------------
%}

function [] = Fun_MultiPlot(Plot_Selection, X_Series, Y_Series, XLabel, YLabel, Title, Grid_Option)
switch Plot_Selection
    case 1
        plot(X_Series, Y_Series);
        xlabel(XLabel);
        ylabel(YLabel);
        title(Title);
        if Grid_Option
            grid on;
        end
    case 2
        semilogx(X_Series, Y_Series);
        xlabel(XLabel);
        ylabel(YLabel);
        title(Title);
        if Grid_Option
            grid on;
        end
end