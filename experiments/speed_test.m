%这段代码旨在研究双臂机器人控制系统在不同频率下的性能，特别是通过计算均方根误差（RMSE）来评估预测数据和控制数据之间的差异。
% clear all
% close all
% clc

addpath('./tools/')

%%

load('./save_file/all_traj_06282022.mat')

time_today = datestr(now, 'mmddyyyy');
%设置参数和初始值
%设置 plot_val_and_update 标志为 0（不绘制验证和更新）
plot_val_and_update = 0;

blur.blur = 0;
plot_movie = 0;
traj_type = 'infty';

if exist('traj_type','var') == 0
    traj_type = 'infty';
end

traj_type = 'infty';

failure.type = 'all';
failure.amplitude = 0.1;
failure.amplitude_2 = 0.1;

bridge_type = 'cubic';

time_infor.val_length=250000;
val_length_rm = time_infor.val_length;

rmse_start_time = round(val_length_rm * 3/5);
rmse_end_time = time_infor.val_length - 100;
%设置频率集合和初始化RMSE矩阵
if strcmp(traj_type, 'circle') == 1
    frequency_set = round(linspace(10, 500, 15));
elseif strcmp(traj_type, 'infty') == 1
    frequency_set = round(linspace(10, 500, 15) / 2);
end
%迭代
iteration = 50;
failure.type = 'none';
%初始化一个矩阵，用于存储每个频率和迭代次数的 RMSE 值。
rmse_set = zeros(length(frequency_set), iteration);

idx=1;
%遍历每个频率值。
for f_idx = 1:length(frequency_set)
%初始化一个数组，用于存储当前频率的 RMSE 值。
    rmse_parfor_set = zeros(1, iteration);
    %进行多次迭代。
    for repeat_i = 1:iteration
    %设置验证长度和轨迹频率
        save_rend=0;
        load('./save_file/all_traj_06282022.mat')
        time_infor.val_length = val_length_rm;
        traj_frequency = frequency_set(f_idx);
%调用 val_and_update 函数进行验证和更新
        val_and_update;
%计算当前迭代的 RMSE 值，并存储在数组中
        rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);
        aaa = 1;
    end
    %对 RMSE 值进行排序，并存储在矩阵中。
    rmse_parfor_set = sort(rmse_parfor_set);
    rmse_set(f_idx, :) = rmse_parfor_set;
end


save_speed_iter.traj_type = traj_type;

save_speed_iter.(['frequency_set', num2str(idx)]) = frequency_set;
save_speed_iter.(['rmse_set', num2str(idx)]) = rmse_set;

save(['save_data/save_speed_iter_' traj_type, '_' time_today, '_' num2str(randi(999)) '.mat'], "save_speed_iter")
































