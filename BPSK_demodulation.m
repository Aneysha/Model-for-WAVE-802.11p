function Inter_DATA = BPSK_demodulation(Mod_DATA)
bitsDemodu = comm.PSKDemodulator(2,'BitOutput', true, 'PhaseOffset', 0);
Inter_DATA = step(bitsDemodu, Mod_DATA');
Inter_DATA = Inter_DATA';
end
