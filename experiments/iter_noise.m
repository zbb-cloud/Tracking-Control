%最初的扰动值和测量噪声的设置
% disturbance = 1.00;
% measurement_noise = 0.00;

% try for only the first one and then only the second one
% then try them together
% then try uncertainty

time_today = datestr(now, 'mmddyyyy');

%% 仅扰动噪声
measurement_noise = 0.00;

% disturbance_set = exp(linspace(log(0.01), log(10), 20));
%1-5 20个值
disturbance_set = linspace(1, 5, 20);
%初始化误差集合
error_set = zeros(1, length(disturbance_set));
%计算rmse长处
rmse_length = 1000/dt;
%初始化权重向量
weight=zeros(rmse_length,1);
% alpha_w=0.2;
%设置权重向量
for ii=1:rmse_length
    weight(ii)=ii;
end
%对权重向量进行归一化
weight = weight/norm(weight, 1);
%扰动噪声测试
%对于每个扰动噪声值进行循环
for di_id = 1:length(disturbance_set)
%设置扰动噪声、绘图标志、轨迹类型、桥接类型和验证长度。
    disturbance = disturbance_set(di_id);
    plot_movie = 0;
    traj_type = 'infty';
    % traj_type = 'lorenz';
    % traj_type = 'mg17';
    % traj_type = 'mg30';
    bridge_type = 'cubic';

    time_infor.val_length=120000;
%调用func_reservoir_validate函数进行验证。
    [control_infor, output_infor, time_infor] = func_reservoir_validate(traj_type,...
        bridge_type, time_infor, input_infor, res_infor, properties, dim_in, dim_out, ...
        Wout, dt, plot_movie, disturbance, measurement_noise);
%获取预测数据和控制数据
    data_pred=output_infor.data_pred;
    q_pred=output_infor.q_pred;
    qdt_pred=output_infor.qdt_pred;
    q2dt_pred=output_infor.q2dt_pred;
    tau_pred=output_infor.tau_pred;

    q_control=control_infor.q_control;
    qdt_control=control_infor.qdt_control;
    q2dt_control=control_infor.q2dt_control;
    tau_control=control_infor.tau_control;
    % q_control_all=control_infor.q_control_all;
    % qdt_control_all=control_infor.qdt_control_all;
    data_control=control_infor.data_control;

    val_length=time_infor.val_length;

    %计算rmse，并将误差储存在error_set中
    error = abs(data_control(1:rmse_length, :) - data_pred(1:rmse_length, :));
    error = sum(weight.*mean(error.^2, 2));

    error_set(di_id) = error;
end
%处理和保存结果
%处理nan值，将其设置成误差集合中最大的5倍
nan_id = isnan(error_set);
error_set_plot = error_set;
error_set_plot(nan_id) = 5*max(error_set, [], 'omitnan');
%将数据储存在save_data 结构体中并保存到文件里
save_data.disturbance_set = disturbance_set;
save_data.disturbance_error_set = error_set;
save_data.disturbance_error_set_plot = error_set_plot;

save(['./save_data/disturbance_result_normscale_', time_today, '.mat'], "save_data")


%% for plot
%使用 plot 函数绘制扰动噪声与误差的关系图，设置 x 轴和 y 轴标签。
figure();
% hold on
% semilogx(disturbance_set, error_set_plot, 'o-')
plot(disturbance_set, error_set_plot, 'o-')
xlabel('gaussian disturbance, \sigma')
ylabel('error')


%% only measurement
disturbance = 0.00;
measurement_set = exp(linspace(log(0.01), log(10), 20));
% measurement_set = linspace(1, 5, 20);
error_set = zeros(1, length(measurement_set));

rmse_length = 1000/dt;
weight=zeros(rmse_length,1);
for ii=1:rmse_length
    weight(ii)=ii;
end
weight = weight/norm(weight, 1);

