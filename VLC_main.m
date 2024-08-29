clc;
clear all;

% Parameters
SNR_dB_min = 0;          % Minimum SNR in dB
SNR_dB_max = 60;         % Maximum SNR in dB
num_points = 30;          % Number of SNR points
num_runs = 10;           % Number of runs for averaging
num_bits = 1000000;        % Number of bits to transmit
EbN0_dB = linspace(SNR_dB_min, SNR_dB_max, num_points); % SNR points in dB

Refractive_Index =1.5; % Refractive Index of the Lens
FOV_PD =75; % Field of View of the Photodiode
Concentrator_Gain =( Refractive_Index ^2) /( sind ( FOV_PD ).^2) ; % Gain of the optical concentrator

d = 5;                      % Distance between transmitter and receiver (m)
phiCap = 30;                % transmitter semiangle
m=-log10(2)/log10(cosd(phiCap));                     % Lambertian order
Adet = 0.5;                % Receiver area (m^2)
phi = 20;                 % Irradiance angle (assumed to be normal incidence)
Filter_Gain = 1;
theta = 60; % Receiver angle

% Convert SNR from dB to linear scale
SNR = 10.^(EbN0_dB / 10);

% Initialize the BER array
ber = zeros(1, num_points);

for i = 1:num_points
    % Simulation for each SNR point
    errors = 0;

    for j = 1:num_runs
        % Generate random bits
        tx_bits = randi([0, 1], 1, num_bits);

        Hg = ((m+1)*Adet*cosd(phi)^m./(2*pi*d^2))*Concentrator_Gain*Filter_Gain*cosd(theta);
        tx_symbols = tx_bits; %OOK

        % Add complex AWGN noise
        noise = (1 / sqrt(2 * SNR(i))) * (randn(1, num_bits) + 1i * randn(1, num_bits));
        H2 = sqrt(Hg); % Channel gain

        rx_symbols = H2 .* tx_symbols + noise;

        % Equalization (Zero-Force Equalization)
        equalized_signal = rx_symbols ./ H2;

        % Demodulate the equalized signal (threshold at 0.5)
        rx_bits = real(equalized_signal) > 0.5;

        % Count errors
        errors = errors + sum(tx_bits ~= rx_bits);
    end

    % Calculate BER for the current SNR point
    ber(i) = errors / (num_bits*num_runs);
end

% Plot the results
figure;
semilogy(EbN0_dB, ber, 'o-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs. SNR');
xlim([SNR_dB_min, SNR_dB_max]);
ylim([1e-4, 1]);
