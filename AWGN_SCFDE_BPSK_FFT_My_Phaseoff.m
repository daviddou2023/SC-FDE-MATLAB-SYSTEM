% AWGN信道-无其他技术-BPSK-手搓FFT-有频偏纠正


clear all;
clc;
tic; % 开始计时

% 仿真参数
FrameSize = 512;  % 每帧数据长度
numframe = 500;   % 总帧数
u = 64;           % UW序列长度

% 生成UW序列
uw = chu(u);

% 初始化BER数组
BER = zeros(1, 16);

for SNR = 0:2:30
    errCount = 0;

    for j = 1:numframe
        % 生成比特
        BitsTranstmp = randi([0 1], 1, FrameSize);
        index = 1; % BPSK

        % 调制
        BitsTrans = modulation(BitsTranstmp, index);

        % 添加UW序列
        Adduw = [uw, BitsTrans, uw];

        % 添加AWGN信道
        RecChantemp = awgn(Adduw, SNR, 'measured');

        % === 频偏估计与补偿 ===
        re_uw1 = RecChantemp(1:length(uw));  % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
        freq_offset = delta_phase / (2 * pi * length(uw)); % 频率偏移估计
        t = 0:length(RecChantemp)-1;
        RecChantemp = RecChantemp .* exp(-1j*2*pi*freq_offset*t); % 频偏校正

        % 重新提取UW和数据
        re_uw1 = RecChantemp(1:length(uw));  % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % 有效数据

        % UW频域
        Rx_UW1 = my_fft(re_uw1);
        Rx_UW2 = my_fft(re_uw2);
        Tx_UW = my_fft(uw);
        
        % 信道估计（UW平均）
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
        H_esti = Rx_UW ./ Tx_UW;

        % IFFT获取时域冲激响应
        h_esti = my_ifft(H_esti);
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
        H_estimate = my_fft(h_estimate); % 频域估计

        % === 噪声功率估计 ===
        noise_est = mean(abs(re_uw1 - uw).^2);
        
        % MMSE均衡
        EqCoe = conj(H_estimate) ./ (noise_est + abs(H_estimate).^2);

        % 接收频域数据
        RX_signal = fft(rx_signal);
        RX = RX_signal .* EqCoe;

        % 还原时域信号
        rx = my_ifft(RX);

        % 解调
        rx1 = demodulation(rx, index);

        % 错误统计
        I = find((BitsTranstmp - rx1) == 0);
        errCount = errCount + (FrameSize - length(I));
    end

    BER(SNR/2+1) = errCount / (FrameSize * numframe);
end

% 绘图
hold on;
semilogy(0:2:30, BER, 'r-o', 'LineWidth', 1.5);
grid on;
xlabel('信噪比 (dB)');
ylabel('比特误比率 (BER)');
title('SC-FDE系统在AWGN信道下的BER性能（含噪声估计与频偏校正）');
legend('含频偏校正与噪声估计');
toc; % 结束计时


%自定义FFT函数
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

% 自定义IFFT函数
function x = my_ifft(X)
    N = length(X);
    x_conj = conj(X);
    temp = my_fft(x_conj);
    x = conj(temp) / N;
end
