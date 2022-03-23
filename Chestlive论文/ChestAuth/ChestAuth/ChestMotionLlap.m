clear ; clc; close all; % llpStarttime.csv
% Read Data.
FileNumber = 10;
PathRoot_Data = '/Users/mengxue/Downloads/Documents/xueTest';
PathData = [PathRoot_Data, num2str(FileNumber), '.csv'];
ChestMotion = csvread(PathData);
PathRoot_StopTime = '/Users/mengxue/Downloads/Documents/stopTime';
PathStopTime = [PathRoot_StopTime, num2str(FileNumber), '.csv'];
Endtime = csvread(PathStopTime);
PathRoot_StartTime = '/Users/mengxue/Downloads/Documents/startTime';
PathStartTime = [PathRoot_StartTime, num2str(FileNumber), '.csv'];
StartTime = csvread(PathStartTime);


allTime = (Endtime - StartTime(1) ) /1000; % ת��Ϊ�� S
DataLen = length(ChestMotion); % �ɼ��ľ������
Fs = DataLen / allTime;
TimeTic = 0 : 1/Fs : allTime - 1/Fs;
% plot(TimeTic,  ChestMotion); %TimeTic, 
plot(ChestMotion);
ylabel('����'); xlabel('ʱ��/s');
