% AWGN�ŵ�-����������-BPSK-�ִ�FFT-��Ƶƫ����
clear all;
clc;
tic; % ��ʼ��ʱ

% �������
FrameSize = 512;  % ÿ֡�����ݳ���
numframe = 500;   % ������֡��
u = 64;           % UW���г���

% ����UW���У�Chu���У�
uw = chu(u);


% ��ʼ��BER����
BER = zeros(1, 16);

% ������ͬ��SNRֵ
for SNR = 0:2:30
    errCount = 0; % �������������
    
    for j = 1:numframe
        % ��SNR��dBת��Ϊ���Ա���
        snr = 10^(SNR/10);
        
        % ����������׼��
        sgma = 1 / sqrt(2 * snr);
        
        % SC-FDE�����
        BitsTranstmp = randi([0 1], 1, FrameSize); % �����������
        
        index = 1; % ���Ʒ�ʽ������1����BPSK��
        
        BitsTrans = modulation(BitsTranstmp, index); % ����
        
        % ���UW����
        Adduw = [uw, BitsTrans, uw];
        
        % ֱ�����AWGN����ͨ�������ŵ�
        RecChantemp = awgn(Adduw, SNR, 'measured');
        
        % SC-FDE���ն�
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % ��ȡ��Ч����
        
        re_uw1 = RecChantemp(1:length(uw)); % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        
        % Ƶ����
        RX_signal = my_fft(rx_signal);
        
        % UW��Ƶ��
        Rx_UW1 = my_fft(re_uw1);
        Rx_UW2 = my_fft(re_uw2);
        Tx_UW = my_fft(uw);
        
        % �ŵ����ƣ�����UWȡƽ����
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
        H_esti = Rx_UW ./ Tx_UW;
        
        % ��ʱ���뵽һ֡����
        h_esti = my_ifft(H_esti);
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
        H_estimate = my_fft(h_estimate); % Ƶ�����
        
        % �������ϵ����MMSE��������
        EqCoe = conj(H_estimate) ./ (sgma^2 + abs(H_estimate).^2);
        
        % ����
        RX = RX_signal .* EqCoe;
        
        % ��ԭʱ��
        rx = my_ifft(RX);
        
        % ���
        rx1 = demodulation(rx, index);
        
        % ����ͳ��
        I = find((BitsTranstmp - rx1) == 0);
        errCount = errCount + (FrameSize - length(I));
    end
    
    % BER��¼
    BER(SNR/2+1) = errCount / (FrameSize * numframe);
end

% ��ͼ
hold on;
semilogy(0:2:30, BER, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('����� (dB)');
ylabel('��������� (BER)');
title('SC-FDEϵͳ��AWGN�ŵ��µ�BER����');
legend('δ����SC-FDE');
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
