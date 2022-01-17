clc, clear all, close all
%%  Transmitter
%---------------------------------------------------------------------------------
%---------------------------------------------------------------------------------
%The transmitter has been designed by implementing the PLCP frame in MATLAB.
%The PLCP frame of WAVE is built up of 3 fields- the Preamble, the Signal
%and the Data fields.
%_______________________________________________________
%% Create Preamble according to IEEE 802.11 amendment 2020
%The Preamble contains 10 short and 2 long training sequences.

%*****************************************************
%% Create Short Symbol:
Short_sym = zeros(1,53);
inx1 = [3 11 23 39 43 47 51];
Short_sym(1,inx1) = 1+1i;
inx2 = [7 15 19 31 35];
Short_sym(1,inx2) = -1-1i;

Short_sym = sqrt(13/6) * Short_sym;
Short_pre =[0 Short_sym(28:53) 0 0 0 0 0 0 0 0 0 0 0 Short_sym(1:26)];

SPTFFT = ifft(Short_pre);
TSHORT= SPTFFT(1:length(SPTFFT)/4);
Short_Preamble = zeros(1, 64 * 2 * 1.25);
for i=1:10
    Short_Preamble(1,[(i-1)*(64 / 4) + 1: i*(64 / 4) ] ) = TSHORT;
    
end
%******************************************************
%% Create Long Symbol:
Long_sym = ones(1,53);
inx3 = [3 4 7 9 16 17 20 22 29 30 33 35 37 38 39 40 41 44 45 47 49];
Long_sym(1,inx3) = -1;
Long_sym(1,27)=0;
Long_pre =[0 Long_sym(28:53) 0 0 0 0 0 0 0 0 0 0 0 Long_sym(1:26)];

LPTFFT = ifft(Long_pre);
GI = LPTFFT(length(LPTFFT)/2+1:length(LPTFFT));
Long_Preamble=[GI LPTFFT LPTFFT];
%******************************************************
PREAMBLE= [Short_Preamble Long_Preamble];
disp('Preamble Created');
%______________________________________________________
%% Create Signal according to IEEE 802.11 amendment 2020
%The Signal field consists of total 24 bits which form 1 OFDM symbol.
%The encoding of the single OFDM symbol is performed with BPSK modulation
%of the subcarriers, using convolutional coding at R = 1/2 as specified
%in the standard.

NBPSC = 1;  %Coded bits per subcarrier
NCBPS = 48; %Coded bits per OFDM symbol
NDBPS = 24; %Data bits per OFDM symbol

%The signal field has total 24 bits
rate = [1 1 0 1]; %for data rate 3 Mbps corresponding to BPSK R = 1/2
reserved = 0;
data_len =[1 0 0 1 0 0 0 1 1 1 0 0]; %length of the PSDU in number of octets.
parity = 0;
tail = zeros(1,6); % 6 zeroes for tail

PHY_Signal=[rate reserved data_len parity tail];

R = 1/2;
Coded_PHY_Signal = convolutional_encoder(PHY_Signal, R);
Interleaved_PHY_Signal = interleaver(Coded_PHY_Signal,NCBPS);
Modulated_PHY_Signal=BPSK_modulation(Interleaved_PHY_Signal);
Modulated_PHY_Signal=[Modulated_PHY_Signal(1:5) 1 Modulated_PHY_Signal(6:18) 1 Modulated_PHY_Signal(19:24) 0 Modulated_PHY_Signal(25:30) 1 Modulated_PHY_Signal(31:43) -1 Modulated_PHY_Signal(44:48)];
Assembled_Array=[0 Modulated_PHY_Signal(28:53) 0 0 0 0 0 0 0 0 0 0 0 Modulated_PHY_Signal(1:26)];
Assembled_OFDM = ifft(Assembled_Array);
GI = Assembled_OFDM( 3*length(Assembled_OFDM)/4 + 1 : length(Assembled_OFDM) );
OFDM_Signal=[GI Assembled_OFDM];
disp('Header Created');
%______________________________________________________
%% Data Field
%The Data Field consists of 4 sub-fields. These are service, PSDU, Tail and Pad Bits. The PSDU,
%which is the payload is processed and converted to an equivalent binary
%stream.

