close all;
clear;clc;
%����wav��ʽ��¼���ļ�
path_voice = '/Users/mengxue/Documents/Paper/ChestAuthentication/Material/TheFirstData/Xusixiao/20200402Vowel/20200402-Vowel-CAT-1.wav';
[Rt, Fs] = audioread(path_voice);
%���һ����ͨ�˲��� 20000 pilot ȷ���Ǹ�Ƶ�������źš�
[b,a]=butter(1,[19000/Fs 21000/Fs],'bandpass');
Rt=filter(b,a,Rt);
 
%����¼���ļ���ESD��sineƵ��Ϊ21KHz������20hz�Ķ����գ�binsΪ 976 977 978 
N = 2048;
L = length(Rt);
for i = 1 :N: L-N
    if( i == 1)%�Ե�һ��2048�����FFT������ESD  (Rt(1:1:N)��ָ�����źŵ�2048���㡣 930:932
        j = 1;
        y_tmp = fft((Rt(1:1:N)),N) ;
        Rf = abs(y_tmp) .* abs(y_tmp);
        Esd =  sum(Rf(976:978)) / N; %pilot Ϊ 20khz
    else%��¼���ļ���ʣ���2048�����FFT������ESD
        j = j + 1;
        y_tmp = fft( Rt(N*(j-1)+1 :1: N*j), N);
        Rf = abs(y_tmp) .* abs(y_tmp);
        tmp = sum(Rf(976:978))/N;
        Esd = [Esd tmp];
    end
end

%ƽ������
Esd = smoothdata(Esd);

%���ݻ���ESD��ʱ��ͼ  2048/48000
len_esd = length(Esd);
t = 0 :N/Fs: (len_esd - 1) * N/Fs;
figure;
plot(t,Esd);
xlabel("ʱ�䣺��λ ��s");
ylabel("ESD");