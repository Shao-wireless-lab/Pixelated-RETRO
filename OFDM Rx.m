##housekeeping
clear all; clc;
##Variables
[time_raw, samples_raw] = isfread('D:\tek0018CH1.isf'); #load o-scope data
binfile = fopen('C:\Users\firep\.m files\tmp\rndBin.bin', 'r'); #load random bits that were sent
bin = fread(binfile); #read random bit file into a variable
sample_rate = 500; #sampling rate of o-scope(all data collected was sampled at the same rate)
symbolFreq = 1; #symbol frequency of the ofdm symbols
ncarr = 16; #number of carriers per ofdm symbol
sps = sample_rate*(1/symbolFreq)/ncarr; #determine the space between sampling points in the
ofdm symbol
#an ofdm signal that has 10 carriers(no cyclic prefixes) will need 10 symbols per sample,
#if there are 500 samples per symbol the needed samples will have 50 samples between each
start = 25936 #isolate the start point of the signal(done manually)
nOFDMsym = ceil(1000/(ncarr-2)); #determine the number of ofdm symbols needed to read
1000 bits
ofdmSymLen = sps*ncarr; #determine the length of the ofdm symbols
samples = samples_raw(start:start+nOFDMsym*ofdmSymLen+1000); #isolate the signal
samples = samples - mean(samples); #normalize the signal
##Demodulation
m = [];
for ii = 0:nOFDMsym-1;
S = [];
##Isolate the needed samples from the ofdm symbol
for i = sps+1:sps:(ncarr+1)*sps
S = [S samples(round(i+ii*ofdmSymLen))];
endfor
s = fft(round(S*10000)/10000); #apply fft to collect data
s = s(2:length(s)/2); #remove hermitian symmetry
m = [m s]; #store data into a single variable
endfor
##Determination
q = [];
for i = 1:length(m)
if imag(m(i)) > 0
q = [q 1];
else
q = [q 0];
endif
if real(m(i)) > 0
q = [q 1];
else
q = [q 0];
endif
endfor
##BER calculation
biterr = sum(bin(1:length(q)) ~= q(:));
biterr #show number of bits different
ber = biterr/length(q)*100 #BER as a percent
##Plot Constellation
figure(1); plot(real(m), imag(m), '.');