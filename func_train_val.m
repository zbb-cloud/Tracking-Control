%这段代码定义了一个名为 func_train_val 的函数，用于训练和验证双臂机器人控制系统的性能。
%定义函数 func_train_val，接收输入参数 n（网络大小），定义函数 func_train_val，接收输入参数 n（网络大小）、train_t（训练时间）、reset_t（重置时间）、noise_level（噪声水平）和 bias（偏置）。
%返回值包括不同轨迹类型的均方根误差（RMSE）和训练时间
function [rmse_l, rmse_c, rmse_m, rmse_i, t] = func_train_val(n, train_t, reset_t, noise_level, bias)
%初始化参数
dt=0.01;
input_infor={'xy', 'qdt'};

dim_in=length(input_infor) * 4;
dim_out=2;

m1=1;m2=1;
l1=0.5;l2=0.5;
lc1=0.25;lc2=0.25;
I1=0.03;I2=0.03;
%将物理属性存储在 properties 数组中
properties=[m1, m2, l1, l2, lc1, lc2, I1, I2];

val_t=500;
% 
% %function [rmse_l, rmse_c, rmse_m, rmse_i, t] = func_train_val(n, train_t, reset_t, noise_level, bias) dt=0.01; input_infor={'xy', 'qdt'}; dim_in=length(input_infor) * 4; dim_out=2; m1=1;m2=1; l1=0.5;l2=0.5; lc1=0.25;lc2=0.25; I1=0.03;I2=0.03; properties=[m1, m2, l1, l2, lc1, lc2, I1, I2]; val_t=500; % prepare for the reservoir computing, the hyperparameters are given by the % Bayesian optimization. hyperpara_set = [0.756250, 0.756250, 0.843750, -3.125, 106.71875, bias]; eig_rho = hyperpara_set(1); W_in_a = hyperpara_set(2); alpha = hyperpara_set(3); beta = 10^hyperpara_set(4); k = round( hyperpara_set(5)/200*n); kb = hyperpara_set(6); W_in = W_in_a*(2*rand(n,dim_in)-1); res_net=sprandsym(n,k/n); eig_D=eigs(res_net,1); res_net=(eig_rho/(abs(eig_D))).*res_net; res_net=full(res_net); section_len=round(reset_t/dt); washup_length=round(1002/dt); train_length=round(train_t/dt)+round(5/dt); % 50000 val_length=round(val_t/dt); % 300 time_length = train_length + 2 * val_length + 3 * washup_length + 100; res_infor=struct('W_in', W_in, 'res_net', res_net, 'alpha', alpha, 'kb', kb, 'beta', beta, 'n', n); time_infor=struct('section_len', section_len, 'washup_length', washup_length, ... 'train_length', train_length, 'val_length', val_length, 'time_length', time_length); % generate training and validation data [xy, q, qdt, q2dt, tau] = robot_data_generator(time_infor, noise_level, dt, properties); xy=xy(washup_length:end, :); q=q(washup_length:end, :); qdt=qdt(washup_length:end, :); q2dt=q2dt(washup_length:end, :); tau=tau(washup_length:end, :); data_reservoir = struct('xy', xy, 'q', q, 'qdt', qdt, 'q2dt', q2dt, 'tau', tau); clearvars q qdt q2dt tau tic; [Wout, r_end] = func_reservoir_train(data_reservoir, time_infor, input_infor, res_infor, dim_in, dim_out); t = toc; clearvars data_reservoir % after training, we test on four trajectories: lorenz, circle, mg17 and % eight symbol. % lorenz disturbance = 0.00; measurement_noise = 0.00; plot_movie = 0; time_infor.val_length=150000; traj_type = 'lorenz'; bridge_type = 'cubic'; save_rend=0; idx=1; if exist('traj_frequency','var') == 0 traj_frequency = 75; end blur.blur = 0; failure.type = 'none'; if save_rend == 0 start_info.q=0; start_info.qdt=0; start_info.q2dt=0; start_info.tau=0; end [control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,... bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ... Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency); % update data_pred=output_infor.data_pred; data_control=control_infor.data_control; rmse_start_time = round(time_infor.val_length * 3/5); rmse_end_time = time_infor.val_length - 100; rmse_l = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time); % circle disturbance = 0.00; measurement_noise = 0.00; plot_movie = 0; time_infor.val_length=150000; traj_type = 'circle'; bridge_type = 'cubic'; save_rend=0; idx=1; blur.blur = 0; failure.type = 'none'; if save_rend == 0 start_info.q=0; start_info.qdt=0; start_info.q2dt=0; start_info.tau=0; end [control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,... bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ... Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency); % update data_pred=output_infor.data_pred; data_control=control_infor.data_control; rmse_start_time = round(time_infor.val_length * 3/5); rmse_end_time = time_infor.val_length - 100; rmse_c = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time); % mg17 disturbance = 0.00; measurement_noise = 0.00; plot_movie = 0; time_infor.val_length=150000; traj_type = 'mg17'; bridge_type = 'cubic'; save_rend=0; idx=1; blur.blur = 0; failure.type = 'none'; if save_rend == 0 start_info.q=0; start_info.qdt=0; start_info.q2dt=0; start_info.tau=0; end [control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,... bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ... Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency); % update data_pred=output_infor.data_pred; data_control=control_infor.data_control; rmse_start_time = round(time_infor.val_length * 3/5); rmse_end_time = time_infor.val_length - 100; rmse_m = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time); % infty disturbance = 0.00; measurement_noise = 0.00; plot_movie = 0; time_infor.val_length=150000; traj_type = 'infty'; bridge_type = 'cubic'; save_rend=0; idx=1; blur.blur = 0; failure.type = 'none'; if save_rend == 0 start_info.q=0; start_info.qdt=0; start_info.q2dt=0; start_info.tau=0; end [control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,... bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ... Wout, r_end, dt, plot_movie, save_rend,failure,blur,traj_frequency); % update data_pred=output_infor.data_pred; data_control=control_infor.data_control; rmse_start_time = round(time_infor.val_length * 3/5); rmse_end_time = time_infor.val_length - 100; rmse_i = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time); end 逐句分析代码
好的，让我们逐句分析 func_train_val 函数的代码。

