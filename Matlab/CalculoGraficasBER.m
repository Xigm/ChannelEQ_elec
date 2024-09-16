close all, clear all, clc;

mod = [];
CONSTEL = "QPSK";
noiseON = 1;
mode = 8;
canalON = 0;
NUM_SYMB = 100;       % Número de símbols a transmitir
L = 40;
bers = zeros(2,L);
for i = 1:2
    canalON = i-1;
    for SNR = 1:L
        %% Configuración del sistema OFDM
        % CONSTEL = '16QAM';    % Constelación utilizada BPSK, QPSK, 16QAM
        % SNR = 60; 
        verbose = 0;
        % noiseON = 1;
        % canalON = 1;

        %% Variables
        useCarrier = 852*mode+1;
        pilotsLoc = 1:12:useCarrier;
        NFFT = mode*1024;    % Número de portadoras de la OFDM
        Ts = (224e-6)/2048;  % Tiempo de muestreo
        Tsymb = Ts*NFFT;
        NDATA = useCarrier - length(pilotsLoc); % Número de portadoras utilizadas
        
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
        bers(i,SNR) = 10*log10(BER);
        
    end
end

plot(1:L,bers(1,:))
hold on
plot(1:L,bers(2,:))
