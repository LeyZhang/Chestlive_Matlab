close all;
clear;clc;
%����wav��ʽ��¼���ļ� /Users/mengxue/Downloads/getWav(1).wav
path = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/TheFirstData/Xusixiao/20200402Vowel/20200402-Vowel-CUP-2.wav';
[Rt, Fs] = audioread(path);

% sound(Rt,Fs);
handle_arr = [
    0 % ������ԭʼ�źš�1
    1 % �˲�֮����źš�2
    0 % ϣ������֮��İ��硣3
    0 % �����ס�4
    1 % MFcc��5
    1 % �������ڼ�⡣6
    ];

%���һ����ͨ�˲��� 20000 pilot ȷ���Ǹ�Ƶ�������źš�
time = length(Rt)/Fs;
xtic = 0 : 1/Fs :time - 1/Fs;
[b,a]=butter(1,[200/Fs 1200/Fs],'bandpass');
Rt=filter(b,a,Rt) * 100;
Rt=Rt-mean(Rt);                                % ��ȥֱ������
Rt=Rt/max(abs(Rt));                            % ��ֵ��һ��

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
b=fir1(48,[200/Fs 1200/Fs]);  %��ƴ�ͨ�˲���
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

% ����÷������ϵ��
if (handle_arr(5) == 1)
    wlen=200; % ֡��
    inc=80;  % ֡��
    num=8; %Mel�˲�������
    AA = Rt; %Rt real(x1)
    AA=AA/max(abs(AA));    % ��ֵ��һ�� 
    time=(0:length(AA)-1)/Fs;
    ccc1=Nmfcc(AA,Fs,num,wlen,inc);
    fn=size(ccc1,1)+4;  %ǰ�������֡������
    cn=size(ccc1,2);
    z=zeros(1,cn);
    ccc2=[z;z;ccc1;z;z];
    frameTime=FrameTimeC(fn,wlen,inc,Fs);               % ���ÿ֡��Ӧ��ʱ��
    figure(105) ; 
    plot(frameTime,ccc2(:,1:cn/2))  % ����ÿͨ����MFCCϵ��  1:cn/2
    title('(b)MFCCϵ��');
    ylabel('��ֵ'); xlabel(['ʱ��/s' ]);  
end

% ������������
if (handle_arr(6) == 1)
    wlen=200;   % ֡��
    inc=80;     % ֡��
    T1=0.1;    % ���û����˵���Ĳ��� 0.05 ��̬���� 0.5 1
    [voiceseg,vosl,SF,Ef]=pitch_vad(Rt,wlen,inc,T1);   % �����Ķ˵���
    fn=length(SF);
    time1 = (0 : length(Rt)-1)/Fs;                % ����ʱ������
    frameTime = FrameTimeC(fn, wlen, inc, Fs);  % �����֡��Ӧ��ʱ������
    figure(106);
    plot(time1,Rt,'k');  hold on;
    title('�����ź���ȡ'); axis([0 max(time1) -1 1]);
    ylabel('��ֵ'); xlabel('ʱ��/s');
    Result_voice = 0;
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
