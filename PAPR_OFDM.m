clc;
clear all;
SNR_dB=0:2:25;
SNR=10.^(SNR_dB/10);
N=32;
N_Sim=1e4;
FFT_length=N;
CP_length=16;

Mod_type='BPSK'; %BPSK, QPSK, 16QAM, 64QAM, or 256QAM

switch Mod_type
    case {'BPSK'}
        Nb=1;
        BPSK_Mod=comm.PSKModulator(2, 'BitInput', true, 'PhaseOffset', 0);
        BPSK_Demod=comm.PSKDemodulator(2, 'BitOutput', true, 'PhaseOffset', 0);        
    case {'QPSK'}
        Nb=2;
        QPSK_Mod=comm.PSKModulator(4, 'BitInput', true, 'PhaseOffset', pi/4);
        QPSK_Demod=comm.PSKDemodulator(4, 'BitOutput', true, 'PhaseOffset', pi/4);
    case {'16QAM'}
        Nb=4;
        QAM16_Mod=comm.RectangularQAMModulator(16, 'BitInput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');
        QAM16_Demod=comm.RectangularQAMDemodulator(16, 'BitOutput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');
    case {'64QAM'}
        Nb=6;
        QAM64_Mod=comm.RectangularQAMModulator(64, 'BitInput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');
        QAM64_Demod=comm.RectangularQAMDemodulator(64, 'BitOutput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');        
    case {'256QAM'}
        Nb=8;
        QAM256_Mod=comm.RectangularQAMModulator(256, 'BitInput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');
        QAM256_Demod=comm.RectangularQAMDemodulator(256, 'BitOutput', true,....
            'NormalizationMethod','Average power','SymbolMapping','Gray');
end


    
for k=1:N_Sim
d=round(rand(N*Nb, 1));    

switch Mod_type
    case {'BPSK'}
    X=step(BPSK_Mod, d);    
    case {'QPSK'}
    X=step(QPSK_Mod, d);        
    case {'16QAM'}
    X=step(QAM16_Mod, d);        
    case {'64QAM'}
    X=step(QAM64_Mod, d);                
     case {'256QAM'}
    X=step(QAM256_Mod, d);        
end    

x=sqrt(1)*idct(X);  %%% bank of Modulators
max_value=max(x.*conj(x));
MSE=(x'*x)/length(x);
PAPR=max_value/MSE;
%PAPR_dB(k)=10*log10(PAPR);

        w_1 = (x').';
       meanSquareValue2 =  w_1'*w_1/length(w_1);
       peakValue2 = max((w_1).*conj(w_1));
       PAPR_Symbol2 = peakValue2/meanSquareValue2; 
       PAPR_TxSamples_1_after = 10*log10( PAPR_Symbol2);
      PAPR_dB(k) = PAPR_TxSamples_1_after; 
      
end
[N1,X1]=hist(PAPR_dB,[0:0.5:30]);
semilogy(X1,1-cumsum(N1)/max(cumsum(N1)),'-ok','linewidth',1.5);hold on
xlabel('PAPR'); ylabel('CCDF');
grid



