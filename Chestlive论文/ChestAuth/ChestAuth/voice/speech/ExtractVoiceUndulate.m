close all;
clear ;clc;
% Load other person's voice
voiceGQY = load('voiceGQY_Cup.mat'); 

%����wav��ʽ��¼���ļ�
% path_voice1 = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/Attackmimic/WithOutBreath/XuSiXiao/20200512Hisiri/';
% path_voice2 = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/TheFirstData/Xusixiao/20200408Vowel/VOWEL-CUP-';
path_voice2 = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/BigData/Final/XueMeng/CollectedData/WAV�ļ�/getWav';
path_voice3 = '.wav';
times_number = 83;
Data_number = times_number;
vowel_end =0.17; % line 104f
deleteseg_num = 0;
path_voice = sprintf('%s%d%s',path_voice2, times_number, path_voice3);
[Rt, Fs] = audioread(path_voice);
% Rt1 = Rt;
% Read Bins data from files
% path_undulate1 = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/Attackmimic/WithOutBreath/XuSiXiao/20200512Hisiri/';
path_undulate2 = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/BigData/Final/XueMeng/CollectedData/BINS�ļ�/TEST_BINS';
path_undulate3 = '.csv';
path_undulate = sprintf('%s%d%s',path_undulate2,times_number,path_undulate3);
BinsSet = csvread(path_undulate, 2,0);
handle_esd = [
    1 % ��֡ ��ʱ��
    ];

% sound(Rt,Fs);
handle_arr = [
    0 % ������ԭʼ�źš�1
    1 % �˲�֮����źš�2
    0 % ϣ������֮��İ��硣3
    0 % �����ס�4
    1 % MFcc��5
    1 % �������ڼ�⡣6
    1 % ����������ݡ�7
    1 % xcorr 8 
    1 % crosscor 9
    ];

%���һ����ͨ�˲��� 20000 pilot ȷ���Ǹ�Ƶ�������źš�
time = length(Rt)/Fs;
xtic = 0 : 1/Fs :time - 1/Fs;
[b,a]=butter(1,[200/Fs 1200/Fs],'bandpass');
Rt=filter(b,a,Rt) * 100;

Rt=Rt-mean(Rt);    % ��ȥֱ������
Rt=Rt/max(abs(Rt));  % ��ֵ��һ��

if (handle_arr(1) == 1)
    figure(101);
    plot(xtic, Rt);
    title("������ԭʼ�ź�");
end

%Frequency Features
N=length(Rt); %����ԭ�źŵĳ���
f=Fs*(0:N-1)/N;  %Ƶ�ʷֲ�
y=fft(Rt);  %��ԭʱ���ź�x����fft���õ�Ƶ���ź�y
if (handle_arr(4) == 1)
    Energy = abs(y) .* abs(y);
    figure(104)
    plot(xtic,Energy)   %�����˲�֮���ʱ���ź�x1
    title('�źŵ�������')
end

%����˲���FIR�˲���
b=fir1(8,[200/Fs 1200/Fs]);  %��ƴ�ͨ�˲��� 48
c=freqz(b,1,N);   %Ƶ������
y1 = y.*c;
x1=ifft(y1);
if (handle_arr(2) == 1)
    figure(102);
    plot(xtic,real(x1))   %�����˲�֮���ʱ���ź�x1
    title('�˲�֮���ʱ���ź�')
end

%hilbert�任����x1�������
x2=hilbert(real(x1));  %x1��ϣ�����ر任x2 real(x1)
x3=abs(x2);      %x2ȡģ���õ�x3
x4 = - abs(hilbert(real(x1)));
if (handle_arr(3) == 1)
    figure(103)
    plot(xtic,x3, xtic,x4);
    title('ʹ��ϣ������֮����õð���')
end

