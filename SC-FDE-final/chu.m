function uw = chu(u)
% 这是一个生成 Chu 序列的函数
% 输入参数：
%    u - 一个正整数，表示序列的长度
% 输出参数：
%    uw - 生成的 Chu 序列（复数数组）

% 预分配长度为64的一维零向量（这里虽然初始化为64，但后面按u大小赋值）
uw = zeros(1, 64);

% 计算相位序列 Q1
for k = 0:u-1
    % Q1(k+1)：存储每个k对应的相位值
    % 注意MATLAB数组索引从1开始，所以这里用k+1
    Q1(k+1) = pi * k^2 / u;
    %fprintf('6''d%d:  begin i_out = %4d; q_out = %4d; end\n', k, i_val, q_val);
end

% 生成实部（I）和虚部（Q）
I = cos(Q1); % 实部为相位角Q1的余弦值
Q = sin(Q1); % 虚部为相位角Q1的正弦值

% 构建最终的Chu序列，注意 MATLAB 中 i 代表虚数单位
uw = I + 1i * Q;

end
