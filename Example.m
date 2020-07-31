close all 
clear all 
clc

load Assignment1.mat
% Collections in the form of [sensor X fast-time] 

c=299792458; %speed of light
data_to_process= CollectionA;  %change to CollectionB, CollectionC and CollectionD
NSamp = size(data_to_process,2);

NFFTA = 1024; % FFT length angle
NFFTR = 1024; % FFT length range
% Range axis
Ts  = Radar_settings.Chirp_time - Radar_settings.Reset_time - Radar_settings.DwellTime;    % Duration of the ramp section of the chirp in s (Sweep Time)
S = Radar_settings.BW/Ts;
Range  = c/(2*S)*linspace(0,Radar_settings.Fs,NFFTR);      % in meters

%% Start writing your code ....