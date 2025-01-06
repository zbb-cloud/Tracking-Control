clear all
close all
clc

time_today = datestr(now, 'mmddyyyy');
%设置轨迹类型为 'circle'，并调用 speed_test 函数
traj_type = 'circle';
speed_test
%设置轨迹类型为 'infty'，并再次调用 speed_test 函数
traj_type = 'infty';
speed_test
