% ���������
% input_frame���������������0��1��ɵ�������
% index�����Ʒ�ʽ������
%         1 --- BPSK
%         2 --- QPSK
%         4 --- 16QAM
%         6 --- 64QAM
%         ����ֵ���ʾ����

function output_modu = modulation(input_frame, index)

% ���ݵ��Ʒ�ʽindex��������Ҫ��������ؽ��е��ƣ�ÿ����ض�Ӧһ�����ţ�
f_length = length(input_frame) / index;

% ��ʼ��I·��ͬ���������Q·������������
QAM_input_I = zeros(1, f_length);
QAM_input_Q = zeros(1, f_length);

% MATLAB����������1��ʼ������ڲ��ӳ��ʱ��Ҫ+1����

switch index
    case 1  % BPSK�����������Ƽ��أ�
        BPSK_I = [-1 1];  % ��ӦIEEE802.11a��Table 82��BPSK���ƣ�0ӳ��Ϊ-1��1ӳ��Ϊ1
        QAM_input_I = BPSK_I(input_frame + 1);  % ����Ϊ0��1����1������Ϊ1��2
        output_modu = QAM_input_I;  % BPSKֻ��I·��������Q·
        
    case 2  % QPSK������λ���Ƽ��أ�
        QPSK_IQ = [-1 1];  % ͬ��ʹ��[-1, 1]��ʾQPSK��I��Q����
        QAM_input_I = QPSK_IQ(input_frame(1:2:end) + 1);  % ����λ��ΪI·
        QAM_input_Q = QPSK_IQ(input_frame(2:2:end) + 1);  % ż��λ��ΪQ·
        output_modu = QAM_input_I + 1i * QAM_input_Q;  % �ϳɸ����źţ�I + jQ
        
    case 3  % 8QAM���������index=3���Ǳ�׼�涨��IEEE���޴˶��壬�������Զ��壩
        % ʹ�����ȶ���õ�8QAM����ͼ���Զ��壩
        % ÿ3������ȷ��һ�����ţ����Ϊ3λ��������ת��Ϊʮ������Ϊ����
        mapping = [3+1i, 1+1i, -3+1i, -1+1i, -3-1i, -1-1i, 3-1i, 1-1i];
        % input_frame��ÿ��λת����һ��������Ϊ����������101 -> 5��
        output_modu = mapping(input_frame(1:3:end)*4 + input_frame(2:3:end)*2 + input_frame(3:3:end) + 1);
        
    case 4  % 16QAM��16���������ȵ��ƣ�
        QAM_16_IQ = [-3 -1 3 1];  % IEEE802.11a Table 84���������ͼӳ��ֵ
        % ����λ����ӳ��ΪI����������λ����ӳ��ΪQ����
        QAM_input_I = QAM_16_IQ(input_frame(1:4:end)*2 + input_frame(2:4:end) + 1);
        QAM_input_Q = QAM_16_IQ(input_frame(3:4:end)*2 + input_frame(4:4:end) + 1);
        output_modu = QAM_input_I + 1i * QAM_input_Q;
        
    case 5  % 32QAM�����Ǳ�׼IEEE�����64QAM�������Զ��壩
        % �Զ���32�����ŵ㹹�ɵ�ӳ����ֶ���������ͼ
        mapping = [5+1i 3+1i 1+1i 5+3*1i 3+3*1i 1+3*1i 3+5*1i 1+5*1i ...
                  -5+1i -3+1i -1+1i -5+3*1i -3+3*1i -1+3*1i -3+5*1i -1+5*1i ...
                  -5-1i -3-1i -1-1i -5-3*1i -3-3*1i -1-3*1i -3-5*1i -1-5*1i ...
                   5-1i 3-1i 1-1i 5-3*1i 3-3*1i 1-3*1i 3-5*1i 1-5*1i];
        % ÿ5λ���ؾ���һ�����ţ���Ӧ32�������㣩
        output_modu = mapping(input_frame(1:5:end)*16 + input_frame(2:5:end)*8 + ...
                              input_frame(3:5:end)*4 + input_frame(4:5:end)*2 + ...
                              input_frame(5:5:end) + 1);
                              
    case 6  % 64QAM��64���������ȵ��ƣ�
        QAM_64_IQ = [-7 -5 -1 -3 7 5 1 3];  % IEEE802.11a Table 85��64QAM����ͼ
        % ��ӳ��I·��ǰ3λ��
        QAM_input_I = QAM_64_IQ(input_frame(1:6:end)*4 + input_frame(2:6:end)*2 + input_frame(3:6:end) + 1);
        % ��ӳ��Q·����3λ��
        QAM_input_Q = QAM_64_IQ(input_frame(4:6:end)*4 + input_frame(5:6:end)*2 + input_frame(6:6:end) + 1);
        output_modu = QAM_input_I + 1i * QAM_input_Q;
end
