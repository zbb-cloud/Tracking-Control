clear all
close all
clc

addpath('./tools/')

%% test for network size, training length, 
% reset time and noise level
% please record the rmse and running time

% network_set = round(linspace(20, 500, 10));
% training_length_set = round(linspace(20000, 200000, 10));
%定义网络大小集合，范围从20到250，共10个值。
network_set = round(exp(linspace(log(20), log(250), 10)));
%定义训练长度集合，范围从2000到150000，共10个值。
training_length_set = round(exp(linspace(log(2000), log(150000), 10)));

% network_set = fliplr(network_set);
% training_length_set = fliplr(training_length_set);
%定义重置时间集合，范围从10到150，共10个值。
reset_t_set = round(linspace(10, 150, 10));
%定义噪声水平集合，范围从 10^-3到10^0，共0个值。
noise_level_set = 10 .^ linspace(-3, 0, 10);
%获取当前日期，并以“mmddyyyy”格式存储在变量 time_today 中。
time_today = datestr(now, 'mmddyyyy');


%% 初始化测试参数
%设置重置时间为80
reset_t = 80;
%设置噪声水平为0.02
noise_level = 2.0 * 10 ^ (-2);
%设置偏置值为2.0
bias = 2.0;

% delete(gcp('nocreate'))
% parpool('local',10)
%设置迭代次数为50
iteration = 50;
%初始化存储不同轨迹类型的RMSE矩阵
rmse_set_lorenz = zeros(length(network_set), length(training_length_set), iteration);
rmse_set_circle = zeros(length(network_set), length(training_length_set), iteration);
rmse_set_mg17 = zeros(length(network_set), length(training_length_set), iteration);
rmse_set_infty = zeros(length(network_set), length(training_length_set), iteration);
time_set = zeros(length(network_set), length(training_length_set), iteration);
%主循环 - 遍历网络大小和训练长度
for ns = 1:length(network_set)
    %获取当前网络大小
    n = network_set(ns);
    %遍历训练长度集合
    for tls = 1:length(training_length_set)
        %获取当前训练长度
        train_t = training_length_set(tls);
        %初始化各个轨迹类型的RMSE和时间矩阵
        rmse_parfor_set_lorenz = zeros(1, iteration);
        rmse_parfor_set_circle = zeros(1, iteration);
        rmse_parfor_set_mg17 = zeros(1, iteration);
        rmse_parfor_set_infty = zeros(1, iteration);
        
        time_parfor_set = zeros(1, iteration);
        %进行多次迭代
        for repeat_i = 1:iteration
        %调用 func_train_val 函数，进行训练和验证，返回不同轨迹类型的RMSE和运行时间
            [rmse_l, rmse_c, rmse_m, rmse_i, t_repeat_i] = func_train_val(n, train_t, reset_t, noise_level, bias);
            %存储 lorenz 轨迹类型的RMSE
            rmse_parfor_set_lorenz(repeat_i) = rmse_l;
            %存储 circle 轨迹类型的RMSE
            rmse_parfor_set_circle(repeat_i) = rmse_c;
            %存储 mg17 轨迹类型的RMSE。
            rmse_parfor_set_mg17(repeat_i) = rmse_m;
            %存储 infty 轨迹类型的RMSE。
            rmse_parfor_set_infty(repeat_i) = rmse_i;
            %存储运行时间
            time_parfor_set(repeat_i) = t_repeat_i;
        end
        %将每次迭代的结果存储到相应的矩阵中
        rmse_set_lorenz(ns, tls, :) = rmse_parfor_set_lorenz;
        rmse_set_circle(ns, tls, :) = rmse_parfor_set_circle;
        rmse_set_mg17(ns, tls, :) = rmse_parfor_set_mg17;
        rmse_set_infty(ns, tls, :) = rmse_parfor_set_infty;
        
        time_set(ns, tls, :) = time_parfor_set;
    end
end
%保存结果
save_success_rate.reset_t = reset_t;
save_success_rate.noise_level = noise_level;
save_success_rate.network_set = network_set;
save_success_rate.training_length_set = training_length_set;
save_success_rate.rmse_set_lorenz = rmse_set_lorenz;
save_success_rate.rmse_set_circle = rmse_set_circle;
save_success_rate.rmse_set_mg17 = rmse_set_mg17;
save_success_rate.rmse_set_infty = rmse_set_infty;
save_success_rate.time_set = time_set;

save(['save_data/save_success_rate_nt_', time_today, '_' num2str(randi(999)) '.mat'], 'save_success_rate')




















































