% AWGN�ŵ�-����������-BPSK-ϵͳ�Դ�FFT-��Ƶƫ����


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
        %disp(BitsTranstmp)
        
        index = 1; % ���Ʒ�ʽ������1����BPSK��
        
        BitsTrans = modulation(BitsTranstmp, index); % ����
        
        % ���UW����
        Adduw = [uw, BitsTrans, uw];
        
        % ֱ�����AWGN����ͨ�������ŵ�
        RecChantemp = awgn(Adduw, SNR, 'measured');
        disp("awgn----------------------------------")
        disp(RecChantemp)
        % SC-FDE���ն�
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % ��ȡ��Ч����
        
        re_uw1 = RecChantemp(1:length(uw)); % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        disp("uw1----------------------------------")
        disp(re_uw1)
        % Ƶ����
        RX_signal = fft(rx_signal);
        
        % UW��Ƶ��
        Rx_UW1 = fft(re_uw1);
        Rx_UW2 = fft(re_uw2);
        Tx_UW = fft(uw);
        
        % �ŵ����ƣ�����UWȡƽ����
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
        H_esti = Rx_UW ./ Tx_UW;
        
        % ��ʱ���뵽һ֡����
        h_esti = ifft(H_esti);
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
        H_estimate = fft(h_estimate); % Ƶ�����
        
        % �������ϵ����MMSE��������
        EqCoe = conj(H_estimate) ./ (sgma^2 + abs(H_estimate).^2);
        
        % ����
        RX = RX_signal .* EqCoe;
        
        % ��ԭʱ��
        rx = ifft(RX);
        
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
