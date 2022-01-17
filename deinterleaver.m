function Coded_PHY_data = deinterleaver(Inter_DATA, NCBPS)
first_permutation = zeros(1, length(Inter_DATA));
Coded_PHY_data = zeros(1, length(Inter_DATA));
Nbpsc = NCBPS / 48;
s = max(Nbpsc/2 , 1);
block_max= length(Inter_DATA) / NCBPS;
for block = 0 : block_max-1
    for i=0:NCBPS-1
        %         disp("i");
        j = s * floor(i/s) + mod((i + NCBPS - floor( (16 * i)/NCBPS )), s);
        OI = (block*NCBPS)+(i+1); %original index
        NI = (block*NCBPS)+(j+1); %new index
        first_permutation(NI)= Inter_DATA(OI);
    end
    for k= 0:NCBPS-1
        %         disp("k");
        i= (NCBPS/16) * mod(k, 16) + floor(k/16);
        OI = (block*NCBPS)+(k+1); %original index
        NI = (block*NCBPS)+(i+1); %new index
        Coded_PHY_data(NI)= first_permutation(OI);
    end
    
end

end