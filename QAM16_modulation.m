function Modulated_PHY=QAM16_modulation(Interleaved_PHY_data)
modulated_data = zeros(1,length(Interleaved_PHY_data)/4);
for i = 1:4:length(Interleaved_PHY_data)
    re = 0;
    im = 0*i;
    
    if Interleaved_PHY_data(i) == 1
        re = +1;
    else
        re = -1;
    end
    
    if Interleaved_PHY_data(i+1) == 1
        re = re*1;
    else
        re = re*3;
    end
    
    if Interleaved_PHY_data(i+2) == 1
        im = +1i;
    else
        im = -1i;
    end
    
    if Interleaved_PHY_data(i+3) == 1
        im = im*1;
    else
        im = im*3;
    end
    
    modulated_data( (i+4-1)/4 ) = re + im;
end
Modulated_PHY = ( 1 / sqrt(10) ) * modulated_data;
end