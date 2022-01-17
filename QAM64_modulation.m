function Modulated_PHY=QAM64_modulation(Interleaved_PHY_data)
modulated = zeros(1,length(Interleaved_PHY_data)/6);
for i = 1:6:length(Interleaved_PHY_data)
    re = 0;
    im = 0*i;
    if Interleaved_PHY_data(i) == 1
        re = +1;
    else
        re = -1;
    end
    
    if Interleaved_PHY_data(i+1) == 1
        if Interleaved_PHY_data(i+2) == 1
            re = re*3;
        else
            re = re*1;
        end
    else
        if Interleaved_PHY_data(i+2) == 1
            re = re*5;
        else
            re = re*7;
        end
    end
    
    if Interleaved_PHY_data(i+3) == 1
        im = +1i;
    else
        im = -1i;
    end
    
    if Interleaved_PHY_data(i+4) == 1
        if Interleaved_PHY_data(i+5) == 1
            im = im*3;
        else
            im = im*1;
        end
    else
        if Interleaved_PHY_data(i+5) == 1
            im = im*5;
        else
            im = im*7;
        end
    end
    
    modulated( (i+6-1)/6 ) = re + im;
end
Modulated_PHY = ( 1 / sqrt(42) ) * modulated;
end