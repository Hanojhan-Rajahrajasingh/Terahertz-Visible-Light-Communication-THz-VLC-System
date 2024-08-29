
clear all; clc; 
N = 10^6; % number of bits or symbols

c= 3*10^8; % Speed of light
Gtx=10^5.5; %(55dBi)
Grx=Gtx;
d=30; % Distance between Tx and Rx
freq = 300*10^9;
k = absorptionco(freq);

a = 0.1;               %radius of the reception antenna effective area = 10cm
wd_1 = 0.6;            %transmission beam footprint radius at distance d1
u = (sqrt(pi)/sqrt(2))*(a/wd_1)  ;                   
weq = sqrt(wd_1^2*((sqrt(pi)*erf(u))/(2*u*exp(-u^2))));
sigma_s = 0.05;
A0 =   abs(erf(u))^2;
gamma_squared = weq^2/(2*sigma_s^2);


% Transmitter
ip = rand(1,N)>0.5; % generating 0,1 with equal probability
s = 2*ip-1; % BPSK modulation 0 -> -1; 1 -> 0 
 
iter=10^6;
 
Eb_N0_dB = [0:50]; % multiple Eb/N0 values
for ii = 1:length(Eb_N0_dB)
   
   n = 1/sqrt(2)*[randn(1,N) + j*randn(1,N)]; % white gaussian noise, 0dB variance 
   hp = (c*sqrt(Gtx*Grx))./(4*pi*d*freq); %FSPL Attenuation
   ha = exp(-0.5*k*d); %Absorption Loss
   
    hp_val= 0:1/iter:A0;
    pdf_hp = (gamma_squared./(A0.^gamma_squared)).*hp_val.^(gamma_squared-1);
    hm = randpdf(pdf_hp,hp_val,[1,iter]); %Missalignment Fading
   
  h = hp*ha*hm; % Overall Channel Gain
   
   % Channel and noise Noise addition
   y = h.*s + 10^(-Eb_N0_dB(ii)/20)*n; 
   % equalization
   yHat = y./h;
   % receiver - hard decision decoding
   ipHat = real(yHat)>0;
   % counting the errors
   nErr(ii) = size(find([ip- ipHat]),2);
end
simBer = nErr/N; % simulated ber
% plot
semilogy(Eb_N0_dB,simBer,'mx-','LineWidth',2);
axis([27 42 10^-4 0.5])
grid on
legend('Simulation');
xlabel('Eb/No, dB');
ylabel('Bit Error Rate');
title('BER for BPSK modulation for THz communication');