% Chan = input("Enter type of channel (1 for AWGN, 2 for Rural-LOS,3 for Urban-LOS, 4 for Highway-LOS)");
SNRValue = 20:5:45; %this range can be changed.

valid_mod_flag = 0;
while valid_mod_flag ==0
    M= input("Enter Modulation Scheme 1,2,4 or 6(BPSK- 1/QPSK- 2/16QAM- 4/64QAM- 6):");
    switch M
        case 1
            r=input("Enter coding rate(1/2 or 3/4):");
            valid_mod_flag = 1;
        case 2
            r=input("Enter coding rate(1/2 or 3/4):");
            valid_mod_flag = 1;
        case 4
            r=input("Enter coding rate(1/2 or 3/4):");
            valid_mod_flag = 1;
        case 6
            r=input("Enter coding rate(2/3 or 3/4):");
            valid_mod_flag = 1;
        otherwise
            disp('invalid input');
    end
    
end

NBPSC = M;
NCBPS = NBPSC * 48;
NDBPS = NCBPS * r;
%Enter path where the image frames are saved.
dir_path = 'F:\THESIS CODE\mycode_80211p\Input_data\';
files = dir([dir_path '*.png']);

parfor SNRRange = 1:length(SNRValue)

    disp(['For SNR value: ',num2str(SNRValue(SNRRange))]);
    k = 6;    %:length(files)-here it picks up one frame of image.This could be converted to 
    % a loop inside the dir_path to pick up all the image frames one by one sequentially.
    file_name = files(k).name;
    disp(file_name);
    
    %Process image data
    imgTX=imread([dir_path file_name]); %read image
    origSize = size(imgTX); %[720,1280,3]
    flatImage = imgTX(:); %convert to 1D vector (not a binary string)
    %The MSDU has a variable size of up to 2304 bytes, which is the maximum 802.11 transmission unit.
    msduLength = 2304; %maximum MSDU length in bytes as per IEEE 802.11 amendment 2020
    MSDUnumss = ceil(length(flatImage)/msduLength); %number of MSDUs
    data = [];
    ErrorMatrix= zeros(4,MSDUnumss);
    disp('Error Matrix Created\n');
    ChannelValue = 1:1:4;    
    
    
    for Chan = 1:length(ChannelValue)
        disp(['For Channel: ', num2str(ChannelValue(Chan))]);
        
        for ind=0:MSDUnumss-1
            count = ind+1;
            disp(['Packet Number: ' num2str(count)])
            
            % Extract image data (in octets) for each MPDU
            frameBody = flatImage(ind*msduLength+1:msduLength*(ind+1),:);
            % Convert MPDU bytes to a bit stream
            psdu = double((reshape(de2bi(frameBody, 8)', [], 1))');
            psdulen=length(psdu);
            
            service = zeros(1,16);
            tail = zeros(1,6);
            NSYM =  ceil((length(psdu)+length(service)+length(tail))/NDBPS);     %Number of symbols to generate
            NDATA = NSYM * NDBPS;                                                %Total number of bits (after padding)
            NPAD = NDATA - ( length(psdu) + length(service) + length(tail) );    %Number of padding bits necessary
            pad = zeros(1,NPAD);
            %%
            % DATA field construction according to the IEEE 802.11-2012 standard.
            DATA_FIELD = [service psdu tail pad];
            
%%          Scrambler
            SDATA = scrambler(DATA_FIELD);
            %
            % The TAIL bits are set to 0 after the scramble because they
            % do not participate in the scrambling process according to the IEEE
            % 802.11 standard.
            SDATA( length(service) + length(psdu) + 1 : length(service) + length(psdu) + length(tail)) = 0;
%%          Convolutional Encoder
            CDATA = convolutional_encoder(SDATA, r);
%%          Interleaver
            IDATA = interleaver(CDATA, NCBPS);
%%           Modulator: The OFDM subcarriers are modulated by using BPSK,
%            QPSK, 16-QAM, or 64-QAM, depending on the RATE requested. The
%            encoded and interleaved binary serial input data is divided into 1, 2, 4, or
%            6 bits and converted into complex numbers representing BPSK, QPSK,
%            16-QAM, or 64-QAM gray-coded constellation points
            if M==1
                MDATA = BPSK_modulation(IDATA);
            elseif M==2
                MDATA = QPSK_modulation(IDATA);
            elseif M==4
                MDATA = QAM16_modulation(IDATA);
            elseif M==6
                MDATA = QAM64_modulation(IDATA);
            end
 %%         OFDM Symbol Assembler and Pilot Insertion: The stream of complex
            % numbers is divided into groups of 48 complex numbers mapped
            % into frequency offset index -26 to 26, skipping subcarriers -21, -7, 0, 7
            % and 21. The assembler block inserts four pilot sub-carriers into positions
            % -21, -7, 7 and 21, as well as a zero DC subcarrier between the data
            % sub-carriers. The subcarriers -32 to -27 and 28 to 32 are set to zero resulting
            % in a guard band that considerably contributes in reducing the out
            % of band power. The polarity of the pilot subcarriers is controlled by the
            % sequence.           
            PN = [1,1,1,1,-1,-1,-1,1,-1,-1,-1,-1,1,1,-1,1, ...
                -1,-1,1,1,-1,1,1,-1,1,1,1,1,1,1,-1,1, ...
                1,1,-1,1,1,-1,-1,1, 1,1,-1,1,-1,-1,-1,1, ...
                -1,1,-1,-1,1,-1,-1,1,1,1,1,1,-1,-1,1,1, ...
                -1,-1,1,-1,1,-1,1,1,-1,-1,-1,1,1,-1,-1,-1, ...
                -1,1,-1,-1,1,-1,1,1,1,1,-1,1,-1,1,-1,1, ...
                -1,-1,-1,-1,-1,1,-1,1,1,-1,1,-1,1,1,1,-1, ...
                -1,1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1];
 %%         Frame Assembler: The data stream that consists of complex data, representing
            % certain points of symbol constellation is transformed into an
            % analog signal waveform suitable for transmission. These symbols containing
            % transmit data are converted from frequency domain to time domain.
            % It is then appended with a Cyclic Prefix. This is then concatenated
            % to the Preamble and Header to form the PPDU.           
            NoSym= length(MDATA)/48;
            DATA_SENT = zeros(1,NoSym*80);
            for i=1:NoSym
                p_index = mod( i ,127 ) +1;
                TDATA= MDATA( (i-1)*48 + 1 : i*48 );
                RDATA = OFDM_Symbol_Assembler( TDATA, PN(p_index) );
                DATA_SENT((i-1)*80 + 1 : i*80) = RDATA;
            end
            Packet_TX = [PREAMBLE OFDM_Signal DATA_SENT];
            disp(['Packet sent: ',num2str(count)]);
            
            %------------------------------------------------------------------------------
            %------------------------------------------------------------------------------
 %% Channel:
            switch ChannelValue(Chan)
                case 1
                    Packet_RX = AWGNChannel(Packet_TX,SNRValue(SNRRange));
                case 2
                    [Packet_RX1,H] = RICIANChannel(Packet_TX);
                    Packet_RX = AWGNChannel(Packet_RX1,SNRValue(SNRRange));
                case 3
                    [Packet_RX1,H] = RICIANChannelUrbanLOS(Packet_TX);
                    Packet_RX = AWGNChannel(Packet_RX1,SNRValue(SNRRange));
                case 4
                    [Packet_RX1,H] = RICIANChannelHighwayLOS(Packet_TX);
                    Packet_RX = AWGNChannel(Packet_RX1,SNRValue(SNRRange));
            end
            
            disp('Channel Cleared');
            %------------------------------------------------------------------------------
            %------------------------------------------------------------------------------
%%  Receiver
            % After passing through the propagation channel, an equalizer is first introduced
            % to reverse distortions by the channel. and being received, the PPDU is extracted to separate the Data from the Header and Preamble fields. The reverse
            % processing of the Data field starts. It is first converted from time domain to
            % frequency domain. The cyclic prefix is removed and the pilots extracted. The
            % guard bands are removed and the OFDM symbols decoded. The Demodulator
            % block performs the reverse process on the data according to any of the
            % schemes of modulation - BPSK, QPSK, 16-QAM, or 64-QAM. This is now
            % the interleaved data that passes through the de-interleaver block which uses
            % the two-step permutation method in the reverse manner to that of the interleaver
            % block. Further, the convolutional decoder uses the Viterbi algorithm for
            % decoding as recommended by the IEEE 802.11 standard. This restored data is then scrambled using the same scrambler
            % as in the transmitter to obtain the payload.
            
            if ChannelValue(Chan)==2 || ChannelValue(Chan)==3 || ChannelValue(Chan)==4
                Packet_RX = transpose(equalizer(Packet_RX,H));
            end
            Short = 2*80;
            Long = 2*80;
            PreambleLen = Short +Long;
            SignalLen = 80;
            
            Received_DATA = Packet_RX(PreambleLen + SignalLen + 1 : length(Packet_RX));
            
            %The number of samples in time are going to be 64:
            %48 data, 4 pilots,12 nulls + 1/4 per GI results in 80 total bits with GI.
            
            Totalsym = length(Received_DATA)/80;
            Mod_DATA = zeros(1,Totalsym*48);
            for a=1:Totalsym
                RData = Received_DATA((a-1)*80+1:a*80);
                get_symbol = OFDM_Symbol_Decoder(RData);
                Mod_DATA((a-1)*48 + 1 : a*48) = get_symbol;
            end
            
            if M==1
                Inter_DATA = BPSK_demodulation(Mod_DATA);
            elseif M==2
                Inter_DATA = QPSK_demodulation(Mod_DATA);
            elseif M==4
                Inter_DATA = QAM16_demodulation(Mod_DATA);
            elseif M==6
                Inter_DATA = QAM64_demodulation(Mod_DATA);
            end
            Coded_Data = deinterleaver(Inter_DATA,NCBPS);
            Scrambled_Data =convolutional_decoder(Coded_Data,M,r);
            Retrieved_DATA_FIELD=scrambler(Scrambled_Data);
            Retrieved_PSDU = Retrieved_DATA_FIELD(16 + 1: 16 + psdulen);
            disp(['PSDU retrieved: ', num2str(count)]);
            biterror = sum( abs( Retrieved_PSDU -  psdu) ); %calculate error
            if ChannelValue(Chan) == 1
                ErrorMatrix(1,count)= biterror;
            end
            if ChannelValue(Chan) == 2
                ErrorMatrix(2,count)= biterror;
            end
            if ChannelValue(Chan) == 3
                ErrorMatrix(3,count)= biterror;
            end
            if ChannelValue(Chan) == 4
                ErrorMatrix(4,count)= biterror;
            end
            disp('Check Error Matrix');
            transpose_psdu = (uint8(Retrieved_PSDU))';
            Resized_psdu = reshape(transpose_psdu,8,[])';
            decimal_psdu = bi2de(Resized_psdu);
            data = [data; decimal_psdu];
            
        end
       
         pic = reshape(data,720,1280,[]);
        %     imshow(pic);
    end   
    ErrorMatrix_SNR{SNRRange} = ErrorMatrix;
end

% save('test.mat','ErrorMatrix_SNR','SNRValue');
