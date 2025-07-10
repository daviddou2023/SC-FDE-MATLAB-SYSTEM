% 输入参数：
% input_frame：输入比特流（由0和1组成的向量）
% index：调制方式的索引
%         1 --- BPSK
%         2 --- QPSK
%         4 --- 16QAM
%         6 --- 64QAM
%         其他值则表示错误

function output_modu = modulation(input_frame, index)

% 根据调制方式index，计算需要多少组比特进行调制（每组比特对应一个符号）
f_length = length(input_frame) / index;

% 初始化I路（同相分量）和Q路（正交分量）
QAM_input_I = zeros(1, f_length);
QAM_input_Q = zeros(1, f_length);

% MATLAB数组索引从1开始，因此在查表映射时需要+1处理

switch index
    case 1  % BPSK（二进制相移键控）
        BPSK_I = [-1 1];  % 对应IEEE802.11a中Table 82的BPSK调制，0映射为-1，1映射为1
        QAM_input_I = BPSK_I(input_frame + 1);  % 输入为0或1，加1后索引为1或2
        output_modu = QAM_input_I;  % BPSK只有I路分量，无Q路
        
    case 2  % QPSK（四相位相移键控）
        QPSK_IQ = [-1 1];  % 同样使用[-1, 1]表示QPSK的I和Q分量
        QAM_input_I = QPSK_IQ(input_frame(1:2:end) + 1);  % 奇数位作为I路
        QAM_input_Q = QPSK_IQ(input_frame(2:2:end) + 1);  % 偶数位作为Q路
        output_modu = QAM_input_I + 1i * QAM_input_Q;  % 合成复数信号：I + jQ
        
    case 3  % 8QAM（但这里的index=3不是标准规定，IEEE中无此定义，可能是自定义）
        % 使用事先定义好的8QAM星座图（自定义）
        % 每3个比特确定一个符号，组合为3位二进制数转换为十进制作为索引
        mapping = [3+1i, 1+1i, -3+1i, -1+1i, -3-1i, -1-1i, 3-1i, 1-1i];
        % input_frame的每三位转换成一个整数作为索引（例如101 -> 5）
        output_modu = mapping(input_frame(1:3:end)*4 + input_frame(2:3:end)*2 + input_frame(3:3:end) + 1);
        
    case 4  % 16QAM（16阶正交幅度调制）
        QAM_16_IQ = [-3 -1 3 1];  % IEEE802.11a Table 84定义的星座图映射值
        % 低两位比特映射为I分量，高两位比特映射为Q分量
        QAM_input_I = QAM_16_IQ(input_frame(1:4:end)*2 + input_frame(2:4:end) + 1);
        QAM_input_Q = QAM_16_IQ(input_frame(3:4:end)*2 + input_frame(4:4:end) + 1);
        output_modu = QAM_input_I + 1i * QAM_input_Q;
        
    case 5  % 32QAM（不是标准IEEE定义的64QAM，但可自定义）
        % 自定义32个符号点构成的映射表，手动定义星座图
        mapping = [5+1i 3+1i 1+1i 5+3*1i 3+3*1i 1+3*1i 3+5*1i 1+5*1i ...
                  -5+1i -3+1i -1+1i -5+3*1i -3+3*1i -1+3*1i -3+5*1i -1+5*1i ...
                  -5-1i -3-1i -1-1i -5-3*1i -3-3*1i -1-3*1i -3-5*1i -1-5*1i ...
                   5-1i 3-1i 1-1i 5-3*1i 3-3*1i 1-3*1i 3-5*1i 1-5*1i];
        % 每5位比特决定一个符号（对应32个星座点）
        output_modu = mapping(input_frame(1:5:end)*16 + input_frame(2:5:end)*8 + ...
                              input_frame(3:5:end)*4 + input_frame(4:5:end)*2 + ...
                              input_frame(5:5:end) + 1);
                              
    case 6  % 64QAM（64阶正交幅度调制）
        QAM_64_IQ = [-7 -5 -1 -3 7 5 1 3];  % IEEE802.11a Table 85中64QAM星座图
        % 先映射I路（前3位）
        QAM_input_I = QAM_64_IQ(input_frame(1:6:end)*4 + input_frame(2:6:end)*2 + input_frame(3:6:end) + 1);
        % 再映射Q路（后3位）
        QAM_input_Q = QAM_64_IQ(input_frame(4:6:end)*4 + input_frame(5:6:end)*2 + input_frame(6:6:end) + 1);
        output_modu = QAM_input_I + 1i * QAM_input_Q;
end
