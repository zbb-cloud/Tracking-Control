%函数的输出，包括位置 xy，关节角度 q，角速度 qdt，角加速度 q2dt，以及控制信号 tau。
%time_infor：包含时间信息的结构体，noise_level：噪声水平，dt：时间步长，properties：双臂机器人的物理属性。
function [xy, q, qdt, q2dt, tau] = robot_data_generator(time_infor, noise_level, dt, properties)
%解析属性和设置时间参数
% generate time series for training and validation
%解析物理属性，包括质量 m1 和 m2，长度 l1 和 l2，质心位置 lc1 和 lc2，以及惯性矩 I1 和 I2。
[m1, m2, l1, l2, lc1, lc2, I1, I2] = matsplit(properties);
%从 time_infor 结构体中提取时间参数。
section_len = time_infor.section_len;
time_length = time_infor.time_length;

%生成并平滑噪声
% 设置噪声间隔
noise_interval=noise_level; % 3*10^(-2)
%设置扰动长度
pert_length=time_length*2;
%生成随机扰动信号
pert=-noise_interval+2*noise_interval*rand(pert_length,2);
%截取扰动信号以避免边界效应
pert=pert(100:end, :);
%使用高斯滤波器平滑扰动信号
BB = smoothdata(pert, 'gaussian', 50);
pert = BB;
%初始化变量,初始化关节角度、角速度、角加速度和控制信号
q=zeros(time_length,2);
qdt=zeros(time_length,2);
q2dt=zeros(time_length,2);
tau=zeros(time_length,2);
%将平滑后的扰动信号分配给控制信号 tau。
tau(:,:)=pert(1:time_length,:);
%随机化随机数生成器。
rng('shuffle')
%随机游走和状态更新
% To avoid the values too large in random walk, every 'section_len' step we
% will reset the states of the two link robot arm.
%遍历时间长度
for t_i = 1:time_length-1
    %每隔 section_len 步随机重置状态。
    if mod(t_i, section_len)==0
        %随机重置关节角度和角速度
        q(t_i, 1) = 2 * pi * rand(1);
        q(t_i, 2) = 2 * pi * rand(1) - pi;
        qdt(t_i,:)=[0,0];
    end
    %动力学方程
    %计算双臂机器人动力学方程中的各项，包括惯性矩阵 H11, H12, H21, H22
    %科氏力项 h，以及 part_1, part_2, denominator，从而计算角加速度 q2dt
    H11=m1*lc1^2+I1+m2*(l1^2+lc2^2+2*l1*lc2*cos(q(t_i,2)))+I2;
    H12=m2*l1*lc2*cos(q(t_i,2))+m2*lc2^2+I2;
    H21=H12;
    H22=m2*lc2^2+I2;
    h=m2*l1*lc2*sin(q(t_i,2));
    
    part_1=-h*qdt(t_i,2)*qdt(t_i,1)-h*(qdt(t_i,1)+qdt(t_i,2))*qdt(t_i,2);
    part_2=h*qdt(t_i,1)*qdt(t_i,1);
    denominator=H12*H21-H11*H22;
    
    q2dt(t_i,1)=-(-part_1*H22+H12*part_2-H12*tau(t_i,2)+H22*tau(t_i,1))/denominator;
    q2dt(t_i,2)=-(part_1*H21-H11*part_2+H11*tau(t_i,2)-H21*tau(t_i,1))/denominator;
    %状态重置
    %每隔 section_len 步将角加速度和控制信号重置为 0。
    if mod(t_i, section_len)==0
        q2dt(t_i,:)=[0,0];
        tau(t_i,:)=[0,0];
    end
    %更新关节角度和角速度。
    q(t_i+1,:)=q(t_i,:)+qdt(t_i,:)*dt;
    qdt(t_i+1,:)=qdt(t_i,:)+q2dt(t_i,:)*dt;
end
%计算双臂机器人的末端位置 x 和 y，并将其合并为 xy
x=l1*cos(q(:,1))+l2*cos(q(:,1)+q(:,2));
y=l1*sin(q(:,1))+l2*sin(q(:,1)+q(:,2));
xy=[x, y];

end

