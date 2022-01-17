function Inter_DATA = QPSK_demodulation(Mod_DATA)
Modulated_DATA = sqrt(2)*Mod_DATA;
Inter_DATA = zeros(1,length(Modulated_DATA)*2);
for a = 1:length(Modulated_DATA)
    b = (a-1)*2 +1;
    if real(Modulated_DATA(a)) > 0
        Inter_DATA(b)   = 1;
    else
        Inter_DATA(b)   = 0;
    end
    
    if imag(Modulated_DATA(a)) > 0
        Inter_DATA(b+1) = 1;
    else
        Inter_DATA(b+1) = 0;
    end
    
end

end