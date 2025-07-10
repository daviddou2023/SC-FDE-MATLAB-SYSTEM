function output_frame = demodulation(input_modu, index)
% demodulation for IEEE802.11a
% index   -�������Ͳ���
% 1��BPSK
% 2: QPSK
% 3: 8QAM
% 4:16-QAM
% 5:32-QAM
% ��ȡ������ų���
Q_length=length(input_modu);

% ���������ͼ��ʵ�����鲿
QAM_input_I = real(input_modu);
QAM_input_Q = imag(input_modu);

% ��ʼ�����������
output_frame = zeros(1,length(input_modu)*index);

switch index
case 1 % BPSK
    BPSK_Demodu_I = [0 1];      
    QAM_input_I(QAM_input_I > 1) = 1;
    QAM_input_I(QAM_input_I < -1) = -1;
    output_frame = BPSK_Demodu_I(round((QAM_input_I+1)/2) + 1); % -1->0 +1->1
case 2 % QPSK
    QPSK_Demodu_IQ = [0 1];     
    % �޷���������ֹ��������ͼ�߽�
    QAM_input_I(QAM_input_I > 1) = 1;
    QAM_input_I(QAM_input_I < -1) = -1;
    QAM_input_Q(QAM_input_Q > 1) = 1;
    QAM_input_Q(QAM_input_Q < -1) = -1;
    output_frame(1:2:end) = QPSK_Demodu_IQ(round((QAM_input_I+1)/2) + 1);
    output_frame(2:2:end) = QPSK_Demodu_IQ(round((QAM_input_Q+1)/2) + 1);
case 3  % 8-QAM
    remapping=[0 0 0;0 0 1;0 1 0;0 1 1;1 0 0;1 0 1;1 1 0;1 1 1].';
    for i=1:Q_length
    % �ж������ĸ�����
    phase_det=[2<QAM_input_I(i)&0<QAM_input_Q(i) 0<QAM_input_I(i)&QAM_input_I(i)<2&0<QAM_input_Q(i) QAM_input_I(i)<-2&0<QAM_input_Q(i) -2<QAM_input_I(i)&QAM_input_I(i)<0&0<QAM_input_Q(i) QAM_input_I(i)<-2&QAM_input_Q(i)<0 QAM_input_I(i)<0&-2<QAM_input_I(i)&QAM_input_Q(i)<0 2<QAM_input_I(i)&QAM_input_Q(i)<0 0<QAM_input_I(i)&QAM_input_I(i)<2&QAM_input_Q(i)<0];
    a=find(phase_det);
    output_frame((1+(i-1)*3):(3+(i-1)*3))=remapping((1+(a-1)*3):(3+(a-1)*3));
    end
case 4 % 16-QAM
    QAM_16_Demodu_IQ = [0 1 3 2];   %f(m)=(m+3)/2 + 1, so I=-3 ---> 1, I=1 ---> 3
    % �޷���-3~3֮��
    QAM_input_I(QAM_input_I > 3) = 3;
    QAM_input_I(QAM_input_I < -3) = -3;
    QAM_input_Q(QAM_input_Q > 3) = 3;
    QAM_input_Q(QAM_input_Q < -3) = -3;
    tmp = round((QAM_input_I+3)/2) + 1;
    output_frame(1:4:end) = bitget(QAM_16_Demodu_IQ(tmp),2);
    output_frame(2:4:end) = bitget(QAM_16_Demodu_IQ(tmp),1);
    tmp = round((QAM_input_Q+3)/2) + 1;
    output_frame(3:4:end) = bitget(QAM_16_Demodu_IQ(tmp),2);
    output_frame(4:4:end) = bitget(QAM_16_Demodu_IQ(tmp),1);
