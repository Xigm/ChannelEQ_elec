function bits_rx = OFDM_RX(rx,NFFT,NCP,NDATA,NUM_SYMB,SEED,CONSTEL,verbose)
    
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
    
    if verbose
        figure
        plot(rx_constel,'.')
    end
    
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
end
