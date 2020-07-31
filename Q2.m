close all 
clear all 
clc
load Walkin_towards_radar_along_beam.mat

%Walkin_towards_radar_along_beam.mat:
%	[12 x 256 x 512 x 120] beat signals [sensors x sweeps per burst x fast
%	time x bursts]. One person walking towards the radar along the beam
%	direction. Data is not calibrated!
load AOA_Cal_Coeff.mat % load calibration coefficent

%% 
c=299792458; %speed of light

NfftR=512;
NfftD=512;
Ts  = settings.Chirp_time - settings.Reset_time - settings.DwellTime;    % Duration of the ramp section of the chirp in s (Sweep Time)
S = settings.BW/Ts;
% Range axis
Range  = c/(2*S)*linspace(0,settings.Fs,NfftR);      % in meters
PRF=1/settings.Chirp_time/settings.NTx;

%% Calibration of the data
CalData = BS.*my_Corcoeff;

%% Range-Doppler movie

%Using single sensor data to make the range doppler movie, use sensor 1
singSens = squeeze(CalData(1,:,:,:));

%Calculating PRI
PRI = 1/PRF;

%Video location and attributes
video_loc = 'N:\MASTERS\Quarter 3\Microwave and radar systems and sensing\Matlab\Radar 4\Radar_Lab_4\Radar_Lab_4';
name = 'Range_Doppler';
title_str='Range-Doppler';
video_name=[video_loc,name,'.avi'];
writerObj = VideoWriter(video_name);
open(writerObj);

%Looping over bursts
for ind=1:148
    %start_time=1+NfftD*(ind-1);
    
    %x=Data_out(start_time:PRI:start_time+PRI*NfftD-1,:);
    %x=singSens(:,:,ind);
    %Taking fft twice to get required Range-Doppler
    FFT_1D = fftshift(fft(singSens(:,:,ind), NfftR, 2));
    FFT_2D = fftshift(fft(FFT_1D, NfftD, 1));
    %FFT_2D = fftshift(fft2(singSens(:,:,ind)), 1);
    RD = FFT_2D;
    %RD=fftshift(fft(x, NfftD),2);
    %frequency=-30:1000/(NfftD*PRI+1):30;
    frequency = -PRF/2:10/(NfftD*PRI+1):PRF/2;
    velocity = frequency.*c/settings.Fc;
    hfig=figure;
    imagesc(velocity,Range(1,:),db(abs(RD.')))
    %colormap(hot(256));
    %colorbar
    %colormap(jet(256));
    colorbar;
    caxis([0, 15]);
    set(gca,'ydir','norm');
    xlabel('Velocity [m/s]');
    ylabel('Range [m]');
    ylim([0, 10]);
    title(['{',title_str,' 1ms, burst ',num2str(ind),'}'])
    frame = getframe(hfig);
    writeVideo(writerObj,frame);
    close all
end
close(writerObj);

%% Micro Doppler Signature of Data

%Required signal
reqSig = squeeze(CalData(1,:,1,:));
%Sampling frequency
fs = settings.Fs;
%Window
win = hamming(256);
%Frequency axis
Freq = 0:10/(NfftD*PRI+1):PRF/2;
%velocity = Freq.*c/settings.Fc;

%spectrogram(x); get micro-doppler
spectrogram(reqSig(:),win,0,Freq,PRF,'yaxis;')

%Beautification
ylim([0, 2.5]);
colorbar;
caxis([-110 -80]);
title('Micro-Doppler, 1st sensor, 1st fast time, Nwin = 256');
ylabel('Doppler Frequency (kHz)');

%% Angle-Range plot 

%Single pulse
singPulse = BS(:,1,:,:);

for ind=1:size(singPulse, 3)
    singPulse(:,:,ind,:) = singPulse(:,:,ind,:).*my_Corcoeff;
end

singPulse = squeeze(singPulse);

%video for angle-range behaviour
video_loc = 'N:\MASTERS\Quarter 3\Microwave and radar systems and sensing\Matlab\Radar 4\Radar_Lab_4\Radar_Lab_4';
name = 'Range-Angle';
title_str='Range-Doppler';
video_name=[video_loc,name,'.avi'];
writerObj = VideoWriter(video_name);
open(writerObj);

%Looping over bursts
for ind=1:148
    
    %Getting the data for a burst
    reqArray = squeeze(singPulse(:,:,ind));
    
    NSamp = size(reqArray,2);    
    
    %Zero padding the data, 1st dim to improve the fft
    zero_matrix = zeros([2000-size(reqArray, 1), size(reqArray, 2)]); 
    
    %vertical concatenarion of the data
    zero_padded_data = [reqArray; zero_matrix];
    
    %Doing 2D fft of the data will give me range/angle data
    FFT = fft2(zero_padded_data);
    
    %Shifting the FFT, to get the stationary data in the middle,
    FFT_Shift = fftshift(FFT, 1);
    
    %Defining angle, same dim as that of zero padded matrix
    AoA = linspace(-90, 90, 2000);
    
    %Plotting the data, Surface plot
    hfig=figure;
    imagesc(AoA,Range,db(abs(FFT_Shift.')))
    %colormap(hot(256));
    %colorbar
    %colormap(jet(256));
    colorbar;
    caxis([0, 15]);
    set(gca,'ydir','norm');
    xlabel('Angle [deg]');
    ylabel('Range [m]');
    ylim([0, 10]);
    title(['{',title_str,' 1ms, burst ',num2str(ind),'}']);
    frame = getframe(hfig);
    writeVideo(writerObj,frame);
    close all
end
close(writerObj);