for di_id = 1:length(measurement_set)
    measurement_noise = measurement_set(di_id);
    plot_movie = 0;
    traj_type = 'infty';
    % traj_type = 'lorenz';
    % traj_type = 'mg17';
    % traj_type = 'mg30';
    bridge_type = 'cubic';

    time_infor.val_length=120000;

    [control_infor, output_infor, time_infor] = func_reservoir_validate(traj_type,...
        bridge_type, time_infor, input_infor, res_infor, properties, dim_in, dim_out, ...
        Wout, dt, plot_movie, disturbance, measurement_noise);

    data_pred=output_infor.data_pred;
    q_pred=output_infor.q_pred;
    qdt_pred=output_infor.qdt_pred;
    q2dt_pred=output_infor.q2dt_pred;
    tau_pred=output_infor.tau_pred;

    q_control=control_infor.q_control;
    qdt_control=control_infor.qdt_control;
    q2dt_control=control_infor.q2dt_control;
    tau_control=control_infor.tau_control;
    % q_control_all=control_infor.q_control_all;
    % qdt_control_all=control_infor.qdt_control_all;
    data_control=control_infor.data_control;

    val_length=time_infor.val_length;

    % calculate rmse
    error = abs(data_control(1:rmse_length, :) - data_pred(1:rmse_length, :));
    error = sum(weight.*mean(error.^2, 2));

    error_set(di_id) = error;
end

nan_id = isnan(error_set);
error_set_plot = error_set;
error_set_plot(nan_id) = 5*max(error_set, [], 'omitnan');

save_data.measurement_set = measurement_set;
save_data.measurement_error_set = error_set;
save_data.measurement_error_set_plot = error_set_plot;

save(['./save_data/measurement_result_logscale_', time_today, '.mat'], "save_data")

%% for plot
%加载先前保存的测量噪声结果文件。
load('./save_data/measurement_result_logscale_05202022.mat')
%将测量误差数据赋值给 error_set_plot 变量。
error_set_plot = save_data.measurement_error_set;

figure();
% hold on
%绘制测量噪声与误差的半对数关系图，使用圆圈标记和实线。
semilogx(measurement_set, error_set_plot, 'o-')
% plot(measurement_set, error_set_plot, 'o-')
xlabel('gaussian measurement noise, \sigma')
ylabel('error')



%% disturbance and measurement noise

disturbance_set = exp(linspace(log(0.01), log(10), 20));
measurement_set = exp(linspace(log(0.01), log(10), 20));

error_set = zeros(length(disturbance_set), length(measurement_set));

rmse_length = 1000/dt;
weight=zeros(rmse_length,1);
for ii=1:rmse_length
    weight(ii)=ii;
end
weight = weight/norm(weight, 1);
%执行联合测试，对每个扰动噪声和测量噪声值进行嵌套循环。
for di_id = 1:length(disturbance_set)
    for mn_id = 1:length(measurement_set)
        disturbance = disturbance_set(di_id);
        measurement_noise = measurement_set(mn_id);
        plot_movie = 0;
        traj_type = 'infty';
        % traj_type = 'lorenz';
        % traj_type = 'mg17';
        % traj_type = 'mg30';
        bridge_type = 'cubic';

        time_infor.val_length=120000;
%调用 func_reservoir_validate 函数进行验证，设置相关参数并返回控制信息、输出信息和时间信息。
        [control_infor, output_infor, time_infor] = func_reservoir_validate(traj_type,...
            bridge_type, time_infor, input_infor, res_infor, properties, dim_in, dim_out, ...
            Wout, dt, plot_movie, disturbance, measurement_noise);

        data_pred=output_infor.data_pred;
        q_pred=output_infor.q_pred;
        qdt_pred=output_infor.qdt_pred;
        q2dt_pred=output_infor.q2dt_pred;
        tau_pred=output_infor.tau_pred;

        q_control=control_infor.q_control;
        qdt_control=control_infor.qdt_control;
        q2dt_control=control_infor.q2dt_control;
        tau_control=control_infor.tau_control;
        % q_control_all=control_infor.q_control_all;
        % qdt_control_all=control_infor.qdt_control_all;
        data_control=control_infor.data_control;

        val_length=time_infor.val_length;

        % calculate rmse
        error = abs(data_control(1:rmse_length, :) - data_pred(1:rmse_length, :));
        error = sum(weight.*mean(error.^2, 2));

        error_set(di_id, mn_id) = error;
    end
end

nan_id = isnan(error_set);
error_set_plot = error_set;
error_set_plot(nan_id) = 3*max(max(error_set));

save_data.disturbance_set_heat = disturbance_set;
save_data.measurement_set_heat = measurement_set;
save_data.heat_error_set = error_set;
save_data.heat_error_set_plot = error_set_plot;

save(['./save_data/heat_result_logscale_', time_today, '.mat'], "save_data")

%% for plot

figure();
surf(disturbance_set, measurement_set, error_set_plot);
xlabel('measurement noise, \sigma')
ylabel('disturbance noise, \sigma')
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
colorbar
view(0, 90)
title('error')



















