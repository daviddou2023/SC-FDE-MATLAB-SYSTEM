% AWGN信道-无其他技术-BPSK-手搓FFT-无频偏纠正
clear all;
clc;
tic; % 开始计时

% 仿真参数
FrameSize = 512;  % 每帧的数据长度
numframe = 500;   % 仿真总帧数
u = 64;           % UW序列长度

% 生成UW序列（Chu序列）
uw = chu(u);


% 初始化BER数组
BER = zeros(1, 16);

% 遍历不同的SNR值
for SNR = 0:2:30
    errCount = 0; % 错误计数器清零
    
    for j = 1:numframe
        % 将SNR从dB转换为线性比例
        snr = 10^(SNR/10);
        
        % 计算噪声标准差
        sgma = 1 / sqrt(2 * snr);
        
        % SC-FDE发射端
        BitsTranstmp = randi([0 1], 1, FrameSize); % 随机比特序列
        
        index = 1; % 调制方式索引（1代表BPSK）
        
        BitsTrans = modulation(BitsTranstmp, index); % 调制
        
        % 添加UW序列
        Adduw = [uw, BitsTrans, uw];
        
        % 直接添加AWGN，不通过瑞利信道
        RecChantemp = awgn(Adduw, SNR, 'measured');
        
        % SC-FDE接收端
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % 截取有效数据
        
        re_uw1 = RecChantemp(1:length(uw)); % UW1
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
        
        % 频域处理
        RX_signal = my_fft(rx_signal);
        
        % UW的频域
        Rx_UW1 = my_fft(re_uw1);
        Rx_UW2 = my_fft(re_uw2);
        Tx_UW = my_fft(uw);
        
        % 信道估计（两个UW取平均）
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
        H_esti = Rx_UW ./ Tx_UW;
        
        % 延时补齐到一帧长度
        h_esti = my_ifft(H_esti);
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
        H_estimate = my_fft(h_estimate); % 频域估计
        
        % 计算均衡系数（MMSE均衡器）
        EqCoe = conj(H_estimate) ./ (sgma^2 + abs(H_estimate).^2);
        
        % 均衡
        RX = RX_signal .* EqCoe;
        
        % 还原时域
        rx = my_ifft(RX);
        
        % 解调
        rx1 = demodulation(rx, index);
        
        % 错误统计
        I = find((BitsTranstmp - rx1) == 0);
        errCount = errCount + (FrameSize - length(I));
    end
    
    % BER记录
    BER(SNR/2+1) = errCount / (FrameSize * numframe);
end

% 绘图
hold on;
semilogy(0:2:30, BER, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('信噪比 (dB)');
ylabel('比特误比率 (BER)');
title('SC-FDE系统在AWGN信道下的BER性能');
legend('未编码SC-FDE');
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