%========================
% ������������
if (handle_arr(6) == 1)
    wlen=200;   % ֡��
    inc=80;     % ֡��
    T1= vowel_end;    % ���û����˵���Ĳ��� 0.05 ��̬���� 0.5 1
    [voiceseg,vosl,SF,Ef]=pitch_vad(Rt,wlen,inc,T1);   % �����Ķ˵���
    fn=length(SF);
    time1 = (0 : length(Rt)-1)/Fs;                % ����ʱ������
    frameTime = FrameTimeC(fn, wlen, inc, Fs);  % �����֡��Ӧ��ʱ������
    figure(106);
    plot(time1,Rt,'k');  hold on;
    title('�����ź���ȡ'); axis([0 max(time1) -1 1]);
    ylabel('��ֵ'); xlabel('ʱ��/s');
%     %%%%%
    if vosl > 2
        i_vosl_temp = vosl;
        remian_num = 3;
        % ȡ�������������
        while(i_vosl_temp-remian_num>0)
            i_vosl_temp1 = i_vosl_temp-remian_num;
            voiceseg(i_vosl_temp1) = [];
            i_vosl_temp = i_vosl_temp - 1;
        end
        vosl = remian_num;
    end
    
    if(deleteseg_num ~= 0)
        voiceseg(deleteseg_num) = []; %Used temporal. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        vosl = vosl -1;           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    Result_voice = 0;
    %%%%%
    for k=1 : vosl    % ����л���
        nx1=voiceseg(k).begin;
        nx2=voiceseg(k).end;
        nxl=voiceseg(k).duration; % ԭʼ����������
        voice_tmp = Rt(frameTime(nx1) * Fs: frameTime(nx2) * Fs);
        if (k==1)
            Result_voice = voice_tmp; % ʹ�÷�ʽResult_voice{1,1}
        else
            Result_voice = {Result_voice voice_tmp};
        end
        fprintf('%4d   %4d   %4d   %4d\n',k,frameTime(nx1),frameTime(nx2),nxl);
        line([frameTime(nx1) frameTime(nx1)],[-1 1],'color','r','linestyle','-');
        line([frameTime(nx2) frameTime(nx2)],[-1 1],'color','b','linestyle','--');
    end
    
    % ����ȡ�����Ի��Ƴ�����
    offline = 0;
    figure(107)
    for i = 1:vosl  % ������441�ļ��
        r_len = length(Result_voice{1,i});
        plot((0:441)/Fs + offline,zeros(442),'k');hold on;
        r_time = (0 : r_len-1)/Fs + offline + 441/Fs;
        plot(r_time, Result_voice{1,i});hold on;
        offline = max(r_time);
    end
    title('����������');
    ylabel('��ֵ'); xlabel('ʱ��/s');
end

%=================================================================
% ����÷������ϵ�� MFCC
if (handle_arr(5) == 1)
    wlen=200; % ֡��
    inc=80;  % ֡��
    num=8; %Mel�˲�������
    AA = Rt; %Rt real(x1)
    AA=AA/max(abs(AA)); % ��ֵ��һ�� 
    time=(0:length(AA)-1)/Fs;
    ccc1=Nmfcc(AA,Fs,num,wlen,inc);
    fn=size(ccc1,1)+4;  %ǰ�������֡������ ����֡һ�ײ�ֲ���Ϊ0
    cn=size(ccc1,2);
    z=zeros(1,cn);
    ccc2=[z;z;ccc1;z;z];
    frameTime=FrameTimeC(fn,wlen,inc,Fs); % ���ÿ֡��Ӧ��ʱ��
    figure(105) ;
    ax105 = gca;
    plot(ax105, frameTime,ccc2(:,1:cn));  % ����ÿͨ����MFCCϵ��  1:cn/2
    title('(b)MFCCϵ��');
    ylabel('��ֵ'); xlabel(['ʱ��/s' ]);
    figure(17); % ����л��β��ֵ� MFCC �� ================================================================
    ccc2xue = cell(1,2);
    for k=1 : vosl    % ����л���
        nx1=voiceseg(k).begin;
        nx2=voiceseg(k).end;
        line(ax105,[frameTime(nx1) frameTime(nx1)],[-10 10],'color','r','linestyle','-');
        line(ax105, [frameTime(nx2) frameTime(nx2)],[-10 10],'color','b','linestyle','--');
        ax17_k = subplot(1,2,k);
        for i = 1:39    % 1:39
            tmpccc2xue = ccc2(:,i);           
            if i==1   %��ȡ����ǻ����Σ������źŵ�MFCC
                ccc2xue{1,k} = tmpccc2xue(nx1:nx2);
            else
                ccc2xue{1,k} = [ccc2xue{1,k} tmpccc2xue(nx1:nx2)];
            end
            plot(ax17_k, frameTime(nx1:nx2),tmpccc2xue(nx1:nx2));hold on;
        end
    end
