%A version of the feature extractor that receives the time sections in
%seconds rather than in 

clear
clc

%% Load and initialise

load('sub1_fingerstartstops.mat') %gives the time intervals (in ms) that the fingers start and stop moving - made through visual inspection
load('sub1_comp.mat')
rawsigs = train_data; %load the EEG data here

[L,C1] = size(rawsigs);
filter_order = 2; %used in preprocessor2
Min_band = 2;
Max_band = 500;
Filter_out = 60;
tolerance_sd = 10; %Select the number of standard deviations from the overall MEAN that will be flagged as high
tolerance_n = 1000; %Select the number of high values that can be accepted before a lead is dropped
%frequency variables
FsFingers = 25;
FsECoG = 1000;


%% This section should perform the pre-processing of the data. It should
%%bandpass min->max and null out 60Hz. Outsourced to preprocessor2 function

[midsigs, C2] = preprocessor1(rawsigs, tolerance_sd, tolerance_n); %Note C is a scalar value that corresponds to the number of acceptable leads
fprintf('number of leads dropped = %f\n', C1-C2);
sigspre = preprocessor2(midsigs, FsECoG, Min_band, Max_band, Filter_out, filter_order);


%time variables
timerange = 0:1:399;
start = (thumbstartstop(1,1)/1000) - 0.5;
stop = (thumbstartstop(1,2)/1000) + 0.5;
start1000Hz = start*FsECoG;
stop1000Hz = stop*FsECoG;

% start2 = 20;
% stop2 = 25;
% start1000Hz_2 = start2*FsECoG;
% stop1000Hz_2 = stop2*FsECoG;

% start3 = 8.36;
% stop3 = 10.44;
% start1000Hz_3 = start3*FsECoG;
% stop1000Hz_3 = stop3*FsECoG;

timerange1000Hz = start1000Hz:stop1000Hz; %start1000Hz_2:stop1000Hz_2]; %start1000Hz_3:stop1000Hz_3 ];

timerange25Hz = 0:1/FsFingers:(400-(1/FsFingers));
T1000Hz = 1/FsECoG;
t1000Hz = ((0:length(timerange1000Hz)-1)*T1000Hz) + start;

brainwavebandset = [0.1 3; 4 7; 8 15; 7.5 12.5; 13 16; 16 31; 32 50; 51 80; 80 100];
%% All data loaded, select time of interest in seconds

EEGpowerdens = zeros(length(timerange1000Hz),(C2*length(brainwavebandset)));
for i = 1:length(brainwavebandset)

ActiveECoGRange = sigspre((min(timerange1000Hz)-100):max(timerange1000Hz),:); %-100 extension required so the script is able to cut out the zero values
EEGpowerdensworking = powerwindower(ActiveECoGRange, FsECoG, brainwavebandset(i,:));
%EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
mlearnworking = EEGpowerdensworking(101:end,:);
EEGpowerdens(:,(1:61)+((i-1)*61)) = mlearnworking;

end

%EEGpowerdens is currently sampled at 1000Hz
t40Hzmid = downsample((min(timerange1000Hz)-100:max(timerange1000Hz)), 25,24);
t40Hz = t40Hzmid(:,8:end).*(1/40);
EEGpowerdensmid = downsample(EEGpowerdens, 25, 24);
EEGpowerdens = EEGpowerdensmid(4:end,:);

%% All data loaded, select time of interest in seconds
n = 1:61;
nrange = [n;n+61;n+(61*2);n+(61*3);n+(61*4);n+(61*5);n+(61*6);n+(61*7);n+(61*8)];

subplot(4,3,1), plot(t40Hz,EEGpowerdens(:,nrange(1))), title('Delta band');
subplot(4,3,2), plot(t40Hz,EEGpowerdens(:,nrange(2))), title('Low-alpha band');
subplot(4,3,3), plot(t40Hz,EEGpowerdens(:,nrange(3))), title('SMR band');
subplot(4,3,4), plot(t40Hz,EEGpowerdens(:,nrange(4))), title('Mu band');
subplot(4,3,5), plot(t40Hz,EEGpowerdens(:,nrange(5))), title('High Mu band');
subplot(4,3,6), plot(t40Hz,EEGpowerdens(:,nrange(6))), title('Beta band');
subplot(4,3,7), plot(t40Hz,EEGpowerdens(:,nrange(7))), title('Low Gamma band');
subplot(4,3,8), plot(t40Hz,EEGpowerdens(:,nrange(8))), title('Mid Gamma band');
subplot(4,3,9), plot(t40Hz,EEGpowerdens(:,nrange(9))), title('High Gamma band');
%subplot(4,3,10), plot(t1000Hz,longstuff(timerange1000Hz,:))


figure

start2 = (thumbstartstop(2,1)/1000) - 0.5;
stop2 = (thumbstartstop(2,2)/1000) + 0.5;
start1000Hz2 = start2*FsECoG;
stop1000Hz2 = stop2*FsECoG;
timerange1000Hz2 = start1000Hz2:stop1000Hz2; %start1000Hz_2:stop1000Hz_2]; %start1000Hz_3:stop1000Hz_3 ];
t1000Hz2 = ((0:length(timerange1000Hz2)-1)*T1000Hz);

