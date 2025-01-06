%这段代码的目的是评估一个双臂机器人控制系统在不同轨迹类型下的性能。
clear all
close all
clc

addpath('./tools/')

% 加载保存的轨迹数据文件，获取当前日期
load('./save_file/all_traj_06282022.mat')
time_today = datestr(now, 'mmddyyyy');
%设置参数和初始值
plot_movie = 0;
if exist('traj_type','var') == 0
    traj_type = 'infty';
end

traj_set = ["lorenz", "circle", "mg17", "infty", "astroid", "fermat", ...
    "lissajous", "talbot", "heart", "chua", "rossler", ...
    "sprott_1", "sprott_4", "mg30", "epitrochoid"];
% traj_set = ["lorenz"];
iteration = 100;

bridge_type = 'cubic';
time_infor.val_length=250000;
val_length_rm = time_infor.val_length;

failure.type = 'none';
blur.last_time = 1000;
blur.recover_time = time_infor.val_length;
blur.blur = 0;

failure.type = 'all';
failure.amplitude = 0.1;
failure.amplitude_2 = 0.1;

rmse_start_time = round(val_length_rm * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_set = zeros(length(traj_set), iteration);

idx=1;
%主循环 - 遍历每个轨迹类型
for traj_id = 1:length(traj_set)
%设置当前的轨迹类型。
    traj_type = traj_set(traj_id);
%根据轨迹类型设置轨迹频率。
    if strcmp(traj_type, 'circle') == 1
        traj_frequency = 150;
    elseif strcmp(traj_type, 'infty') == 1
        traj_frequency = 75;
    end
%初始化一个数组，用于存储当前轨迹类型的 RMSE 值。
    rmse_parfor_set = zeros(1, iteration);
    %进行多次迭代。
    for repeat_i = 1:iteration
        load('./save_file/all_traj_06282022.mat')
        %设置验证长度，保存渲染标志为 0，调用 val_and_update 函数进行验证和更新。
        time_infor.val_length = val_length_rm;
        save_rend=0;
        val_and_update;
        %计算当前迭代的 RMSE值，并存储在数组中。
        rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);
        aaa = 1;
    end
    %对 RMSE 值进行排序，并存储在矩阵中。
    rmse_parfor_set = sort(rmse_parfor_set);
    rmse_set(traj_id, :) = rmse_parfor_set;
end
%存RMSE结果
save_success.rmse_set = rmse_set;
save_success.val_length = time_infor.val_length;
save_success.traj_set = traj_set;

% save(['./save_data/save_saferegion_success_rate_noise_' time_today, '_' num2str(randi(999)) '.mat'], "save_success")

%%
% load('./save_data/save_normal_success_rate_08022022_92.mat')

% rmse_set = save_success.rmse_set;
%clear all close all clc addpath('./tools/') % load training data load('./save_file/all_traj_06282022.mat') time_today = datestr(now, 'mmddyyyy'); plot_movie = 0; if exist('traj_type','var') == 0 traj_type = 'infty'; end traj_set = ["lorenz", "circle", "mg17", "infty", "astroid", "fermat", ... "lissajous", "talbot", "heart", "chua", "rossler", ... "sprott_1", "sprott_4", "mg30", "epitrochoid"]; % traj_set = ["lorenz"]; iteration = 100; bridge_type = 'cubic'; time_infor.val_length=250000; val_length_rm = time_infor.val_length; failure.type = 'none'; blur.last_time = 1000; blur.recover_time = time_infor.val_length; blur.blur = 0; failure.type = 'all'; failure.amplitude = 0.1; failure.amplitude_2 = 0.1; rmse_start_time = round(val_length_rm * 3/5); rmse_end_time = time_infor.val_length - 100; rmse_set = zeros(length(traj_set), iteration); idx=1; for traj_id = 1:length(traj_set) traj_type = traj_set(traj_id); if strcmp(traj_type, 'circle') == 1 traj_frequency = 150; elseif strcmp(traj_type, 'infty') == 1 traj_frequency = 75; end rmse_parfor_set = zeros(1, iteration); for repeat_i = 1:iteration load('./save_file/all_traj_06282022.mat') time_infor.val_length = val_length_rm; save_rend=0; val_and_update; rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time); aaa = 1; end rmse_parfor_set = sort(rmse_parfor_set); rmse_set(traj_id, :) = rmse_parfor_set; end save_success.rmse_set = rmse_set; save_success.val_length = time_infor.val_length; save_success.traj_set = traj_set; % save(['./save_data/save_saferegion_success_rate_noise_' time_today, '_' num2str(randi(999)) '.mat'], "save_success") %% % load('./save_data/save_normal_success_rate_08022022_92.mat') % rmse_set = save_success.rmse_set; rmse_threshold = 0.18; rmse_logic = zeros(size(rmse_set)); for i = 1:size(rmse_set, 1) for j = 1:size(rmse_set, 2) if rmse_set(i, j) > rmse_threshold rmse_logic(i, j) = 0; else rmse_logic(i, j) = 1; end end end rmse_count = mean(rmse_logic, 2); figure() plot(rmse_count, 'o') 逐句分析代码
好的，让我们逐句分析这段代码。

清理和初始化
matlab
clear all
close all
clc

addpath('./tools/')
clear all: 清除工作区中的所有变量。

close all: 关闭所有打开的图形窗口。

clc: 清除命令窗口的内容。

addpath('./tools/'): 将 ./tools/ 目录添加到 MATLAB 路径中，以便访问该目录中的工具函数。

加载训练数据
matlab
% load training data
load('./save_file/all_traj_06282022.mat')
time_today = datestr(now, 'mmddyyyy');
load('./save_file/all_traj_06282022.mat'): 加载保存的轨迹数据文件。

