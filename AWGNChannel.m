%AWGN Channel:
function outsignal = AWGNChannel(insignal, SNR)
awgnchan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',SNR);
outsignal = awgnchan(insignal);
end