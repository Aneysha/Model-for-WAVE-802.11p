function Modulated_PHY=BPSK_modulation(Interleaved_PHY_data)
%Interleaved_PHY_data=interleaved_data;
modulator = comm.PSKModulator(2,'BitInput', true, 'PhaseOffset', 0);
modulated_data = step(modulator,Interleaved_PHY_data');
modulated_data = modulated_data';  
Modulated_PHY = 1 * modulated_data;
end