time_today = datestr(now, 'mmddyyyy'): 获取当前日期，并以“mmddyyyy”格式存储在变量 time_today 中。

设置参数和初始值
matlab
plot_movie = 0;
if exist('traj_type', 'var') == 0
    traj_type = 'infty';
end

traj_set = ["lorenz", "circle", "mg17", "infty", "astroid", "fermat", ...
    "lissajous", "talbot", "heart", "chua", "rossler", ...
    "sprott_1", "sprott_4", "mg30", "epitrochoid"];
% traj_set = ["lorenz"];
iteration = 100;

bridge_type = 'cubic';
time_infor.val_length = 250000;
val_length_rm = time_infor.val_length;

failure.type = 'none';
blur.last_time = 1000;
blur.recover_time = time_infor.val_length;
blur.blur = 0;

failure.type = 'all';
failure.amplitude = 0.1;
failure.amplitude_2 = 0.1;

rmse_start_time = round(val_length_rm * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_set = zeros(length(traj_set), iteration);
plot_movie = 0: 设置 plot_movie 标志为 0（不绘制电影）。

if exist('traj_type', 'var') == 0 traj_type = 'infty'; end: 如果 traj_type 变量不存在，则将 traj_type 设置为 'infty'。

traj_set: 定义一组轨迹类型。

iteration = 100: 设置迭代次数为 100。

bridge_type = 'cubic': 设置桥接类型为 'cubic'。

time_infor.val_length = 250000: 设置验证长度为 250000。

val_length_rm = time_infor.val_length: 将验证长度赋值给 val_length_rm。

failure.type= 'none': 设置故障类型为 'none'。

blur.last_time = 1000: 设置模糊的持续时间为 1000。

blur.recover_time = time_infor.val_length: 设置模糊的恢复时间为验证长度。

blur.blur= 0: 设置模糊标志为 0（不模糊）。

failure.type= 'all': 设置故障类型为 'all'。

failure.amplitude= 0.1 failure.amplitude_2 = 0.1: 设置故障幅度为 0.1。

rmse_start_time = round(val_length_rm * 3/5) rmse_end_time = time_infor.val_length - 100: 设置 RMSE 计算窗口的开始时间和结束时间。

rmse_set = zeros(length(traj_set), iteration): 初始化一个矩阵，用于存储每个轨迹类型和迭代次数的 RMSE 值。

主循环 - 遍历每个轨迹类型
matlab
idx = 1;
for traj_id = 1:length(traj_set)
    traj_type = traj_set(traj_id);
    if strcmp(traj_type, 'circle') == 1
        traj_frequency = 150;
    elseif strcmp(traj_type, 'infty') == 1
        traj_frequency = 75;
    end

    rmse_parfor_set = zeros(1, iteration);
    for repeat_i = 1:iteration
        load('./save_file/all_traj_06282022.mat')
        time_infor.val_length = val_length_rm;
        save_rend = 0;
        val_and_update;
        rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);
        aaa = 1;
    end
    rmse_parfor_set = sort(rmse_parfor_set);
    rmse_set(traj_id, :) = rmse_parfor_set;
end
for traj_id = 1:length(traj_set): 遍历每个轨迹类型。

traj_type = traj_set(traj_id): 设置当前的轨迹类型。

if strcmp(traj_type, 'circle') == 1 traj_frequency = 150; elseif strcmp(traj_type, 'infty') == 1 traj_frequency = 75; end: 根据轨迹类型设置轨迹频率。

rmse_parfor_set = zeros(1, iteration): 初始化一个数组，用于存储当前轨迹类型的 RMSE 值。

for repeat_i = 1:iteration: 进行多次迭代。

load('./save_file/all_traj_06282022.mat'): 每次迭代重新加载数据文件。

time_infor.val_length = val_length_rm; save_rend = 0; val_and_update;: 设置验证长度，保存渲染标志为 0，调用 val_and_update 函数进行验证和更新。

rmse_parfor_set(repeat_i) = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);: 计算当前迭代的 RMSE 值，并存储在数组中。

rmse_parfor_set = sort(rmse_parfor_set); rmse_set(traj_id, :) = rmse_parfor_set;: 对 RMSE 值进行排序，并存储在矩阵中。

保存RMSE结果
matlab
save_success.rmse_set = rmse_set;
save_success.val_length = time_infor.val_length;
save_success.traj_set = traj_set;

% save(['./save_data/save_saferegion_success_rate_noise_' time_today, '_' num2str(randi(999)) '.mat'], "save_success")
save_success.rmse_set = rmse_set: 将 RMSE 矩阵存储在结构体 save_success 中。

save_success.val_length = time_infor.val_length: 将验证长度存储在结构体 save_success 中。

save_success.traj_set = traj_set: 将轨迹集合存储在结构体 save_success 中。

save（注释掉的部分）：将 save_success 结构体保存到文件中。

%计算RMSE逻辑并绘制结果
%设置 RMSE 阈值为 0.18。
rmse_threshold = 0.18;
%初始化 RMSE 逻辑矩阵。
rmse_logic = zeros(size(rmse_set));
%遍历 RMSE 矩阵。
for i = 1:size(rmse_set, 1)
    for j = 1:size(rmse_set, 2)
    %根据阈值设置逻辑矩阵值。
        if rmse_set(i, j) > rmse_threshold
            rmse_logic(i, j) = 0;
        else
            rmse_logic(i, j) = 1;
        end
    end
end
%计算每个轨迹类型的成功率。
rmse_count = mean(rmse_logic, 2);

figure()
plot(rmse_count, 'o')




















