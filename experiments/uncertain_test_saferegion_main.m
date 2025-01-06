clear all 
close all 
clc

time_today = datestr(now, 'mmddyyyy');
%设置轨迹类型为 'lorenz'，并调用 uncertain_test_saferegion 函数进行不确定性测试
% traj_type = 'lorenz';
% uncertain_test_saferegion

% traj_type = 'circle';
% uncertain_test_saferegion

% traj_type = 'mg17';
% uncertain_test_saferegion

traj_type = 'infty';
uncertain_test_saferegion







































