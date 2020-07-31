%Assignment - 1 and 2
close all
clear all 
clc

load Assignment2.mat
% Collections in the form of [sensor X fast-time] 

c=299792458; %speed of light
%% Start writing your code ....

%Invoke names according to assignment 1 or 2
%name = ["CollectionA", "CollectionB", "CollectionC", "CollectionD"];
name = ["BS_TCR_0_10", "BS_TCR_0_15", "BS_TCR_0_20", "BS_TCR_0_5"];
NFFTA = 1024; % FFT length angle
NFFTR = 1024; % FFT length range
% Range axis
Ts  = Radar_settings.Chirp_time - Radar_settings.Reset_time - Radar_settings.DwellTime;    % Duration of the ramp section of the chirp in s (Sweep Time)
S = Radar_settings.BW/Ts;
Range  = c/(2*S)*linspace(0,Radar_settings.Fs,NFFTR);      % in meters

%Number of sensors
N = 12;
%Distance between the sensors
d = 2*c/Radar_settings.Fc;
rangeRes_Theory = c/(2*Radar_settings.BW);

for ind = 1:size(name, 2)
    data_to_process= eval(name(ind));  %change to CollectionB, CollectionC and CollectionD
    NSamp = size(data_to_process,2);    
    
    %Zero padding the data, 1st dim to improve the fft
    zero_matrix = zeros([3000-size(data_to_process, 1), size(data_to_process, 2)]); 
    
    %vertical concatenarion of the data
    zero_padded_data = [data_to_process; zero_matrix];
    
    %Doing 2D fft of the data will give me range/angle data
    FFT = fft2(zero_padded_data);
    
    %Shifting the FFT, to get the stationary data in the middle,
    FFT_Shift = fftshift(FFT, 1);
    
    %Defining angle, same dim as that of zero padded matrix
    AoA = linspace(-90, 90, 3000);
    
    %Plotting the data, Surface plot
    figure();
    surf(AoA, Range, db(abs(FFT_Shift)).'); view(2); shading flat;
    ylim([0 10]); 
    %Taking first 15 meters in the range data 
    %other wise the graph goes till 182 m
    xlabel('Angle (in degree)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Range (in meters)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Range/Angle Graph', 'FontSize',12, 'FontWeight', 'bold');
    grid on;
    colorbar;
    caxis([-50 10]);
    
    %Ploting data in polar coordinates, used pudn.com's polarPcolor.m
    %Taking till R = 15m belyond that the data is mostly zero
    figure();
    [h, c]=polarPcolor(Range(:, 1:58),AoA, db(abs(FFT_Shift(:, 1:58))).');
    colorbar;
    caxis([-50 10]);
    
    %Range cuts to find the range resolution Broadside
    figure();
    plot(Range(:,1:58), db(abs(FFT_Shift(size(AoA,2)/2+1,1:58))).', 'LineWidth', 1.5);
    xlabel('Range (in m)');
    ylabel('Angle/Range data (in dB)');
    title('Range cut for AoA = 0 deg');
    ylim([-30, 30]);
    
    %Angle cut to find the angle resolution R = 10 m
    figure();
    plot(AoA(1,:), db(abs(FFT_Shift(:,39))).', 'LineWidth', 1.5);
    xlabel('AoA (in deg)');
    ylabel('Angle/Range data (in dB)');
    title('Angle cut for Range = 6.78 m');
    ylim([-30, 10]);
end