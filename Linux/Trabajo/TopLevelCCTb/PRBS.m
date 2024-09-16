function pilotos = PRBS(NUM_SYMB,useCarrier)
    pilotsLoc = 1:12:useCarrier;
    PRBSvar = ones(1,11);
    pilotos = [];
    limit = length(pilotsLoc)*NUM_SYMB;
    for i = 1:(limit)
        cuenta = xor(PRBSvar(end-2), PRBSvar(end));
        Salida = PRBSvar(end); 
        PRBSvar = circshift(PRBSvar,1);
        PRBSvar(1) = cuenta;
        pilotos = [pilotos, Salida];
    end
    pilotos = (pilotos-0.5)*2;
    
end 