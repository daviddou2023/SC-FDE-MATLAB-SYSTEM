% AWGN�ŵ�-����������-BPSK-�ִ�FFT-��Ƶƫ����


clear all;
clc;
tic; % ��ʼ��ʱ

% �������
FrameSize = 512;  % ÿ֡���ݳ���
numframe = 500;   % ��֡��
u = 64;           % UW���г���

% ����UW����
uw = chu(u);

% ��ʼ��BER����
BER = zeros(1, 16);

for SNR = 0:2:30
    errCount = 0;

    for j = 1:numframe
        % ���ɱ���
        BitsTranstmp = randi([0 1], 1, FrameSize);
        index = 1; % BPSK

        % ����
        BitsTrans = modulation(BitsTranstmp, index);

        % ���UW����
        Adduw = [uw, BitsTrans, uw];

        % ���AWGN�ŵ�
        RecChantemp = awgn(Adduw, SNR, 'measured');

        % === Ƶƫ�����벹�� ===
        re_uw1 = RecChantemp(1:length(uw));  % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
        freq_offset = delta_phase / (2 * pi * length(uw)); % Ƶ��ƫ�ƹ���
        t = 0:length(RecChantemp)-1;
        RecChantemp = RecChantemp .* exp(-1j*2*pi*freq_offset*t); % ƵƫУ��

        % ������ȡUW������
        re_uw1 = RecChantemp(1:length(uw));  % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % ��Ч����

        % UWƵ��
        Rx_UW1 = my_fft(re_uw1);
        Rx_UW2 = my_fft(re_uw2);
        Tx_UW = my_fft(uw);
        
        % �ŵ����ƣ�UWƽ����
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
        H_esti = Rx_UW ./ Tx_UW;

        % IFFT��ȡʱ��弤��Ӧ
        h_esti = my_ifft(H_esti);
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
        H_estimate = my_fft(h_estimate); % Ƶ�����

        % === �������ʹ��� ===
        noise_est = mean(abs(re_uw1 - uw).^2);
        
        % MMSE����
        EqCoe = conj(H_estimate) ./ (noise_est + abs(H_estimate).^2);

        % ����Ƶ������
        RX_signal = fft(rx_signal);
        RX = RX_signal .* EqCoe;

        % ��ԭʱ���ź�
        rx = my_ifft(RX);

        % ���
        rx1 = demodulation(rx, index);

        % ����ͳ��
        I = find((BitsTranstmp - rx1) == 0);
        errCount = errCount + (FrameSize - length(I));
    end

    BER(SNR/2+1) = errCount / (FrameSize * numframe);
end

% ��ͼ
hold on;
semilogy(0:2:30, BER, 'r-o', 'LineWidth', 1.5);
grid on;
xlabel('����� (dB)');
ylabel('��������� (BER)');
title('SC-FDEϵͳ��AWGN�ŵ��µ�BER���ܣ�������������ƵƫУ����');
legend('��ƵƫУ������������');
toc; % ������ʱ


%�Զ���FFT����
function X = my_fft(x)
    N = length(x);
    if N <= 1
        X = x;
    else
        even = my_fft(x(1:2:end));
        odd  = my_fft(x(2:2:end));
        W = exp(-2j*pi*(0:N/2-1)/N);
        X = [even + W .* odd, even - W .* odd];
    end
end

% �Զ���IFFT����
function x = my_ifft(X)
    N = length(X);
    x_conj = conj(X);
    temp = my_fft(x_conj);
    x = conj(temp) / N;
end
