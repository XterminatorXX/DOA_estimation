clc;
clear;
close all;

% ULA and signal data
j=sqrt(-1);
c=3e8; % speed of light;
fc=1e7; % carrier frequency
lambda=c/fc; % carrier wavelength
d=lambda/2; % distance between antennas
M=10; % No of antennas
K=4; % No of sources


N=200; % No of samples per source
signal_indices=randi(4,K,N);
signal_samples=exp(j*(2*pi*signal_indices/4+pi/4));

theta_aoa=[10,15,30,60]; % aoa in degrees
theta_aoa_rad=deg2rad(theta_aoa);
gen_ster_vec=zeros(M,K); % generate appropriate delay 
for k=1:1:K
    for m=1:1:M
        gen_ster_vec(m,k)=exp(j*2*pi*d*(m-1)*sin(theta_aoa_rad(1,k))/lambda);
    end
end

% Noise data
snr=20; % snr in dB;
snr_linear=10^(snr/10);
signal_power=1;
noise_power=signal_power/snr_linear;
noise_samples = sqrt(noise_power/2) * (randn(M, N) + 1j * randn(M, N));

% Received signal processing
received_signal_samples=gen_ster_vec*signal_samples+noise_samples;
Rxx=(received_signal_samples*received_signal_samples')*1/N;
Rxx_inv=inv(Rxx); % inverse of Rxx
[V,D]=eig(Rxx); % eigen decomposition
[val,ind]=sort(diag(D));
Ds=D(ind,ind); % sorted eigen value matrix 
Vs=V(:,ind); %unitary eigen vector matrix
val=sort(val,'descend');
[mld_values,sources_estimate]=number_sources_estimation(M,N,val); % Estimate no of sources
Vn=Vs(:,1:M-sources_estimate);

% DOA estimation
angle_resolution=0.1;
angle_scan_range=-90:angle_resolution:90;
num_angles=length(angle_scan_range);

a_ster_vec=zeros(M,1); % steering vector
cf_fourier=zeros(num_angles,1); % cost function fourier
cf_capon=zeros(num_angles,1); % cost function capon
cf_music=zeros(num_angles,1); % cost fucntion music
aoa_angle_scan=zeros(num_angles,1); % angle axis
angle_index=1;

for angle_deg=angle_scan_range
    angle_rad=deg2rad(angle_deg);
    for m=1:1:M
        a_ster_vec(m,1)=exp(j*2*pi*d*(m-1)*sin(angle_rad)/lambda);
    end
    cf_fourier(angle_index,1)=a_ster_vec' * Rxx * a_ster_vec;
    cf_capon(angle_index,1)=1/(a_ster_vec' * Rxx_inv * a_ster_vec);
    cf_music(angle_index,1)=1/(a_ster_vec' * Vn * Vn' * a_ster_vec);
    aoa_angle_scan(angle_index,1)=angle_deg;
    angle_index=angle_index+1;
end

cf_fourier_dB = 10 * log10(abs(cf_fourier));
cf_capon_dB   = 10 * log10(abs(cf_capon));
cf_music_dB   = 10 * log10(abs(cf_music));

% Normalize to maximum value (in dB)
cf_fourier_dB = cf_fourier_dB - max(cf_fourier_dB);
cf_capon_dB   = cf_capon_dB   - max(cf_capon_dB);
cf_music_dB   = cf_music_dB   - max(cf_music_dB);


figure;
plot(angle_scan_range, cf_fourier_dB, 'b-', 'LineWidth', 1.5); 
hold on;
plot(angle_scan_range, cf_capon_dB, 'r--', 'LineWidth', 1.5);
plot(angle_scan_range, cf_music_dB, 'g', 'LineWidth', 1.5);
xlabel('Angle (degrees)');
ylabel('Beamformer Output Power (dB)');
legend('Fourier (DAS)', 'Capon (MVDR)','MUSIC');
title('DOA Estimation using Beamforming');
grid on;
zoom on;

% Peak detection and aoa estimation
[aoa_fourier, peak_vals_fourier] = find_peaks_doa(angle_scan_range, cf_fourier_dB,sources_estimate);
[aoa_capon, peak_vals_capon]     = find_peaks_doa(angle_scan_range, cf_capon_dB,sources_estimate);
[aoa_music, peak_vals_music]     = find_peaks_doa(angle_scan_range, cf_music_dB,sources_estimate);

% Display results
disp('Estimated DOAs (Fourier):'); disp(aoa_fourier);
disp('Estimated DOAs (Capon):');   disp(aoa_capon);
disp('Estimated DOAs (MUSIC):');   disp(aoa_music);
