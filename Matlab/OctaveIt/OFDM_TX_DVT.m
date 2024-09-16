function [tx,bits_tx,pilotosReturn] = OFDM_TX_DVT(NFFT,NCP,useCarrier,NUM_SYMB,SEED,CONSTEL,SNR,verbose)

    if nargin == 0
        %% Configuración del sistema OFDM
        NFFT=128;            % Número de portadoras de la OFDM
        NCP = 12;            % Número de muestras del prefijo cíclico
        NDATA=97;            % Número de portadoras utilizadas
        NUM_SYMB = 10;       % Número de símbols a transmitir
        SEED=100;            % Semilla para el generador de números aleatorios
        CONSTEL = 'QPSK';    % Constelación utilizada BPSK o QPSK
        SNR = 10;            % SNR en dB
    end
    tic
    
    % Colocación de los pilotos
    pilotsLoc = 1:12:useCarrier;
    NDATA = useCarrier - length(pilotsLoc);
    dataLoc = setdiff(1:useCarrier,pilotsLoc);
    
    % Secuencia de pilotos
%     PRBS = ones(1,11);
%     pilotos = [];
%     limit = useCarrier*NUM_SYMB+11*NUM_SYMB;
%     for i = 1:(limit)
%         cuenta = xor(PRBS(end-2), PRBS(end));
%         Salida = PRBS(end); 
%         PRBS = circshift(PRBS,1);
%         PRBS(1) = cuenta;
%         if (find(i == 1:12:(limit)) ~= 0)
%            pilotos = [pilotos, Salida];
%         end
%     end
%     pilotos = (pilotos-0.5)*2;
    
    PRBS = ones(1,11);
    pilotos = [];
    limit = length(pilotsLoc)*NUM_SYMB;
    for i = 1:(limit)
        cuenta = xor(PRBS(end-2), PRBS(end));
        Salida = PRBS(end); 
        PRBS = circshift(PRBS,1);
        PRBS(1) = cuenta;
        pilotos = [pilotos, Salida];
    end
    pilotos = (pilotos-0.5)*2;
    pilotosReturn = pilotos;
    % Inicializamos el generador de números aleatorios con la semilla
    % rng(SEED);

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
    
    if verbose
        scatter(real(C),imag(C));
        grid
        title('Constelación')
    end
    
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

    if verbose
        scatter(real(const_points),imag(const_points));
        grid
        title('Constelación transmitida')
    end
    
    % Símbolos OFDM en frecuencia (rejilla tiempo frecuencia)
    ofdm_freq_rx = zeros(NFFT, NUM_SYMB); % NFFT x NUM_SYMB
    ofdm_freq_rx(ceil((NFFT-useCarrier)/2)+(pilotsLoc),:) = (4/3)*reshape(pilotos,length(pilotsLoc),NUM_SYMB);
    ofdm_freq_rx(ceil((NFFT-useCarrier)/2)+(dataLoc),:) = reshape(const_points, NDATA, NUM_SYMB);

    if verbose
        figure
        stem(abs(ofdm_freq_rx(:,1))); % Pintamos un único símbolo
        grid
        xlabel('Portadoras OFDM');
        ylabel('Amplitud');
        title('Espectro OFDM')
    end
    
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

    if verbose
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
    end
end
