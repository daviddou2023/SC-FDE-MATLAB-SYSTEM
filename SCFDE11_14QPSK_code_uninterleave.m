clear all;
clc;
tic; % 开始计时

FrameSize = 512;    % 每帧数据长度 512
numframe = 500;     % 仿真总帧数 500
u = 64;             % UW序列长度64
uw = chu(u);      % 生成UW（独特字Unique Word）

% 创建 Rayleigh 信道对象（替代 rayleighchan）
Ts = 0.1e-6;        % 采样时间 0.1微秒
Fd = 0.5;           % 多普勒频移 0.5Hz
tau = [0 0.4e-6 0.9e-6];  % 多径延迟
pdb = [0 -5 -10];         % 每条路径的增益(dB)

% 使用 comm.RayleighChannel 对象代替 rayleighchan
chan = comm.RayleighChannel( ...
    'SampleRate', 1/Ts, ...
    'PathDelays', tau, ...
    'AveragePathGains', pdb, ...
    'MaximumDopplerShift', Fd, ...
    'NormalizePathGains', true);

trel = poly2trellis( 7,[171 133] ); % 生成卷积编码的trellis结构
tblen = 5*7;                        % 回溯深度
% interleave_table = interleav_matrix( ones(1,2*FrameSize) ); 

BER = zeros(1,16); % 初始化BER数组，16个点（0:2:30一共16个）

% 遍历不同的SNR值
for SNR = 0:2:30
    errCount = 0; % 每个SNR下的错误计数器
    for j = 1:numframe
        % 将SNR从dB转换成线性值
        snr = 10^(SNR/10);
        % 计算噪声标准差
        sgma = 1/sqrt(2*snr);

        % --- 发送端 ---
        BitsTranstmp_1 = randi([0 1], 1, FrameSize); 
        BitsTranstmp = convenc( BitsTranstmp_1,trel ); % 对比特序列进行卷积编码
%         interleav_out = interleaving( BitsTranstmp,interleave_table ); % 交织
        index = 2;    % 调制方式（QPSK）
        BitsTrans = modulation(BitsTranstmp, index); % 自定义函数：调制
        % 添加UW序列（在头部和尾部）
        Adduw = [uw, BitsTrans, uw]; 

        % --- 信道传输 ---
        chan.reset(); % 重置信道，确保每帧独立
        RecChan = chan(Adduw.'); % 注意chan需要列向量输入
        RecChan = RecChan.';    % 转回行向量

        % 加性高斯白噪声
        RecChantemp = awgn(RecChan, SNR, 'measured');

        % --- 接收端 ---
        % 去除前后的UW序列，只保留中间的数据
        rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw));
        re_uw1 = RecChantemp(1:length(uw)); % 前导UW
        re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % 后导UW

        RX_signal = fft(rx_signal); % 对接收到的数据进行FFT

        % --- 信道估计 ---
        Rx_UW1 = fft(re_uw1);  
        Rx_UW2 = fft(re_uw2);  
        Tx_UW = fft(uw);      % 发射端UW的FFT
        Rx_UW = (Rx_UW1 + Rx_UW2) / 2; % 平均两个UW，减少估计误差
        H_esti = Rx_UW ./ Tx_UW;  % 估计信道频响
        h_esti = ifft(H_esti);    % 转到时域
        h_estimate = [h_esti, zeros(1, FrameSize - length(uw))]; % 补零使长度一致
        H_estimate = fft(h_estimate); % 完整的一帧频域信道估计

        % --- 均衡 ---
        % MMSE均衡器
        EqCoe = conj(H_estimate) ./ (sgma^2 + abs(H_estimate).^2);
        % (如果要用ZF，改成 EqCoe = 1 ./ H_estimate)

        RX = RX_signal .* EqCoe;   % 频域均衡
        rx = ifft(RX);             % 变回时域

        % --- 解调 ---
        rx1 = demodulation(rx, index); % 自定义函数：解调
%         % 解交织
%         deinterleav_out = de_interleaving( rx1,interleave_table );
%         % 维特比编码
%         viterbi_out = vitdec( deinterleav_out,trel,tblen,'cont','hard' );
        % 维特比编码
        viterbi_out = vitdec( rx1,trel,tblen,'cont','hard' );
        % 去除回溯深度部分
        rx_1 = viterbi_out(tblen+1:end);
        % 去除发射端的回溯部分
        tx_1 = BitsTranstmp_1(1:end-tblen);

        I = find((tx_1 - rx_1) == 0); % 找出接收正确的位置
        errCount = errCount + (length(tx_1)-length(I)); % 统计错误个数
    end

    % 计算BER
    BER(SNR/2+1) = errCount / (FrameSize*numframe);
end

% --- 绘制BER曲线 ---
hold on;
semilogy(0:2:30, BER, 'o-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('SC-FDE系统在Rayleigh信道下的BER性能');
toc; % 显示总运行时间
