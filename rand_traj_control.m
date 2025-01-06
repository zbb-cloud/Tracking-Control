clear all
close all
clc

addpath('./tools/')

% load training data
load('./save_file/all_traj_06282022.mat')
%% 设置轨迹类型集合
traj_set = ["infty", "circle", "astroid", "fermat", ...
    "lissajous", "talbot", "heart", "lorenz", "chua", "rossler", ...
    "sprott_1", "sprott_4", "mg17", "mg30", "epitrochoid"];
%随机打乱轨迹类型的顺序
order = randperm(length(traj_set));
traj_set= traj_set(order);
%设置参数和初始值
%设置 plot_val_and_update 标志为 1（绘制验证和更新）。
plot_val_and_update = 1;
disturbance = 0.1;
measurement_noise = 0.1;
plot_movie = 0;
bridge_type = 'cubic';
failure.type = 'none';
blur.blur = 0;
idx=1;
val_length_all=150000;
%主循环 - 遍历每个轨迹类型
for ii = 1:length(traj_set)
    rng('shuffle')
    %设置当前的轨迹类型。
    traj_type = traj_set(ii);
    %设置验证长度
    time_infor.val_length=val_length_all;
%如果是第一个轨迹类型，设置 save_rend 为 0，否则设置为 1
    if ii == 1
        save_rend=0;
    else
        save_rend=1;
    end
%如果变量 traj_frequency 存在，根据轨迹类型设置不同的频率。
    if exist('traj_frequency','var') == 1
        if strcmp(traj_type, 'lorenz') == 1
            traj_frequency = 100;
        elseif strcmp(traj_type, 'cirlce') == 1
            traj_frequency = 150;
        else
            traj_frequency = 75;
        end
    end
    %调用 val_and_update 函数进行验证和更新。
    val_and_update;
    %增加索引
    idx = idx+1;
    %如果是第一个轨迹类型，设置变量 aaa 为 1
    if ii == 1
        aaa = 1;
    end
end
%保存结果
%再次设置验证长度。
time_infor.val_length=val_length_all;
%获取当前日期，并以“mmddyyyy”格式存储在变量 time_today 中。
time_today = datestr(now, 'mmddyyyy');
% save(['./save_data/15traj_', time_today, '_', num2str(randi(999)), '.mat'], "val_length_all", "save_all_traj", "traj_set")









































