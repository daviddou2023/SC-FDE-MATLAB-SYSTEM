% ��ȡ�������ݺͽ�������
tx = load('E:\DaSanXia\SC-FDE\SC-FDE-VIVADO\units\bpsk_mod\bpsk_mod\bpsk_mod.sim\sim_1\random_data.txt');  % ����ʹ�� readmatrix / textscan �����ļ���ʽѡ��
rx = load('E:\DaSanXia\SC-FDE\SC-FDE-VIVADO\units\bpsk_demod\bpsk_demod\bpsk_demod.sim\sim_1\demod_out.txt');

% ȷ������һ��
minLen = min(length(tx), length(rx));
tx = tx(1:minLen);
rx = rx(1:minLen);

% ������������
errorBits = sum(tx ~= rx);

% ���������ʣ�BER��
BER = errorBits / minLen;

% ��ʾ���
fprintf('�ܱ�����: %d\n', minLen);
fprintf('���������: %d\n', errorBits);
fprintf('������ (BER): %.6f\n', BER);
