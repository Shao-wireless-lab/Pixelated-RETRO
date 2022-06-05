##Housekeeping close all; clear all; clc;

##Variables
fc = 1; #carrier frequency
sps = 64; #samples per symbol
t = 1/sps:1/(sps):1; #symbol period
halfN = 5000; #half the total number of bits

bits = randi([0 1], 2, halfN); #generate random bits nrz_bits = bits*2-1; #non-return to zero encoding

carrierI = cos(2*pi*fc*t); #Inphase Carrier carrierQ = sin(2*pi*fc*t); #Quadrature Carrier


##Modulation I = [];
Q = [];
pos = [];
for i = 1:halfN
Isym = nrz_bits(1, i)*carrierI; #Generate Inphase component of one symbol Qsym = nrz_bits(2, i)*carrierQ; #Generate Quadrature component of one symbol ##Collect index of all 11 symbols
if (nrz_bits(1, i) > 0) && (nrz_bits(2, i) > 0) pos = [pos i];
endif

#Place Inphase and Quadrature symbols into signals I = [I Isym];
Q = [Q Qsym]; endfor

#generate the transmission signal w/ normalization factor tx = (I+Q)/sqrt(2);
 

##Channel #Noise Variables
EbNodB = 4; #Eb/No in decibels
EbNo = 10^(EbNodB/10); #conversion from dB to fraction #Eb = 1/2; #Energy per symbol is 1, Es = 2Eb > Eb = 1/2 No = Eb/EbNo; #Eb/(Eb/No) = NoEb/Eb = No
L = length(tx); #each sample of the signal received noise

#Noise generation
sigma = sqrt(No/2); #deviation(square root of variance) n = sigma*randn(1, L); #noise generation

#Application of noise rx = tx + n;

##Demodulation
qoff = 1/2 - 1/(4*fc); #the location of the sample where sine wave is greatest(to determine sampling point of Q signal)

sym = [];
data = [];
for i = 1:halfN
rsym = rx((i-1)*sps+1:i*sps); #Isolate one symbol

Qsym = (rsym.*carrierQ)(round(sps*qoff)); #separate quadrature component, and T spaced sampling
Isym = (rsym.*carrierI)(round(sps/2)); #separate inphase component, and T spaced sampling

sym = [sym Isym+Qsym*j]; #Generate the demodulated constellation data = [data [(Isym > 0); (Qsym > 0)]]; #Generate the demodulated data endfor

#Isolated 11 data
d = real(sym(pos)) - sqrt(2)/2; #vertical distances between ideal 11 symbol (1/root(2), 1/root(2)) and actual 11 symbol
L = length(pos);
Rxx = 1/L*conv(d', flipud(d')); #autocorrelation function of noise on 11 symbols

No_d = max(Rxx)*2; #autocorrelation function of awgn produces a delta function with height No/2

##Display Data No_d
 
Eb No EbNo
EbNodB
BER = length(find(data ~= bits))/(2*halfN) BER_th = 0.5*erfc(sqrt(EbNo))
BER_r = abs(BER-BER_th)/BER_th
