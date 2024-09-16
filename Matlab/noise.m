function rx = noise(tx,SNR)

Ps = (tx'*tx)/length(tx); % Potencia de señal
nsr = 10^(-SNR/10);      % Pn/Ps

noise = (randn(size(tx))+1i*randn(size(tx))) / sqrt(2); % Ruido complejo de potencia 1
noise = sqrt(Ps*nsr).*noise; % Ruido complejo de potencia Ps*snr
% Alternativa a las dos líneas anteriores:
% noise = wgn(size(tx,1), 1, Ps*nsr, 'complex');

rx = tx+noise;
end