clear all
close all
clc

addpath('./tools/')

load('./save_file/all_traj_06282022.mat')

% 选择参考轨迹类型
% traj_type = 'lorenz';
traj_type = 'circle';
% traj_type = 'mg17';
% traj_type = 'infty';
% traj_type = 'fermat';
% traj_type = 'astroid';
% traj_type = 'heart';
% traj_type = 'epitrochoid';
% traj_type = 'lissajous';
% traj_type = 'talbot';
% traj_type = 'chua';
% traj_type = 'rossler';
% traj_type = 'sprott_1';
% traj_type = 'sprott_4';
% traj_type = 'mg30';
% traj_type = 'lorenz96';

% traj_frequency = 75;
%设置参数和初始值
time_infor.val_length=200000;
bridge_type = 'cubic';
failure.type = 'none';
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;
blur.blur = 0;

save_rend = 0;
idx = 0;

plot_val_and_update = 1;

% 调用 val_and_update 函数，让训练好的机器跟随给定的参考轨迹。
val_and_update



















