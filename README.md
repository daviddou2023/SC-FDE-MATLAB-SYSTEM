# Welcome to SC-FDE Matlab System
本项目系XDU某课程作业，鉴于网上SC-FDE的资料实在少之又少，笔者开源出来仅供参考，欢迎读者star~。此工程中一些函数经过几版的改进，个别函数出于系统的简洁性和普适性仅给出代码，但是在主函数中并未使用，细则在下面都会给出。


512长随机比特生成 -> BPSK调制 -> 数据首尾加UW成帧 -> AWGN信道 -> 去UW序列 -> 频偏纠正 -> FFT -> 信道估计 -> MMSE均衡器 -> IFFT -> BPSK解调 -> 误码率计算



# 文件目录说明

## Datasave.m
将调试过程中单步的输出保存下来，但是在实际调试系统中笔者发现输出显示格式会有点问题，这里建议谨慎使用，最好和主程序中直接printf搭配使用。


## modulation.m 和 demodulation.m

调制和解调函数，包含多种调制方式，本系统这里只使用最简单的BPSK。

## chu.m 和 frank.m

用于生成uw序列。

## interleaving.m 和 interleav_matrix.m 和 de_interleaving.m

交织函数，交织矩阵和解交织，但是本系统未使用这些功能。

## viterbidec.m

维特比译码函数，本系统也未使用。

## 不同版本的输出文件

随着不同功能的增加，作者均备份了历史版本，在这里统一梳理和说明。

- **SCFDE11_14BPSK_code_uninterleave.m** ：使用BPSK、无交织、瑞利衰落信道
-  **SCFDE11_14QPSK_code_uninterleave.m** ：使用QPSK、无交织、瑞利衰落信道
- **AWGN_SCFDE_BPSK_FFT_Direct_NoPhaseoff.m** ：使用BPSK、无交织、AWGN信道、系统FFT函数、无噪声估计和频偏纠正
- **AWGN_SCFDE_BPSK_FFT_My_NoPhaseoff.m**：使用BPSK、无交织、AWGN信道、手搓FFT函数（Cooley-Tukey算法）、无噪声估计和频偏纠正
- **AWGN_SCFDE_BPSK_FFT_My_Phaseoff.m**：使用BPSK、无交织、AWGN信道、手搓FFT函数（Cooley-Tukey算法）、噪声估计和频偏纠正
- **AWGN_SCFDE_BPSK_FFT_My_Phaseoff2.m**：使用BPSK、无交织、AWGN信道、手搓FFT函数（Radix-2算法）、噪声估计和频偏纠正