函数定义和输入参数
matlab
function [rmse_l, rmse_c, rmse_m, rmse_i, t] = func_train_val(n, train_t, reset_t, noise_level, bias)
定义函数 func_train_val，接收输入参数 n（网络大小）、train_t（训练时间）、reset_t（重置时间）、noise_level（噪声水平）和 bias（偏置）。

返回值包括不同轨迹类型的均方根误差（RMSE）和训练时间。

初始化参数
matlab
dt = 0.01;
input_infor = {'xy', 'qdt'};

dim_in = length(input_infor) * 4;
dim_out = 2;

m1 = 1; m2 = 1;
l1 = 0.5; l2 = 0.5;
lc1 = 0.25; lc2 = 0.25;
I1 = 0.03; I2 = 0.03;
properties = [m1, m2, l1, l2, lc1, lc2, I1, I2];

val_t = 500;
dt = 0.01: 设置时间步长为 0.01。

input_infor = {'xy', 'qdt'}: 定义输入信息，包括坐标 xy 和速度 qdt。

dim_in = length(input_infor) * 4 dim_out = 2: 计算输入维度和输出维度。

m1 = 1; m2 = 1; l1 = 0.5; l2 = 0.5; lc1 = 0.25; lc2 = 0.25; I1 = 0.03; I2 = 0.03: 定义双臂机器人的物理属性。

properties = [m1, m2, l1, l2, lc1, lc2, I1, I2]: 将物理属性存储在 properties 数组中。

val_t = 500: 设置验证时间为 500。

%准备储层计算和超参数
%从超参数集中提取各个参数，并分别赋值给 eig_rho、W_in_a、alpha、beta、k 和 kb。从超参数集中提取各个参数，并分别赋值给 eig_rho、W_in_a、alpha、beta、k 和 kb。
hyperpara_set = [0.756250, 0.756250, 0.843750, -3.125, 106.71875, bias];
eig_rho = hyperpara_set(1);
W_in_a = hyperpara_set(2);
alpha = hyperpara_set(3);
beta = 10^hyperpara_set(4);
k = round( hyperpara_set(5)/200*n);
kb = hyperpara_set(6);
%初始化输入权重矩阵 W_in。
W_in = W_in_a*(2*rand(n,dim_in)-1);
%生成稀疏对称随机矩阵 res_net。
res_net=sprandsym(n,k/n);
%计算 res_net 的最大特征值。
eig_D=eigs(res_net,1);
%res_net*: 调整 res_net 以满足特征值范围。
res_net=(eig_rho/(abs(eig_D))).*res_net;
%将稀疏矩阵 res_net 转换为全矩阵
res_net=full(res_net);
%计算不同时间段的长度
section_len=round(reset_t/dt); 
washup_length=round(1002/dt);
train_length=round(train_t/dt)+round(5/dt); % 50000
val_length=round(val_t/dt); % 300
time_length = train_length + 2 * val_length + 3 * washup_length + 100;
%将储层信息存储在结构体 res_infor 中。
res_infor=struct('W_in', W_in, 'res_net', res_net, 'alpha', alpha, 'kb', kb, 'beta', beta, 'n', n);
%将时间信息存储在结构体 time_infor 中。
time_infor=struct('section_len', section_len, 'washup_length', washup_length, ...
    'train_length', train_length, 'val_length', val_length, 'time_length', time_length);

