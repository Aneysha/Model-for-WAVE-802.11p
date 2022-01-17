function OFDMSYM = OFDM_Symbol_Assembler(TDATA, pol)
DATA=[TDATA(1:5) 1*pol TDATA(6:18) 1*pol TDATA(19:24) 0 TDATA(25:30) 1*pol TDATA(31:43) -1*pol TDATA(44:48)];
New_Data=[0 DATA(28:53) 0 0 0 0 0 0 0 0 0 0 0 DATA(1:26)];
Assembled_DATA = ifft(New_Data);
GI = Assembled_DATA( 3*length(Assembled_DATA)/4 + 1 : length(Assembled_DATA) );
OFDMSYM=[GI Assembled_DATA];
end