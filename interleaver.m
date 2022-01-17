% All encoded data bits are interleaved through a block interleaver
% with a block size corresponding to the number of bits in a single
% OFDM symbol. It increases the robustness of the encoded bits to subcarriers
% interferences and adjacent bits loss. This is a two-step permutation
% process.

function interleaved_data = interleaver(Coded_PHY_data,NCBPS)
first_permutation = zeros(1, length(Coded_PHY_data));      
interleaved_data = zeros(1, length(Coded_PHY_data));
Nbpsc = NCBPS / 48; 
s = max(Nbpsc/2 , 1);
block_max= length(Coded_PHY_data) / NCBPS;
for block= 0:block_max-1
%     disp("block");
    for k= 0:NCBPS-1
%         disp("k");
        i= (NCBPS/16) * mod(k, 16) + floor(k/16);
        OI = (block*NCBPS)+(k+1); %original index
        NI = (block*NCBPS)+(i+1); %new index
        first_permutation(OI)= Coded_PHY_data(NI);
    end
%     disp("first permutation");
    for i=0:NCBPS-1
%         disp("i");
        j = s * floor(i/s) + mod((i + NCBPS - floor( (16 * i)/NCBPS )), s);
        OI = (block*NCBPS)+(i+1); %original index
        NI = (block*NCBPS)+(j+1); %new index
        interleaved_data(OI)= first_permutation(NI);
    end  
%     disp(interleaved_data);
end
end
