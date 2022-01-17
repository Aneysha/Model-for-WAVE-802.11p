% The scrambler is used for avoiding long sequences of zeroes
% and ones in the transmitted data. An intial state value of [1011101] is set
% using the generator polynomial S(x) = x7+x4+1. A XOR operation is
% then done between the output and data.

function SData = scrambler(data)
initial_state = [1 0 1 1 1 0 1];
SData = zeros(1, length(data));
for i=1:length(data)
    S = xor(initial_state(4),initial_state(7));  
    SData(i) = xor(S, data(i));   
    initial_state = circshift(initial_state, 1,2);
    initial_state(1) = S;   
end
end