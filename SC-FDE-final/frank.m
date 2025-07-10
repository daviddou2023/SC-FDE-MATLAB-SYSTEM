function uw = frank(u)

% 预分配长度为64的一维零向量（虽然初始化了64，但后面根据u大小赋值）
uw = zeros(1, 64);

% 双重循环生成相位矩阵
% Frank序列是基于sqrt(u)阶正方矩阵展开的
for p = 0:sqrt(u)-1
    for q = 0:sqrt(u)-1
        % Q(p+q*sqrt(u)+1)：
        %   每一个 (p,q) 坐标对应到一维数组的位置

        %   计算每个元素对应的相位值，公式是：2*pi*p*q/sqrt(u)
        Q(p + q * sqrt(u) + 1) = 2 * pi * p * q / sqrt(u);
    end
end
% 生成 Frank 序列的实部和虚部
I = cos(Q);  % 实部：相位角Q的余弦值
Q = sin(Q);  % 虚部：相位角Q的正弦值
% 构建最终的 Frank 序列
uw = I + 1i * Q;

end
