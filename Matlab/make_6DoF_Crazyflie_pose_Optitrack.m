% --------------------------------------------------------------------------------------------------------------------
% Made by Eunju Jeong (eunju0316@sookmyung.ac.kr)
% 
% input data  : The results of NatNetPollingSample.m
%               2) timestamp_optitrack.txt 
%                  (timestamp[ms])
%               3) position_optitrack.txt 
%                  (tx[m] ty[m] tz[m])
%               5) rotation_1x9_optitrack.txt 
%                  (r11 r12 r13 r21 r22 r23 r31 r32 r33)
%               
% output data : 2) Optitrack_Crazyflie_6DoF_pose.txt
%                  (timestamp[ms] r11 r12 r13 tx[m] r21 r22 r23 ty[m] r31 r32 r33 tz[m])
% --------------------------------------------------------------------------------------------------------------------

clear all; clc;
%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
milliSecondToSecond = 1000;
milliMeterToMeter = 1000;


%% step 1) parse Optitrack timestamp data

textOptitrackTimeStampFileDir = 'input\timestamp_optitrack.txt';
textOptitrackTimeStampData = importdata(textOptitrackTimeStampFileDir, delimiter, headerlinesIn);
OptitrackTimeStampData = textOptitrackTimeStampData.data(:,1); % textTimeStampData : timestamp[ms]


%% step 2) parse Optitrack position (x y z) data

textOptitrackPoseFileDir = 'input\position_optitrack.txt';
textOptitrackCFPoseData = importdata(textOptitrackPoseFileDir, delimiter, headerlinesIn);
OptitrackCFPoseData = textOptitrackCFPoseData.data(:,[1:3]); % textCFPoseData : tx[mm] ty[mm] tz[mm]

numPose = size(OptitrackCFPoseData,1);
Optitrack_Crazyflie_6DoF_pose = zeros(13, numPose); % initialization


%% step 3) parse Crazyflie rotation matrix (1x9) data

textOptitrackRotationFileDir = 'input\rotation_1x9_optitrack.txt';
textOptitrackRotationData = importdata(textOptitrackRotationFileDir, delimiter, headerlinesIn);
OptitrackRotationData = textOptitrackRotationData.data(:,[1:9]); % textRotationData : r11 r12 r13 r21 r22 r23 r31 r32 r33

%% step 4) rearrange data
for k = 1:numPose
    
    Optitrack_Crazyflie_6DoF_pose(1,k) = OptitrackTimeStampData(k,1);
    Optitrack_Crazyflie_6DoF_pose([2:4],k) = OptitrackRotationData(k,[1:3]);
    Optitrack_Crazyflie_6DoF_pose(5,k) = OptitrackCFPoseData(k,1)/milliMeterToMeter;
    Optitrack_Crazyflie_6DoF_pose([6:8],k) = OptitrackRotationData(k,[4:6]);
    Optitrack_Crazyflie_6DoF_pose(9,k) = OptitrackCFPoseData(k,2)/milliMeterToMeter;
    Optitrack_Crazyflie_6DoF_pose([10:12],k) = OptitrackRotationData(k,[7:9]);
    Optitrack_Crazyflie_6DoF_pose(13,k) = OptitrackCFPoseData(k,3)/milliMeterToMeter;
   
end

Optitrack_Crazyflie_6DoF_pose_1x13 = [0 0 0 0 0 0 0 0 0 0 0 0 0; Optitrack_Crazyflie_6DoF_pose'];
%% step 5) save as .txt & .csv

% Crazyflie_6DoF_pose.txt
% timestamp[ms] r11 r12 r13 tx[m] r21 r22 r23 ty[m] r31 r32 r33 tz[m]
writematrix(Optitrack_Crazyflie_6DoF_pose_1x13, 'output\Optitrack_Crazyflie_6DoF_pose.txt', 'delimiter', ' ')

disp('Done making Optitrack_Crazyflie_6DoF_pose.txt!')
