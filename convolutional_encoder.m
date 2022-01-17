% Convolutional Encoder follows the industry
% standard generator polynomials, g0 = 10110112 and g1 = 11110012 of
% rate R=1/2. For higher rates, puncturing is used. It is used for error correction
% for the receiver to correct the detrimental effects of the channel.

function coded_signal= convolutional_encoder(PHY_data, R)
codeRate = R;
constraintLength = 7;
codeGenerator = [171 133];                               
Trellis = poly2trellis(constraintLength,codeGenerator);  
if (codeRate == 1/2)
    puncVector = [1 1];
elseif (codeRate == 2/3)
    puncVector = [1 1 1 0];
elseif (codeRate == 3/4)
    puncVector = [1 1 1 0 0 1];
else errordlg('INVALID RATE');    
end

puncVector = fliplr(puncVector);
coded_signal = convenc(PHY_data, Trellis, puncVector);     
end
