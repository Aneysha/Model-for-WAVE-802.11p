%% equRicChan
    % Performs an ideal equalization given the ideal frequency response of
    % the channel.
   
function eqData = equalizer(X, H)
    X = X(:);
    H = H(:);
    % A simple division is performed between the frame in frequency and 
    % the channel response in frequency, then, transformed into time
    % domain.
    eqData = ifft(fft(X)./H);
end