% AWGN�ŵ�-����������-BPSK-�ִ�FFT-��Ƶƫ����


clear all;
clc;
tic; % ��ʼ��ʱ
SAVE_DATA = 1;  % �����Ƿ񱣴����ݵı�־
% �������
FrameSize = 512;  % ÿ֡���ݳ���
numframe = 500;   % ��֡��
u = 64;           % UW���г���

% ����UW����
uw = chu(u);

% �����512��������
BitsTranstmp = randi([0 1], 1, FrameSize);
DataSave("BitsTranstmp.txt",BitsTranstmp, length(BitsTranstmp),SAVE_DATA);



index = 1; % BPSK

% ����
BitsTrans = modulation(BitsTranstmp, index);% BPSK���ƣ�0��-1, 1��+1��
DataSave("BitsTrans.txt",BitsTrans, length(BitsTrans),SAVE_DATA);


% ���UW����
Adduw = [uw, BitsTrans, uw];% ǰ����� UW
DataSave("Adduw.txt",Adduw, length(Adduw),SAVE_DATA);
%disp(Adduw)

% ���AWGN�ŵ�
RecChantemp = awgn(Adduw, 0, 'measured');
DataSave("RecChantemp.txt",RecChantemp, length(RecChantemp),SAVE_DATA);
%disp(RecChantemp)

% disp(RecChantemp)
% Ƶƫ�����벹�� 
re_uw1 = RecChantemp(1:length(uw));  % UW1
%disp(re_uw1)
DataSave("rx_re_uw1.txt",re_uw1, length(re_uw1),SAVE_DATA);
re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
DataSave("rx_re_uw2.txt",re_uw2, length(re_uw2),SAVE_DATA);
%delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
% disp(sum(conj(re_uw1) .* re_uw2))
DataSave("delta_phase.txt",delta_phase, length(delta_phase),SAVE_DATA);
freq_offset = delta_phase / (2 * pi * length(uw)); % Ƶ��ƫ�ƹ���
DataSave("freq_offset.txt",freq_offset, length(freq_offset),SAVE_DATA);
t = 0:length(RecChantemp)-1;
RecChantemp = RecChantemp .* exp(-1j*2*pi*freq_offset*t); % ƵƫУ��
DataSave("freq_offset_RecChantemp.txt",RecChantemp, length(RecChantemp),SAVE_DATA);
%disp(RecChantemp)



% ������ȡUW������
re_uw1 = RecChantemp(1:length(uw));  % UW1
re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % ��Ч����



% UWƵ��
Rx_UW1 = my_fft(re_uw1);
%disp(Rx_UW1)
Rx_UW2 = my_fft(re_uw2);
Tx_UW = my_fft(uw);
% �ŵ����ƣ�UWƽ����
Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
%disp(Rx_UW)
H_esti = Rx_UW ./ Tx_UW;
% IFFT��ȡʱ��弤��Ӧ
h_esti = my_ifft(H_esti);
disp(h_esti)

h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
H_estimate = my_fft(h_estimate); % Ƶ�����
%disp(H_estimate)
DataSave("H_estimate.txt",H_estimate, length(H_estimate),SAVE_DATA);


%�������ʹ��� 
noise_est = mean(abs(re_uw1 - uw).^2);
DataSave("noise_est.txt",noise_est, length(noise_est),SAVE_DATA);
% MMSE����
EqCoe = conj(H_estimate) ./ (noise_est + abs(H_estimate).^2);
% ����Ƶ������
RX_signal = fft(rx_signal);
RX = RX_signal .* EqCoe;
% ��ԭʱ���ź�
rx = my_ifft(RX);
DataSave("rx.txt",rx, length(rx),SAVE_DATA);



% ���
rx1 = demodulation(rx, index);
DataSave("rx1.txt",rx1, length(rx1),SAVE_DATA);
% ����ͳ��
I = find((BitsTranstmp - rx1) == 0);

function X = my_fft(x)
    N = length(x);
    x = bitrevorder(x);  % λ��ת����

    stages = log2(N);  % FFT�ļ���

    for s = 1:stages
        m = 2^s;
        half_m = m / 2; % ÿ������������ϡ��²������ݳ���
        W_m = exp(-2j * pi * (0:half_m - 1) / m); % ������ת���ӣ�Twiddle Factor��

        for k = 1:m:N % ����ÿһ��
            for j = 0:half_m - 1 % �������ڵ�ÿһ�Ե��β���
                t = W_m(j + 1) * x(k + j + half_m); % �°벿�ֳ���ת����
                u = x(k + j); % �ϰ벿��
                x(k + j) = u + t; % ���μӷ�����
                x(k + j + half_m) = u - t; % ���μ�������
            end
        end
    end

    X = x;
end

function x = my_ifft(X)
    N = length(X);
    X_conj = conj(X);
    x_temp = my_fft(X_conj);
    x = conj(x_temp) / N;
end
