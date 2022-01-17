function Modulated_PHY=QPSK_modulation(Interleaved_PHY_data)
modulated_data = zeros(1,length(Interleaved_PHY_data)/2);
for i = 1:2:length(Interleaved_PHY_data)
    if Interleaved_PHY_data(i) == 1
        if Interleaved_PHY_data(i+1)==1
            modulated_data( (i+1)/2 ) = 1+1i;
        else
            modulated_data( (i+1)/2 ) = 1-1i;
        end
    else
        if Interleaved_PHY_data(i+1)==1
            modulated_data( (i+1)/2 ) = -1+1i;
        else
            modulated_data( (i+1)/2 ) = -1-1i;
        end
    end
end
Modulated_PHY = ( 1 / sqrt(2) ) * modulated_data;
end