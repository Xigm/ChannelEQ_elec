function [muestras, hest, v, pilotosReturn,ofdm_freq_rx_eq] = GoldenChannelEstim(mode,CONSTEL,SNR,noiseON,canalON,NUM_SYMB,SEED)

    %% Configuración del sistema OFDM
    % mode = 2;
    % CONSTEL = '16QAM';   % Constelación utilizada BPSK, QPSK, 16QAM
    % SNR = 60; 
        
    if nargin == 0
        mode = 2;
        CONSTEL = '16QAM';   % Constelación utilizada BPSK, QPSK, 16QAM
        SNR = 60;
        noiseON = 1;
        canalON = 1;
        SEED = 100;
        NUM_SYMB = 1;
    end


    %% Variables
    useCarrier = 852*mode+1;
    pilotsLoc = 1:12:useCarrier;
    NFFT = mode*1024;    % Número de portadoras de la OFDM
    Ts = (224e-6)/2048;  % Tiempo de muestreo
    Tsymb = Ts*NFFT;
    NDATA = useCarrier - length(pilotsLoc); % Número de portadoras utilizadas
%     NUM_SYMB = 10;       % Número de símbols a transmitir
    NCP = NFFT/32;       % Número de muestras del prefijo cíclico
    % SEED=100;            % Semilla para el generador de números aleatorios

    %% Transmisión
    [tx,bits_tx,pilotosReturn] = OFDM_TX_DVT(NFFT,NCP,useCarrier,NUM_SYMB,SEED,CONSTEL,SNR,0);


    %% Channel
    canal = [];

    if canalON
        [tx,canal] = channel(tx,Tsymb,NFFT,0);
    end
    
    canal = ones(1,useCarrier);
    
    %% Ruido

    if noiseON
        tx = noise(tx,SNR);
    end
    
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
    
    % Colocación de los pilotos
    pilotsLoc = 1:12:useCarrier;
    NDATA = useCarrier - length(pilotsLoc);
    dataLoc = setdiff(1:useCarrier,pilotsLoc);

%     PRBS = ones(1,11);
%     pilotos = [];
%     limit = length(pilotsLoc)*NUM_SYMB;
%     for i = 1:(limit)
%         cuenta = xor(PRBS(end-2), PRBS(end));
%         Salida = PRBS(end); 
%         PRBS = circshift(PRBS,1);
%         PRBS(1) = cuenta;
%         pilotos = [pilotos, Salida];
%     end
%     pilotos = (pilotos-0.5)*2;

    PRBS = ones(1,11);
    limit = length(pilotsLoc)*NUM_SYMB;
    pilotos = zeros(1,limit);
    for i = 1:(limit)
        cuenta = xor(PRBS(end-2), PRBS(end));
        Salida = PRBS(end); 
        PRBS = circshift(PRBS,1);
        PRBS(1) = cuenta;
        pilotos(i) = Salida;
    end
    pilotos = (pilotos-0.5)*2;
    
    %% Receptor
    % Paso de serie a paralelo
    ofdm_time_rx = reshape(tx,NFFT+NCP,NUM_SYMB);

    % Extracción del prefijo ciclico
    ofdm_time_rx = ofdm_time_rx(NCP+1:end, :);

    % FFT para desortogonalizar las portadoras 
    ofdm_freq_rx = fft(ofdm_time_rx, NFFT, 1);

    % Colocacción de los ceros en sus posiciones originales
    ofdm_freq_rx = fftshift(ofdm_freq_rx, 1); 

    % Descarte de los zeros y reestructuración para poner simbolos por separado
    ofdm_freq_rx_o = ofdm_freq_rx;
    ofdm_freq_rx_pilots = ofdm_freq_rx_o(ceil((NFFT-useCarrier)/2)+(pilotsLoc),:);
    
    % Get samples to use the golden file
    muestras = ofdm_freq_rx_o(ceil((NFFT-useCarrier)/2)+(1:useCarrier),:);
    
    % Cálculo de la hest
    hest = ofdm_freq_rx_pilots./((4/3)*reshape(pilotos,length(pilotsLoc),NUM_SYMB));
    
    ofdm_freq_rx_eq = zeros(useCarrier,NUM_SYMB);
    % Interpolar h
    for i = 1:NUM_SYMB
        y = zeros(length(pilotsLoc)-1,2);
        y(:,2) = hest(1:end-1,i);
        y(:,1) = (hest(2:end,i)-hest(1:end-1,i))/12;
        v = repmat((0:11),length(y),1);
        v = v.*kron(y(:,1),ones(1,12)); 
        v = v+kron(y(:,2),ones(1,12));
        v = reshape(v.',[],1);
        v = [v; hest(i,end)];
        ofdm_freq_rx_eq(:,i) = ofdm_freq_rx_o(ceil((NFFT-useCarrier)/2)+(1:useCarrier),i)./v;
    end
    
%     ejeX = (-NFFT/2:NFFT/2-1)/Tsymb;
    
    ofdm_freq_rx = ofdm_freq_rx_eq(dataLoc,:);
    
    % Obtención símbolos de la constelación
%     rx_constel = reshape(ofdm_freq_rx,1,NDATA*NUM_SYMB);
    
    
%     % Demap
%     switch CONSTEL
%         case 'BPSK'
%             bits_rx = rx_constel<0;
%         case 'QPSK'
%             bits_rx = zeros(1,length(rx_constel)*2);
%             bits_rx(2:2:end) = real(rx_constel)<0;
%             bits_rx(1:2:end) = imag(rx_constel)<0;
%         case '16QAM'
%             Xcx = mean(max(abs(C))-min(abs(C))); 
%             Xcy = Xcx;
%             bits_rx = zeros(1,length(rx_constel)*M);
%             bits_rx(3:4:end) = real(rx_constel)<0;
%             bits_rx(1:4:end) = imag(rx_constel)<0;
%             bits_rx(4:4:end) = abs(real(rx_constel))-Xcx<0;
%             bits_rx(2:4:end) = abs(imag(rx_constel))-Xcy<0;
%     end
end
