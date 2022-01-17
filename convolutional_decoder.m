function SDATA = convolutional_decoder(PHY_data,M,R)
codeRate = R;
constraintLength = 7;
codeGenerator = [171 133];
Trellis = poly2trellis(constraintLength,codeGenerator);
tbdepth = 0;
if (codeRate == 1/2)
    puncVector = [1 1];
    tbdepth = 36;
elseif (codeRate == 2/3)
    puncVector = [1 1 1 0];
    tbdepth = 96;
elseif (codeRate == 3/4)
    puncVector = [1 1 1 0 0 1];
    tbdepth = 96;
%     if M==1 tbdepth = 36;
%     else tbdepth = 96;
%     end
else errordlg('INVALID RATE');
end
puncVector = fliplr(puncVector);
SDATA = vitdec(PHY_data,Trellis,tbdepth,'trunc','hard',puncVector);
end