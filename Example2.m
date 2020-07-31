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
Ts  = Radar_settings.Chirp_time - Radar_settings.Reset_time - Radar_settings.DwellTime;    % Duration of the ramp section of the chirp in s (Sweep Time)
S = Radar_settings.BW/Ts;
% Range axis
Range  = c/(2*S)*linspace(0,Radar_settings.Fs,NfftR);      % in meters
PRF=1/Radar_settings.Chirp_time/Radar_settings.NTx;

%% Start writing your code here 