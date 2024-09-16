%% Configuración del sistema OFDM
NFFT=128;            % Número de portadoras de la OFDM
NCP = 12;            % Número de muestras del prefijo cíclico
NDATA=97;            % Número de portadoras utilizadas
NUM_SYMB = 10;       % Número de símbols a transmitir
SEED=100;            % Semilla para el generador de números aleatorios
CONSTEL = 'QPSK';    % Constelación utilizada BPSK o QPSK
SNR = 10; 
verbose = 1;

[tx,bits_tx] = OFDM_TX(NFFT,NCP,NDATA,NUM_SYMB,SEED,CONSTEL,SNR,verbose);
bits_rx = OFDM_RX(tx,NFFT,NCP,NDATA,NUM_SYMB,SEED,CONSTEL,verbose)

BER = mean(xor(bits_rx, bits_tx.'));
fprintf(1, 'BER = %f\n', BER);
toc