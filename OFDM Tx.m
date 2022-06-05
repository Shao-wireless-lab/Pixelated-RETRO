##Housekeeping
clear all; close all; clc;
##Variables
sps = 8; #samples per symbol for qpsk modulation
nbits = 10000; #number of bits
ncarr = 4; #number of carriers not including hermitian symmetry
morder = 2; #order of the modulation scheme(in this case qpsk -> order 2
fi = fopen('C:\Users\firep\.m files\tmp\rndBin.bin', 'r'); #open up a file containing 10000 random
bits of data
q = fread(fi); #read the file into a variable
q = q*2-1; #non-return to zero encoding
fclose(fi);
##Modulation
Simpulse = [];
for ii = 0:(nbits/(morder*ncarr)-1)
s = [];
#split bits into frequency bins for ifft
for i = 1:ncarr
s = [s q(2*i+ncarr*2*ii)+q(2*i-1 + ncarr*2*ii)*j];
endfor
#apply hermitian symmetry
s = [0 s 0 flip(conj(s))];
#apply ifft to generate real valued ofdm symbol
S = real(ifft(s));
#add symbol into an impulse train
for i = 1:length(S)
Simpulse = [Simpulse zeros(1,sps-1) S(i)];
endfor
endfor
##Pulse shaping
#create pulse shape(raised cosine filter)
beta = 0.35; #roll off factor
Ts = sps;
t = -51:51;
h = sinc(t/Ts) .* cos(pi*beta*(t/Ts)) ./ (1-(2*beta*t/Ts).^2); #raised cosine filter
Spulse = conv(Simpulse, h); #apply pulse shape
ofdmSymLen = 150; #determine number of samples per ofdm symbol
Spulse = resample(Spulse(51:end), ofdmSymLen, sps*(ncarr*2+2)); #resample signal
##Normalization
Snorm = Spulse - min(Spulse); #DC offset signal making it all >0
#quantize signal into 37(36+1) distinct levels(corresponding to the shutter states)
Snorm = (Snorm/max(Snorm))*36;
qS = round(Snorm);
##Data Storage
#save 'tmp/OFDM20carr.mat' qS -V7 #store signal data to .mat file