% AWGN信道-无其他技术-BPSK-手搓FFT-有频偏纠正


clear all;
clc;
tic; % 开始计时
SAVE_DATA = 1;  % 定义是否保存数据的标志
% 仿真参数
FrameSize = 512;  % 每帧数据长度
numframe = 500;   % 总帧数
u = 64;           % UW序列长度

% 生成UW序列
uw = chu(u);

% 随机生512比特数据
BitsTranstmp = randi([0 1], 1, FrameSize);
DataSave("BitsTranstmp.txt",BitsTranstmp, length(BitsTranstmp),SAVE_DATA);



index = 1; % BPSK

% 调制
BitsTrans = modulation(BitsTranstmp, index);% BPSK调制（0→-1, 1→+1）
DataSave("BitsTrans.txt",BitsTrans, length(BitsTrans),SAVE_DATA);


% 添加UW序列
Adduw = [uw, BitsTrans, uw];% 前后插入 UW
DataSave("Adduw.txt",Adduw, length(Adduw),SAVE_DATA);
%disp(Adduw)

% 添加AWGN信道
RecChantemp = awgn(Adduw, 0, 'measured');
DataSave("RecChantemp.txt",RecChantemp, length(RecChantemp),SAVE_DATA);
%disp(RecChantemp)

% disp(RecChantemp)
% 频偏估计与补偿 
re_uw1 = RecChantemp(1:length(uw));  % UW1
%disp(re_uw1)
DataSave("rx_re_uw1.txt",re_uw1, length(re_uw1),SAVE_DATA);
re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
DataSave("rx_re_uw2.txt",re_uw2, length(re_uw2),SAVE_DATA);
%delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
delta_phase = angle(sum(conj(re_uw1) .* re_uw2));
% disp(sum(conj(re_uw1) .* re_uw2))
DataSave("delta_phase.txt",delta_phase, length(delta_phase),SAVE_DATA);
freq_offset = delta_phase / (2 * pi * length(uw)); % 频率偏移估计
DataSave("freq_offset.txt",freq_offset, length(freq_offset),SAVE_DATA);
t = 0:length(RecChantemp)-1;
RecChantemp = RecChantemp .* exp(-1j*2*pi*freq_offset*t); % 频偏校正
DataSave("freq_offset_RecChantemp.txt",RecChantemp, length(RecChantemp),SAVE_DATA);
%disp(RecChantemp)



% 重新提取UW和数据
re_uw1 = RecChantemp(1:length(uw));  % UW1
re_uw2 = RecChantemp(FrameSize+length(uw)+1 : FrameSize+2*length(uw)); % UW2
rx_signal = RecChantemp(length(uw)+1 : FrameSize+length(uw)); % 有效数据



% UW频域
Rx_UW1 = my_fft(re_uw1);
%disp(Rx_UW1)
Rx_UW2 = my_fft(re_uw2);
Tx_UW = my_fft(uw);
% 信道估计（UW平均）
Rx_UW = (Rx_UW1 + Rx_UW2) / 2;
%disp(Rx_UW)
H_esti = Rx_UW ./ Tx_UW;
% IFFT获取时域冲激响应
h_esti = my_ifft(H_esti);
disp(h_esti)

h_estimate = [h_esti, zeros(1, FrameSize - length(uw))];
H_estimate = my_fft(h_estimate); % 频域估计
%disp(H_estimate)
DataSave("H_estimate.txt",H_estimate, length(H_estimate),SAVE_DATA);


%噪声功率估计 
noise_est = mean(abs(re_uw1 - uw).^2);
DataSave("noise_est.txt",noise_est, length(noise_est),SAVE_DATA);
% MMSE均衡
EqCoe = conj(H_estimate) ./ (noise_est + abs(H_estimate).^2);
% 接收频域数据
RX_signal = fft(rx_signal);
RX = RX_signal .* EqCoe;
% 还原时域信号
rx = my_ifft(RX);
DataSave("rx.txt",rx, length(rx),SAVE_DATA);



% 解调
rx1 = demodulation(rx, index);
DataSave("rx1.txt",rx1, length(rx1),SAVE_DATA);
% 错误统计
I = find((BitsTranstmp - rx1) == 0);

function X = my_fft(x)
    N = length(x);
    x = bitrevorder(x);  % 位反转排序，

    stages = log2(N);  % FFT的级数

    for s = 1:stages
        m = 2^s;
        half_m = m / 2; % 每组蝶形运算中上、下部分数据长度
        W_m = exp(-2j * pi * (0:half_m - 1) / m); % 计算旋转因子（Twiddle Factor）

        for k = 1:m:N % 遍历每一组
            for j = 0:half_m - 1 % 遍历组内的每一对蝶形操作
                t = W_m(j + 1) * x(k + j + half_m); % 下半部分乘旋转因子
                u = x(k + j); % 上半部分
                x(k + j) = u + t; % 蝶形加法运算
                x(k + j + half_m) = u - t; % 蝶形减法运算
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
