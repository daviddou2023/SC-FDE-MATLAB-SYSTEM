N = 64;
for k = 0:N-1
    angle = pi * k^2 / N;
    i_val = round(127 * cos(angle));
    q_val = round(127 * sin(angle));
    fprintf('6''d%d:  begin i_out = %4d; q_out = %4d; end\n', k, i_val, q_val);
end
