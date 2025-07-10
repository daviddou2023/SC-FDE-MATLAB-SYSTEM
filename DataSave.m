function ret = DataSave(fn, var, len, opt)
% DataSave - 用于将数据保存到文件的函数。
% 输入：
%   fn   - 文件名字符串，指定保存数据的文件路径。
%   var  - 要保存的数据变量，通常是一个数组或向量。
%   len  - 数据的长度，指定保存的元素个数。
%   opt  - 保存选项，0 表示不保存数据，非零值表示保存数据。
% 输出：
%   ret  - 返回值，1 表示保存成功，0 表示保存失败或未进行保存。

% 检查是否需要保存数据
if opt
    % 打开文件进行写操作
    fid = fopen(fn, 'w');  % 打开文件 fn，'w'表示写入模式
    if fid  % 如果文件成功打开
        % 遍历数据并逐个写入文件
        for i = 1:len
            % 将数据 var(i) 写入文件，每个数据占一行
            fprintf(fid, '%.6f\n', var(i));  % 写入整数数据，格式为有符号整数 %d
        end
        % 关闭文件
        fclose(fid);
        % 返回 1 表示保存成功
        ret = 1;
    else
        % 如果文件打开失败，返回 0
        ret = 0;
    end
else
    % 如果 opt 为 0，则不保存数据，返回 0
    ret = 0;
end