end

%=================================================================
% �����������
if (handle_arr(7) == 1)
    % Value of bins
    time = BinsSet(:,1);
    xtic= (time(:) - time(1))./1000;
    Fs_undulate = length(time)/xtic(length(time)); 
    Esd = 0;
    figure(11)
    % Plot the bins.
    for i = 2:1:17   
        plot(xtic,BinsSet(:,i)); hold on;
    end
    title('��ͬbins������');

    %���� ��ǻ���������ͼ
    for i = 8:1:12 % 1856-1860
        Esd = Esd + BinsSet(:,i) .* BinsSet(:,i);
    end
    figure(12)
    FlattenedData2 = Esd(:)';
    MappedFlattened2 = mapminmax(FlattenedData2, -1, 1);
    MappedData2 = reshape(MappedFlattened2, size(Esd));
    plot(xtic,MappedData2);
    title('��ǻ���������ͼ');
    axis([0 max(xtic) -1 1]); 

    % ��֡����λ˵��ʱ�����
    if( handle_esd(1) == 1)
        wlen=200;   % ֡��
        inc=80;     % ֡��
        y=enframe(Esd,wlen,inc)';    % ��֡
        fn=size(y,2);                % ��֡��
        Result_undulate = 0;
        for k=1 : vosl               % ����л���
            nx1=voiceseg(k).begin;
            nx2=voiceseg(k).end;
            Undulate_tmp = MappedData2(floor(frameTime(nx1) * Fs_undulate): ceil(frameTime(nx2) * Fs_undulate)); %ceil
            if (k==1)
                Result_undulate = Undulate_tmp; % ʹ�÷�ʽResult_voice{1,1}
            else
                Result_undulate = {Result_undulate Undulate_tmp};
            end
            line([frameTime(nx1) frameTime(nx1)],[-1 1],'color','r','linestyle','-');
            line([frameTime(nx2) frameTime(nx2)],[-1 1],'color','b','linestyle','--');
        end
        
    end

    % ����ȡ��������Ƴ�����
    offline_undulate = 0;
    figure(13)
    for i = 1:vosl  % ������441�ļ��
        r_len_un = length(Result_undulate{1,i});
        r_time_un = (0 : r_len_un-1)/Fs_undulate + offline_undulate;
        plot(r_time_un, Result_undulate{1,i});hold on;
        offline_undulate = max(r_time_un);
    end
    title('���������');
    ylabel('��ֵ'); xlabel('ʱ��/s');
end


%=================================================================
% ���� xcor
if (handle_arr(8) == 1)
    %corrcoef xcorr crosscorr
%     voiceCundualte1 = xcorr(Result_voice{1,1},Result_undulate{1,1},'none');
    voiceCundualte2 = xcorr(Result_voice{1,2},Result_undulate{1,2},'none');
    voiceCundualte1 = xcorr(voiceGQY.voiceGQY,Result_undulate{1,1},'none'); % UseToMimic Hi