case  5 % 32-QAM
     remapping=[0 0 0 0 0;0 0 0 0 1;0 0 0 1 0;0 0 0 1 1;0 0 1 0 0;0 0 1 0 1;0 0 1 1 0;0 0 1 1 1;
                0 1 0 0 0;0 1 0 0 1;0 1 0 1 0;0 1 0 1 1;0 1 1 0 0;0 1 1 0 1;0 1 1 1 0;0 1 1 1 1;
                1 0 0 0 0;1 0 0 0 1;1 0 0 1 0;1 0 0 1 1;1 0 1 0 0;1 0 1 0 1;1 0 1 1 0;1 0 1 1 1;
                1 1 0 0 0;1 1 0 0 1;1 1 0 1 0;1 1 0 1 1;1 1 1 0 0;1 1 1 0 1;1 1 1 1 0;1 1 1 1 1].';
    for i=1:Q_length
    phase_det=[4<QAM_input_I(i)&0<QAM_input_Q(i)&QAM_input_Q(i)<2;2<QAM_input_I(i)&QAM_input_I(i)<4&0<QAM_input_Q(i)&QAM_input_Q(i)<2;0<QAM_input_I(i)&QAM_input_I(i)<2&0<QAM_input_Q(i)&QAM_input_Q(i)<2;4<QAM_input_I(i)&2<QAM_input_Q(i)&QAM_input_Q(i)<4;
               2<QAM_input_I(i)&QAM_input_I(i)<4&2<QAM_input_Q(i)&QAM_input_Q(i)<4;0<QAM_input_I(i)&QAM_input_I(i)<2&2<QAM_input_Q(i)&QAM_input_Q(i)<4;2<QAM_input_I(i)&QAM_input_I(i)<4&4<QAM_input_Q(i);0<QAM_input_I(i)&QAM_input_I(i)<2&4<QAM_input_Q(i);
               QAM_input_I(i)<-4&0<QAM_input_Q(i)&QAM_input_Q(i)<2;-4<QAM_input_I(i)&QAM_input_I(i)<-2&0<QAM_input_Q(i)&QAM_input_Q(i)<2;-2<QAM_input_I(i)&QAM_input_I(i)<0&0<QAM_input_Q(i)&QAM_input_Q(i)<2;QAM_input_I(i)<-4&2<QAM_input_Q(i)&QAM_input_Q(i)<4;
               -4<QAM_input_I(i)&QAM_input_I(i)<-2&2<QAM_input_Q(i)&QAM_input_Q(i)<4;-2<QAM_input_I(i)&QAM_input_I(i)<0&2<QAM_input_Q(i)&QAM_input_Q(i)<4;-4<QAM_input_I(i)&QAM_input_I(i)<-2&4<QAM_input_Q(i);-2<QAM_input_I(i)&QAM_input_I(i)<0&4<QAM_input_Q(i);
               QAM_input_I(i)<-4&-2<QAM_input_Q(i)&QAM_input_Q(i)<0;-4<QAM_input_I(i)&QAM_input_I(i)<-2&-2<QAM_input_Q(i)&QAM_input_Q(i)<0;-2<QAM_input_I(i)&QAM_input_I(i)<0&0<QAM_input_Q(i)&QAM_input_Q(i)<0;QAM_input_I(i)<-4&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;
               -4<QAM_input_I(i)&QAM_input_I(i)<-2&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;-2<QAM_input_I(i)&QAM_input_I(i)<0&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;-4<QAM_input_I(i)&QAM_input_I(i)<-2&QAM_input_Q(i)<-4;-2<QAM_input_I(i)&QAM_input_I(i)<0&QAM_input_Q(i)<-4;
               4<QAM_input_I(i)&-2<QAM_input_Q(i)&QAM_input_Q(i)<0;2<QAM_input_I(i)&QAM_input_I(i)<4&-2<QAM_input_Q(i)&QAM_input_Q(i)<0;0<QAM_input_I(i)&QAM_input_I(i)<2&0<QAM_input_Q(i)&QAM_input_Q(i)<0;4<QAM_input_I(i)&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;
               2<QAM_input_I(i)&QAM_input_I(i)<4&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;0<QAM_input_I(i)&QAM_input_I(i)<2&-4<QAM_input_Q(i)&QAM_input_Q(i)<-2;2<QAM_input_I(i)&QAM_input_I(i)<4&QAM_input_Q(i)<-4;0<QAM_input_I(i)&QAM_input_I(i)<2&QAM_input_Q(i)<-4];
    a=find(phase_det);
    output_frame((1+(i-1)*5):(5+(i-1)*5))=remapping((1+(a-1)*5):(5+(a-1)*5));
    end                %5+i 3+i 1+i 5+3*i 3+3*i 1+3*i 3+5*i 1+5*i -5+i -3+i -1+i -5+3*i -3+3*i -1+3*i -3+5*i -1+5*i -5-i -3-i -1-i -5-3*i -3-3*i -1-3*i -3-5*i -1-5*i 5-i 3-i 1-i 5-3*i 3-3*i 1-3*i 3-5*i 1-5*i
case 6 % 64-QAM
    QAM_64_Demodu_IQ = [0 1 3 2 6 7 5 4];   %f(m)=(m+7)/2 + 1, so I=-7 ---> 1, I=1 ---> 5
    QAM_input_I(QAM_input_I > 7) = 7;
    QAM_input_I(QAM_input_I < -7) = -7;
    QAM_input_Q(QAM_input_Q > 7) = 7;
    QAM_input_Q(QAM_input_Q < -7) = -7;
    tmp = round((QAM_input_I+7)/2) + 1;
    output_frame(1:6:end) = bitget(QAM_64_Demodu_IQ(tmp),3);
    output_frame(2:6:end) = bitget(QAM_64_Demodu_IQ(tmp),2);
    output_frame(3:6:end) = bitget(QAM_64_Demodu_IQ(tmp),1);
    tmp = round((QAM_input_Q+7)/2) + 1;
    output_frame(4:6:end) = bitget(QAM_64_Demodu_IQ(tmp),3);
    output_frame(5:6:end) = bitget(QAM_64_Demodu_IQ(tmp),2);
    output_frame(6:6:end) = bitget(QAM_64_Demodu_IQ(tmp),1);
end
