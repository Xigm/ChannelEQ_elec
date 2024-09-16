close all, clear all, clc;

%% Configuración del sistema OFDM
mode = 8;
CONSTEL = '16QAM';    % Constelación utilizada BPSK, QPSK, 16QAM
SNR = 60; 
verbose = 0;
noiseON = 0;
canalON = 0;

%% Variables
useCarrier = 852*mode+1;
pilotsLoc = 1:12:useCarrier;
NFFT = mode*1024;    % Número de portadoras de la OFDM
Ts = (224e-6)/2048;  % Tiempo de muestreo
Tsymb = Ts*NFFT;
NDATA = useCarrier - length(pilotsLoc); % Número de portadoras utilizadas
NUM_SYMB = 10;       % Número de símbols a transmitir
NCP = NFFT/32;       % Número de muestras del prefijo cíclico
SEED=100;            % Semilla para el generador de números aleatorios

%% Transmisión
[tx,bits_tx] = OFDM_TX_DVT(NFFT,NCP,useCarrier,NUM_SYMB,SEED,CONSTEL,SNR,verbose);

%% Channel

if canalON
    [tx,canal] = channel(tx,Tsymb,NFFT,verbose);
else
    canal = [];
end

%% Ruido

if noiseON
    tx = noise(tx,SNR);
end

%% Recepción
if isempty(canal)
    canal = ones(1,NFFT);
end
bits_rx = OFDM_RX_DVT(tx,NFFT,NCP,useCarrier,NUM_SYMB,SEED,CONSTEL,verbose,canal);

BER = mean(xor(bits_rx, bits_tx.'));
fprintf(1, 'BER = %f\n', BER);
toc
