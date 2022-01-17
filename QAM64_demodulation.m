function Inter_DATA = QAM64_demodulation(Mod_DATA)
MDATA = sqrt(42)*Mod_DATA;
Inter_DATA = zeros(1,length(MDATA)*6);    
    for a=1:length(MDATA)
        b = (a-1)*6 + 1;                
        if real(MDATA(a)) > 0           
            Inter_DATA(b) = 1;
        else                            
            Inter_DATA(b) = 0;
        end
        
        if abs(real(MDATA(a))) < 4      
            Inter_DATA(b+1) = 1;
        else                            
            Inter_DATA(b+1) = 0;
        end
        
        if abs( abs(real(MDATA(a))) - 4 ) < 2       
            Inter_DATA(b+2) = 1;
        else                                        
            Inter_DATA(b+2) = 0;
        end 
        
        if imag(MDATA(a)) > 0           
            Inter_DATA(b+3) = 1;
        else                            
            Inter_DATA(b+3) = 0;
        end
        
        if abs(imag(MDATA(a))) < 4      
            Inter_DATA(b+4) = 1;
        else                           
            Inter_DATA(b+4) = 0;
        end
        
        if abs( abs(imag(MDATA(a))) - 4 ) < 2       
            Inter_DATA(b+5) = 1;
        else                                        
            Inter_DATA(b+5) = 0;
        end  
    end
end