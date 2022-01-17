function DATAM = OFDM_Symbol_Decoder(OFDMSYM)
ASym = OFDMSYM( 0.2*length(OFDMSYM) + 1 : length(OFDMSYM));  
New_Data= fft(ASym);
data =[New_Data(39:64) 0 New_Data(2:27)];
DATAM= [data(1:5) data(7:19) data(21:26) data(28:33) data(35:47) data(49:53)] ;    
end