%     voiceCundualte2 = xcorr(voiceGQY.voiceGQYSiri,Result_undulate{1,2},'none'); % UseToMimic
    
    figure(14);
    subplot(1,2,1)
    plot(voiceCundualte1);
    subplot(1,2,2)
    plot(voiceCundualte2);
    %===========
    cor_wlen=200; % ֡��
    cor_inc=80;  % ֡��
    cor_num=8; %Mel�˲�������
    
    cor_AA1 = voiceCundualte1; 
    cor_AA2 = voiceCundualte2;
    cor_AA1=cor_AA1/max(abs(cor_AA1)); % ��ֵ��һ�� 
    cor_AA2=cor_AA2/max(abs(cor_AA2)); % ��ֵ��һ�� 
    cor_time1=(0:length(cor_AA1)-1)/Fs;
    cor_time2=(0:length(cor_AA2)-1)/Fs;
    cor1_ccc1=Nmfcc(cor_AA1,Fs,num,wlen,inc);
    cor_fn1=size(cor1_ccc1,1)+4;  %ǰ�������֡������
    cor_cn1=size(cor1_ccc1,2);
    cor_z1=zeros(1,cor_cn1);
    cor1_ccc2=[cor_z1;cor_z1;cor1_ccc1;cor_z1;cor_z1];
    
    cor2_ccc1=Nmfcc(cor_AA2,Fs,num,wlen,inc);
    cor_fn2=size(cor2_ccc1,1)+4;  %ǰ�������֡������
    cor_cn2=size(cor2_ccc1,2);
    cor_z2=zeros(1,cor_cn2);
    cor2_ccc2=[cor_z2;cor_z2;cor2_ccc1;cor_z2;cor_z2];
    frameTime1=FrameTimeC(cor_fn1,wlen,inc,Fs); % ���ÿ֡��Ӧ��ʱ��
    frameTime2=FrameTimeC(cor_fn2,wlen,inc,Fs); % ���ÿ֡��Ӧ��ʱ��
    figure(15) ;
    subplot(121);
    plot(frameTime1,cor1_ccc2(:,1:cor_cn1))  % ����ÿͨ����MFCCϵ��  1:cor_cn1  =================1
    title('(a)MFCCϵ��');
    ylabel('��ֵ'); xlabel(['ʱ��/s' ]);
    subplot(122);
    plot(frameTime2,cor2_ccc2(:,1:cor_cn2))  % ����ÿͨ����MFCCϵ��  1:cor_cn2  ==================1
    title('(b)MFCCϵ��');
    ylabel('��ֵ'); xlabel(['ʱ��/s']);
    %===========
    HiSiri = [cor1_ccc2; cor2_ccc2];
end

%=================================================================
% ���� crosscor
if (handle_arr(9) == 1)
    [acor1,lag1] = crosscorr(Result_voice{1,1},Result_undulate{1,1});
    [acor2,lag2] = crosscorr(Result_voice{1,2},Result_undulate{1,2});
    [~,I1] = max(abs(acor1));
    [~,I2] = max(abs(acor2));
    lagDiff1 = lag1(I1);
    timeDiff1 = lagDiff1/Fs_undulate;
    lagDiff2 = lag2(I2);
    timeDiff2 = lagDiff2/Fs_undulate;

    figure(16)
    subplot(211)
    plot(lag1,acor1)
    a3 = gca;
%     a3.XTick = sort([-3000:1000:3000 lagDiff1]);

    subplot(212)
    plot(lag2,acor2)
    a4 = gca;
%     a4.XTick = sort([-3000:1000:3000 lagDiff2]);
end 

%=================================================================
% Save Data.
% path_store0  = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/TheFirstData/Xusixiao/MimicGQY/CUP';
% % path_store1  = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/Attackmimic/WithOutBreath/XuSiXiao/Matlab20200512/HiSiri';
% path_store2 = '.mat';
% path_store_chest = sprintf('%s%d%s',path_store0,Data_number,path_store2);
% % path_store_voice = sprintf('%s%d%s',path_store0,times_number,path_store2);
% save(path_store_chest, 'cor1_ccc2'); %, 'cor2_ccc2', 'HiSiri'
% % save(path_store_voice, 'ccc2xue'); %  'cor1_ccc2', 'cor2_ccc2' two word�� cup��luck��
%================================================================
% voiceGQYHi = Result_voice{1,1};
% voiceGQYSiri = Result_voice{1,2};
% save('voiceGQY.mat', 'voiceGQYHi', 'voiceGQYSiri')