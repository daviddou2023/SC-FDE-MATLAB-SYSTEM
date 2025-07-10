% 读取发送数据和接收数据
tx = load('E:\DaSanXia\SC-FDE\SC-FDE-VIVADO\units\bpsk_mod\bpsk_mod\bpsk_mod.sim\sim_1\random_data.txt');  % 或者使用 readmatrix / textscan 根据文件格式选择
rx = load('E:\DaSanXia\SC-FDE\SC-FDE-VIVADO\units\bpsk_demod\bpsk_demod\bpsk_demod.sim\sim_1\demod_out.txt');

% 确保长度一致
minLen = min(length(tx), length(rx));
tx = tx(1:minLen);
rx = rx(1:minLen);

% 计算错误比特数
errorBits = sum(tx ~= rx);

% 计算误码率（BER）
BER = errorBits / minLen;

% 显示结果
fprintf('总比特数: %d\n', minLen);
fprintf('错误比特数: %d\n', errorBits);
fprintf('误码率 (BER): %.6f\n', BER);
