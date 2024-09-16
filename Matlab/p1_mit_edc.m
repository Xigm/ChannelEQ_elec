clear all;
close all;
%% Configuración del sistema OFDM
NFFT=128;            % Número de portadoras de la OFDM
NCP = 12;            % Número de muestras del prefijo cíclico
NDATA=97;            % Número de portadoras utilizadas
NUM_SYMB = 10;       % Número de símbols a transmitir
SEED=100;            % Semilla para el generador de números aleatorios
CONSTEL = 'BPSK';    % Constelación utilizada BPSK o QPSK
SNR=-50;             % SNR en dB

tic

% Inicializamos el generador de números aleatorios con la semilla
rng(SEED);

% Definición de la constelación
switch CONSTEL
    case 'BPSK'
        M=1;
        C=[1 -1];
    case 'QPSK'
        C=[1+1i 1-1i -1+1i -1-1i];
        M=2;      
end

scatterplot(C);
grid
title('Constelación')

%% Receptor
% Generación de los bits a transmitir
numbits = NUM_SYMB*NDATA*M;
bits_tx = rand(numbits, 1)>0.5; % numbits x 1

% Bits to symbols
aux  = reshape(bits_tx, M, []).'; % numbits/M x M
symb = zeros(size(aux, 1),1);     % numbits/M x 1
for k=1:M
    symb = symb + (2^(k-1))*aux(:,k); % primera columna = lsb 
end

% Mapper
const_points = C(symb+1); % numbits/M x 1

scatterplot(const_points);
grid
title('Constelación transmitida')

% Símbolos OFDM en frecuencia (rejilla tiempo frecuencia)
ofdm_freq = zeros(NFFT, NUM_SYMB); % NFFT x NUM_SYMB
ofdm_freq(ceil((NFFT-NDATA)/2)+(1:NDATA),:) = reshape(const_points, NDATA, NUM_SYMB);

figure
stem(abs(ofdm_freq(:,1))); % Pintamos un único símbolo
grid
xlabel('Portadoras OFDM');
ylabel('Amplitud');
title('Espectro OFDM')

% ifftshift permite pasar de una representación del espectro con el f=0 en el
% centro a una representación con f=0 a la izquierda.
% Importante el 1 para hacer la transformación en la dimensión correcta
ofdm_freq=ifftshift(ofdm_freq, 1); % NFFT x NUM_SYMB

% Modulacion OFDM
% Importante el 1 para hacer la transformación en la dimensión correcta
ofdm_time = ifft(ofdm_freq, NFFT, 1); % NFFT x NUM_SYMB

% Prefijo cíclico de forma matricial
ofdm_time = [ofdm_time(end-(NCP-1):end, :); ofdm_time];

% Salida secuencial (el : lee por columnas)
tx = ofdm_time(:); % (NFFT+NCP)·NUM_SYMB x 1

figure
plot(real(tx), 'b-');
hold on
plot(imag(tx), 'r-');
xlabel('Muestras temporales');
ylabel('Amplitud');
legend('real', 'imag');
grid
title('Señal OFDM en el tiempo')

% Espectro de la señal transmitida
figure
pwelch(tx);

%% Canal AWGN

% Ruido
Ps = mean(tx.*conj(tx)); % Potencia de señal
nsr = 10^(-SNR/10);      % Pn/Ps

noise = (randn(size(tx))+1i*randn(size(tx))) / sqrt(2); % Ruido complejo de potencia 1
noise = sqrt(Ps*nsr).*noise; % Ruido complejo de potencia Ps*snr
% Alternativa a las dos líneas anteriores:
% noise = wgn(size(tx,1), 1, Ps*nsr, 'complex');

rx = tx+noise;

% Return termina la ejecución del script. Las líneas de después no se
% ejecutarán
return

%% Receptor
% TO-DO: Receptor (operaciones inversas al transmisor)

% Demap
switch CONSTEL
    case 'BPSK'
        bits_rx = rx_constel<0;
    case 'QPSK'
        bits_rx = zeros(1,length(rx_constel)*2);
        bits_rx(2:2:end) = real(rx_constel)<0;
        bits_rx(1:2:end) = imag(rx_constel)<0;
end

BER = mean(xor(bits_rx, bits_tx.'));
fprintf(1, 'BER = %f\n', BER);
toc