% 生成训练和验证数据
[xy, q, qdt, q2dt, tau] = robot_data_generator(time_infor, noise_level, dt, properties);
xy=xy(washup_length:end, :);
q=q(washup_length:end, :);
qdt=qdt(washup_length:end, :);
q2dt=q2dt(washup_length:end, :);
tau=tau(washup_length:end, :);
data_reservoir = struct('xy', xy, 'q', q, 'qdt', qdt, 'q2dt', q2dt, 'tau', tau);

clearvars q qdt q2dt tau

tic;
[Wout, r_end] = func_reservoir_train(data_reservoir, time_infor, input_infor, res_infor, dim_in, dim_out);
t = toc;

clearvars data_reservoir

% after training, we test on four trajectories: lorenz, circle, mg17 and
% eight symbol.

% lorenz
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;

time_infor.val_length=150000;

traj_type = 'lorenz';
bridge_type = 'cubic';
save_rend=0;
idx=1;

if exist('traj_frequency','var') == 0
    traj_frequency = 75;
end

blur.blur = 0;
failure.type = 'none';

if save_rend == 0
    start_info.q=0;
    start_info.qdt=0;
    start_info.q2dt=0;
    start_info.tau=0;
end

[control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,...
    bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ...
    Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency);

% update
data_pred=output_infor.data_pred;
data_control=control_infor.data_control;

rmse_start_time = round(time_infor.val_length * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_l = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);


% circle
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;

time_infor.val_length=150000;

traj_type = 'circle';
bridge_type = 'cubic';
save_rend=0;
idx=1;

blur.blur = 0;
failure.type = 'none';

if save_rend == 0
    start_info.q=0;
    start_info.qdt=0;
    start_info.q2dt=0;
    start_info.tau=0;
end

[control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,...
    bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ...
    Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency);

% update
data_pred=output_infor.data_pred;
data_control=control_infor.data_control;

rmse_start_time = round(time_infor.val_length * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_c = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);


% mg17
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;

time_infor.val_length=150000;

traj_type = 'mg17';
bridge_type = 'cubic';
save_rend=0;
idx=1;

blur.blur = 0;
failure.type = 'none';

if save_rend == 0
    start_info.q=0;
    start_info.qdt=0;
    start_info.q2dt=0;
    start_info.tau=0;
end

[control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,...
    bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ...
    Wout, r_end, dt, plot_movie, save_rend,failure,blur, traj_frequency);

% update
data_pred=output_infor.data_pred;
data_control=control_infor.data_control;

rmse_start_time = round(time_infor.val_length * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_m = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);

% infty
disturbance = 0.00;
measurement_noise = 0.00;
plot_movie = 0;

time_infor.val_length=150000;

traj_type = 'infty';
bridge_type = 'cubic';
save_rend=0;
idx=1;

blur.blur = 0;
failure.type = 'none';

if save_rend == 0
    start_info.q=0;
    start_info.qdt=0;
    start_info.q2dt=0;
    start_info.tau=0;
end

[control_infor, output_infor, time_infor, r_end] = func_reservoir_validate(traj_type,...
    bridge_type, time_infor, input_infor, res_infor, start_info, properties, dim_in, dim_out, ...
    Wout, r_end, dt, plot_movie, save_rend,failure,blur,traj_frequency);

% update
data_pred=output_infor.data_pred;
data_control=control_infor.data_control;

rmse_start_time = round(time_infor.val_length * 3/5);
rmse_end_time = time_infor.val_length - 100;

rmse_i = func_rmse(data_pred, data_control, rmse_start_time, rmse_end_time);


end


























