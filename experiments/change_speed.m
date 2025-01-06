clear all
close all
clc

%% change the frequency of infty symbol

addpath('./tools/')

time_today = datestr(now, 'mmddyyyy');

% traj_frequency_set = round(exp(linspace(log(1), log(500), 10)));
% 设计轨迹频率，迭代次数，验证长度，扰动值，测量噪声，绘制标志，轨迹类型
% 桥接类型，故障类型，模糊类型
traj_frequency_set = round(linspace(1, 400, 20));
iteration = 50;
val_length_all = 300000;
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;
traj_type = 'infty';
bridge_type = 'cubic';
failure.type = 'none';
blur.blur = 0;
%设置RMSE计算窗口开始时间结束时间，初始化RMSE矩阵
rmse_start_time = round(val_length_all * 3/5);
rmse_end_time = val_length_all - 100;
rmse_frequency_set = zeros(length(traj_frequency_set), iteration);
% 主循环，遍历每个频率
for tfs = 1:length(traj_frequency_set)
    traj_frequency = traj_frequency_set(tfs);
    rmse_repeat_set = zeros(1, iteration);
    %内循环，多次迭代
    for repeat_i = 1:iteration
        load('./save_file/all_traj_06282022.mat')
        %随机数生成
        rng('shuffle')
        save_rend=0;
        idx=1;
        time_infor.val_length=val_length_all;
      %调用函数
        val_and_update; 

        rmse_repeat_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);

        bb=1;
    end
    %排序和储存RMSE值
    rmse_repeat_set = sort(rmse_repeat_set);
    rmse_frequency_set(tfs, :) = rmse_repeat_set;
    xxx = ['traj frequency:', traj_frequency];
    disp(xxx)
    aa = 1;
end

%保存结果
save_frequency_iter.traj_type = traj_type;
save_frequency_iter.val_length = val_length_all;
save_frequency_iter.traj_frequency_set = traj_frequency_set;
save_frequency_iter.rmse_frequency_set = rmse_frequency_set;
save(['save_data/save_frequency_iter_', time_today, '_' num2str(randi(999)) '.mat'], "save_frequency_iter")

































