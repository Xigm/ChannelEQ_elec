clear all;
close all;
%% Configuración del sistema OFDM
NFFT=128;            % Número de portadoras de la OFDM
NCP = 12;            % Número de muestras del prefijo cíclico
NDATA=97;            % Número de portadoras utilizadas
NUM_SYMB = 10;       % Número de símbols a transmitir
SEED=100;            % Semilla para el generador de números aleatorios
CONSTEL = 'QPSK';    % Constelación utilizada BPSK o QPSK
SNR = 10;              % SNR en dB

tic

% Inicializamos el generador de números aleatorios con la semilla
rng(SEED);

% Definición de la constelación
switch CONSTEL
    case 'BPSK'
        M=1;
        C=[1 -1];
    case 'QPSK'
        C=[1+1i 1-1i -1+1i -1-1i]/sqrt(2);
        M=2;
    case '16QAM'
        C = [3 3 3 3 -3 -3 -3 -3 1 1 1 1 -1 -1 -1 -1]+1j.*[3 -3 1 -1 3 -3 1 -1 3 -3 1 -1 3 -3 1 -1];
        % añadir normalización
        C = C/(sqrt(norm(C)));
        M = 4;
end

scatter(real(C),imag(C));
grid
title('Constelación')

%% Tx
% Generación de los bits a transmitir
numbits = NUM_SYMB*NDATA*M;
bits_tx = rand(numbits, 1)>0.5; % numbits x 1

% Bits to symbols
aux  = reshape(bits_tx, M, []).'; % numbits/M x M
symb = zeros(size(aux, 1),1);     % numbits/M x 1
pot2 = kron(ones(length(symb),1),(2.^(0:M-1)));
symb = sum(pot2.*aux,2); % primera columna = lsb 


% Mapper
const_points = C(symb+1); % numbits/M x 1

scatter(real(const_points),imag(const_points));
grid
title('Constelación transmitida')

% Símbolos OFDM en frecuencia (rejilla tiempo frecuencia)
ofdm_freq_rx = zeros(NFFT, NUM_SYMB); % NFFT x NUM_SYMB
ofdm_freq_rx(ceil((NFFT-NDATA)/2)+(1:NDATA),:) = reshape(const_points, NDATA, NUM_SYMB);

figure
stem(abs(ofdm_freq_rx(:,1))); % Pintamos un único símbolo
grid
xlabel('Portadoras OFDM');
ylabel('Amplitud');
title('Espectro OFDM')

% ifftshift permite pasar de una representación del espectro con el f=0 en el
% centro a una representación con f=0 a la izquierda.
% Importante el 1 para hacer la transformación en la dimensión correcta
ofdm_freq_rx=ifftshift(ofdm_freq_rx, 1); % NFFT x NUM_SYMB

% Modulacion OFDM
% Importante el 1 para hacer la transformación en la dimensión correcta
ofdm_time = ifft(ofdm_freq_rx, NFFT, 1); % NFFT x NUM_SYMB

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
pwelch(tx,[],[],[],pi,'maxhold','centered');

%% Canal AWGN

% Ruido
Ps = (tx'*tx)/length(tx); % Potencia de señal
nsr = 10^(-SNR/10);      % Pn/Ps

noise = (randn(size(tx))+1i*randn(size(tx))) / sqrt(2); % Ruido complejo de potencia 1
noise = sqrt(Ps*nsr).*noise; % Ruido complejo de potencia Ps*snr
% Alternativa a las dos líneas anteriores:
% noise = wgn(size(tx,1), 1, Ps*nsr, 'complex');

rx = tx+noise;
figure,plot(abs(tx)),hold on,plot(abs(rx)),plot(abs(noise))
% Return termina la ejecución del script. Las líneas de después no se
% ejecutarán

%% Receptor
% Paso de serie a paralelo
ofdm_time_rx = reshape(rx,NFFT+NCP,NUM_SYMB);

% Extracción del prefijo ciclico
ofdm_time_rx = ofdm_time_rx(NCP+1:end, :);

% FFT para desortogonalizar las portadoras 
ofdm_freq_rx = fft(ofdm_time_rx, NFFT, 1);

% Colocacción de los ceros en sus posiciones originales
ofdm_freq_rx = fftshift(ofdm_freq_rx, 1); 

% Descarte de los zeros y reestructuración para poner simbolos por separado
ofdm_freq_rx = ofdm_freq_rx(ceil((NFFT-NDATA)/2)+(1:NDATA),:);

% Obtención símbolos de la constelación
rx_constel = reshape(ofdm_freq_rx,1,NDATA*NUM_SYMB);
figure,plot(rx_constel,'.')

% Demap
switch CONSTEL
    case 'BPSK'
        bits_rx = rx_constel<0;
    case 'QPSK'
        bits_rx = zeros(1,length(rx_constel)*2);
        bits_rx(2:2:end) = real(rx_constel)<0;
        bits_rx(1:2:end) = imag(rx_constel)<0;
    case '16QAM'
        Xcx = mean(max(abs(C))-min(abs(C))); 
        Xcy = Xcx;
        bits_rx = zeros(1,length(rx_constel)*M);
        bits_rx(3:4:end) = real(rx_constel)<0;
        bits_rx(1:4:end) = imag(rx_constel)<0;
        bits_rx(4:4:end) = abs(real(rx_constel))-Xcx<0;
        bits_rx(2:4:end) = abs(imag(rx_constel))-Xcy<0;
end

BER = mean(xor(bits_rx, bits_tx.'));
fprintf(1, 'BER = %f\n', BER);
toc
