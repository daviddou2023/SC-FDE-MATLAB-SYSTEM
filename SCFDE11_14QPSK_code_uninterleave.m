clear all;
clc;
tic; % ��ʼ��ʱ

FrameSize = 512;    % ÿ֡���ݳ��� 512
numframe = 500;     % ������֡�� 500
u = 64;             % UW���г���64
uw = chu(u);      % ����UW��������Unique Word��

% ���� Rayleigh �ŵ�������� rayleighchan��
Ts = 0.1e-6;        % ����ʱ�� 0.1΢��
Fd = 0.5;           % ������Ƶ�� 0.5Hz
tau = [0 0.4e-6 0.9e-6];  % �ྶ�ӳ�
pdb = [0 -5 -10];         % ÿ��·��������(dB)

% ʹ�� comm.RayleighChannel ������� rayleighchan
chan = comm.RayleighChannel( ...
    'SampleRate', 1/Ts, ...
    'PathDelays', tau, ...
    'AveragePathGains', pdb, ...
    'MaximumDopplerShift', Fd, ...
    'NormalizePathGains', true);

trel = poly2trellis( 7,[171 133] ); % ���ɾ�������trellis�ṹ
tblen = 5*7;                        % �������
% interleave_table = interleav_matrix( ones(1,2*FrameSize) ); 

BER = zeros(1,16); % ��ʼ��BER���飬16���㣨0:2:30һ��16����

% ������ͬ��SNRֵ
for SNR = 0:2:30
    errCount = 0; % ÿ��SNR�µĴ��������
    for j = 1:numframe
        % ��SNR��dBת��������ֵ
        snr = 10^(SNR/10);
        % ����������׼��
        sgma = 1/sqrt(2*snr);

        % --- ���Ͷ� ---
        BitsTranstmp_1 = randi([0 1], 1, FrameSize); 
        BitsTranstmp = convenc( BitsTranstmp_1,trel ); % �Ա������н��о������
%         interleav_out = interleaving( BitsTranstmp,interleave_table ); % ��֯
        index = 2;    % ���Ʒ�ʽ��QPSK��
        BitsTrans = modulation(BitsTranstmp, index); % �Զ��庯��������
        % ���UW���У���ͷ����β����
        Adduw = [uw, BitsTrans, uw]; 

        % --- �ŵ����� ---
        chan.reset(); % �����ŵ���ȷ��ÿ֡����
        RecChan = chan(Adduw.'); % ע��chan��Ҫ����������
        RecChan = RecChan.';    % ת��������

        % ���Ը�˹������
        RecChantemp = awgn(RecChan, SNR, 'measured');

        % --- ���ն� ---
        % ȥ��ǰ���UW���У�ֻ�����м������
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw));
        re_uw1 = RecChantemp(1:length(uw)); % ǰ��UW
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % ��UW

        RX_signal = fft(rx_signal); % �Խ��յ������ݽ���FFT

        % --- �ŵ����� ---
        Rx_UW1 = fft(re_uw1);  
        Rx_UW2 = fft(re_uw2);  
        Tx_UW = fft(uw);      % �����UW��FFT
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2; % ƽ������UW�����ٹ������
        H_esti = Rx_UW ./ Tx_UW;  % �����ŵ�Ƶ��
        h_esti = ifft(H_esti);    % ת��ʱ��
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))]; % ����ʹ����һ��
        H_estimate = fft(h_estimate); % ������һ֡Ƶ���ŵ�����

        % --- ���� ---
        % MMSE������
        EqCoe = conj(H_estimate) ./ (sgma^2 + abs(H_estimate).^2);
        % (���Ҫ��ZF���ĳ� EqCoe = 1 ./ H_estimate)

        RX = RX_signal .* EqCoe;   % Ƶ�����
        rx = ifft(RX);             % ���ʱ��

        % --- ��� ---
        rx1 = demodulation(rx, index); % �Զ��庯�������
%         % �⽻֯
%         deinterleav_out = de_interleaving( rx1,interleave_table );
%         % ά�رȱ���
%         viterbi_out = vitdec( deinterleav_out,trel,tblen,'cont','hard' );
        % ά�رȱ���
        viterbi_out = vitdec( rx1,trel,tblen,'cont','hard' );
        % ȥ��������Ȳ���
        rx_1 = viterbi_out(tblen+1:end);
        % ȥ������˵Ļ��ݲ���
        tx_1 = BitsTranstmp_1(1:end-tblen);

        I = find((tx_1 - rx_1) == 0); % �ҳ�������ȷ��λ��
        errCount = errCount + (length(tx_1)-length(I)); % ͳ�ƴ������
    end

    % ����BER
    BER(SNR/2+1) = errCount / (FrameSize*numframe);
end

% --- ����BER���� ---
hold on;
semilogy(0:2:30, BER, 'o-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('SC-FDEϵͳ��Rayleigh�ŵ��µ�BER����');
toc; % ��ʾ������ʱ��
