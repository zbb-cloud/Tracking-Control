%这段代码的主要目的是评估双臂机器人控制系统在不同参数 l1 和 l2 下的性能。
 clear all
 close all
 clc

addpath('./tools/')

%%

load('./save_file/all_traj_06282022.mat')

 time_today = datestr(now, 'mmddyyyy');
%设置参数和初始值
%设置 plot_val_and_update 标志为 0（不绘制验证和更新）
plot_val_and_update = 0;
blur.blur = 0;
plot_movie = 0;
% traj_type = 'lorenz';
%如果 traj_type 变量不存在，则将 traj_type 设置为 'infty'
if exist('traj_type','var') == 0
    traj_type = 'infty';
end
bridge_type = 'cubic';
time_infor.val_length=250000;
val_length_rm = time_infor.val_length;
rmse_start_time = round(val_length_rm * 3/5);
rmse_end_time = time_infor.val_length - 100;
%根据轨迹类型设置轨迹频率。
if strcmp(traj_type, 'circle') == 1
    traj_frequency = 150;
elseif strcmp(traj_type, 'infty') == 1
    traj_frequency = 75;
else
    traj_frequency = 75;
end
%定义参数 l1 和 l2 的集合，范围从0.5到0.55，共10个值。
l1_set = linspace(0.5, 0.55, 10);
l2_set = linspace(0.5, 0.55, 10);
iteration = 50;
failure.type = 'all';
failure.amplitude = 0.1;
failure.amplitude_2 = 0.1;
% length
uncertain_type = 'l';

rmse_set = zeros(length(l1_set), length(l2_set), iteration);

idx=2;
%主循环 - 遍历参数l1和l2集合并进行验证和更新
%遍历参数l1和l2集合
for l1_idx = 1:length(l1_set)
    for l2_idx = 1:length(l2_set)
        rmse_parfor_set = zeros(1, iteration);
        for repeat_i = 1:iteration
           %设置验证长度和参数 properties
            save_rend=0;
            load('./save_file/all_traj_06282022.mat')
            time_infor.val_length = val_length_rm;
            properties(3:4) = [l1_set(l1_idx), l2_set(l2_idx)];
            %并调用 val_and_update 函数进行验证和更新
            val_and_update;
            %计算当前迭代的 RMSE 值，并存储在数组中
            rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);
            aaa = 1;
        end
        %对 RMSE 值进行排序，并存储在矩阵中
        rmse_parfor_set = sort(rmse_parfor_set);
        rmse_set(l1_idx, l2_idx, :) = rmse_parfor_set;
    end
end
%保存结果
save_uncertain_iter.traj_type = traj_type;

save_uncertain_iter.(['type', num2str(idx)]) = uncertain_type;
save_uncertain_iter.(['l1_set', num2str(idx)]) = l1_set;
save_uncertain_iter.(['l2_set', num2str(idx)]) = l2_set;
save_uncertain_iter.(['rmse_set', num2str(idx)]) = rmse_set;

save(['save_data/save_uncertain_iter_' traj_type, '_' time_today, '_' num2str(randi(999)) '.mat'], "save_uncertain_iter")



%% 绘制RMSE结果 
%从 save_uncertain_iter 结构体中提取 RMSE 数据
rmse_set_l = save_uncertain_iter.rmse_set2;
%计算沿第三维度的平均 RMSE 值
rmse_l_mean = mean(rmse_set_l, 3);

figure();
imagesc(l1_set, l2_set, rmse_l_mean);
colorbar

l1_set_plot = (l1_set - 0.5)/ 0.5;
l2_set_plot = (l2_set - 0.5)/ 0.5;
rmse_l_mean_flip = flip(rmse_l_mean, 1);

figure();
imagesc(l1_set_plot, l2_set_plot, rmse_l_mean_flip);
colorbar