start3 = (thumbstartstop(3,1)/1000) - 0.5;
stop3 = (thumbstartstop(3,2)/1000) + 0.5;
start1000Hz3 = start3*FsECoG;
stop1000Hz3 = stop3*FsECoG;
timerange1000Hz3 = start1000Hz3:stop1000Hz3; %start1000Hz_2:stop1000Hz_2]; %start1000Hz_3:stop1000Hz_3 ];
t1000Hz3 = ((0:length(timerange1000Hz3)-1)*T1000Hz);

start0 = 1.5;
stop0 = 4;
start1000Hz0 = start0*FsECoG;
stop1000Hz0 = stop0*FsECoG;
timerange1000Hz0 = start1000Hz0:stop1000Hz0; %start1000Hz_2:stop1000Hz_2]; %start1000Hz_3:stop1000Hz_3 ];
t1000Hz0 = ((0:length(timerange1000Hz0)-1)*T1000Hz);

t1000Hz = t1000Hz - start;
subplot(4,3,1), plot(t1000Hz,mean(EEGpowerdens_3(timerange1000Hz,:),2), 'r' ,t1000Hz2,mean(EEGpowerdens_3(timerange1000Hz2,:),2), 'g',t1000Hz3,mean(EEGpowerdens_3(timerange1000Hz3,:),2), 'c',t1000Hz0,mean(EEGpowerdens_3(timerange1000Hz0,:),2), 'k'), title('Delta band');
subplot(4,3,2), plot(t1000Hz,mean(EEGpowerdens_4_7(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_4_7(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_4_7(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_4_7(timerange1000Hz0,:),2),'k'),  title('Low-alpha band');
subplot(4,3,3), plot(t1000Hz,mean(EEGpowerdens_7_5_12_5(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_7_5_12_5(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_7_5_12_5(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_7_5_12_5(timerange1000Hz0,:),2),'k'), title('SMR band');
subplot(4,3,4), plot(t1000Hz,mean(EEGpowerdens_8_15(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_8_15(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_8_15(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_8_15(timerange1000Hz0,:),2),'k'), title('Mu band');
subplot(4,3,5), plot(t1000Hz,mean(EEGpowerdens_13_16(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_13_16(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_13_16(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_13_16(timerange1000Hz0,:),2),'k'), title('High Mu band');
subplot(4,3,6), plot(t1000Hz,mean(EEGpowerdens_16_31(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_16_31(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_16_31(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_16_31(timerange1000Hz0,:),2),'k'), title('Beta band');
subplot(4,3,7), plot(t1000Hz,mean(EEGpowerdens_32_50(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_32_50(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_32_50(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_32_50(timerange1000Hz0,:),2),'k'), title('Low Gamma band');
subplot(4,3,8), plot(t1000Hz,mean(EEGpowerdens_51_80(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_51_80(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_51_80(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_51_80(timerange1000Hz0,:),2),'k'), title('Mid Gamma band');
subplot(4,3,9), plot(t1000Hz,mean(EEGpowerdens_80_100(timerange1000Hz,:),2),'r',t1000Hz2,mean(EEGpowerdens_80_100(timerange1000Hz2,:),2),'g',t1000Hz3,mean(EEGpowerdens_80_100(timerange1000Hz3,:),2),'c',t1000Hz0,mean(EEGpowerdens_80_100(timerange1000Hz0,:),2),'k'), title('High Gamma band');
subplot(4,3,10), plot(t1000Hz,longstuff(timerange1000Hz,:),'r',t1000Hz2,longstuff(timerange1000Hz2,:),'g',t1000Hz3,longstuff(timerange1000Hz3,:),'c',t1000Hz0,longstuff(timerange1000Hz0,:),'k')

figure

start = (thumbstartstop(2,1)/1000) - 0.5;
stop = (thumbstartstop(2,2)/1000) + 0.5;
start1000Hz = start*FsECoG;
stop1000Hz = stop*FsECoG;
timerange1000Hz = start1000Hz:stop1000Hz; %start1000Hz_2:stop1000Hz_2]; %start1000Hz_3:stop1000Hz_3 ];
T1000Hz = 1/FsECoG;
t1000Hz = ((0:length(timerange1000Hz)-1)*T1000Hz) + start;


subplot(4,3,1), plot(t1000Hz,EEGpowerdens_3(timerange1000Hz,:)), title('Delta band');
subplot(4,3,2), plot(t1000Hz,EEGpowerdens_4_7(timerange1000Hz,:)), title('Low-alpha band');
subplot(4,3,3), plot(t1000Hz,EEGpowerdens_7_5_12_5(timerange1000Hz,:)), title('SMR band');
subplot(4,3,4), plot(t1000Hz,EEGpowerdens_8_15(timerange1000Hz,:)), title('Mu band');
subplot(4,3,5), plot(t1000Hz,EEGpowerdens_13_16(timerange1000Hz,:)), title('High Mu band');
subplot(4,3,6), plot(t1000Hz,EEGpowerdens_16_31(timerange1000Hz,:)), title('Beta band');
subplot(4,3,7), plot(t1000Hz,EEGpowerdens_32_50(timerange1000Hz,:)), title('Low Gamma band');
subplot(4,3,8), plot(t1000Hz,EEGpowerdens_51_80(timerange1000Hz,:)), title('Mid Gamma band');
subplot(4,3,9), plot(t1000Hz,EEGpowerdens_80_100(timerange1000Hz,:)), title('High Gamma band');
subplot(4,3,10), plot(t1000Hz,longstuff(timerange1000Hz,:))



