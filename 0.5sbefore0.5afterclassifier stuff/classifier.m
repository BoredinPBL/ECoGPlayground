%Classifier

clc
clear

%% initialise
load('sub1_comp.mat')
load('sub1_CubicSVM.mat')
load('sub1_testlabels.mat')
rawsigs = test_data;

Min_band = 2;
Max_band = 200;
notch = 60;
filter_order = 10;
tolerance_sd = 7; %Select the number of standard deviations from the overall MEAN that will be flagged as high
tolerance_n = 500; %Select the number of high values that can be accepted before a lead is dropped
[L,C1] = size(rawsigs);
Fs1 = 1000;
Fs2 = 25;

%% check leads
[midsigs, C2] = preprocessor1(rawsigs, tolerance_sd, tolerance_n);
fprintf('total number of leads used = %.0f\n total number of leads dropped = %.0f\n', C2, C1-C2);

%% filter data
sigspre = preprocessor2(midsigs, Fs1, Min_band, Max_band, notch, filter_order); %preprocessor2_1 also deals with the resonances of the 60Hz
%% Put the comp data into the the format we can read
[singlecolumn,movementswvalues,movements,t2,blurredmovements] = fingerer(Fs1, Fs2, test_dg, 0.2);

longstuff = elongate((Fs1/Fs2),blurredmovements);
%manually shift data back 40ms to synchronise data and match matricies
longstuff(end:end+40,:) = 0;
matchstuff = downsample(longstuff,25);
matchstuff = matchstuff(4:end,:);

%% prepare for the classifier

brainwavebandset = [0.1 3; 4 7; 8 15; 7.5 12.5; 13 16; 16 31; 32 50; 51 80; 80 100];
Bigdata = zeros(7997,C2*length(brainwavebandset));
for i = 1:length(brainwavebandset)
    brainwaveband = brainwavebandset(i,:);
    EEGpowerdens = powerwindower(sigspre, Fs1, brainwaveband);
    EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
    Bigdata(:,(1:C2)+((i-1)*C2)) = EEGpowerdensdowned(4:end,:);
end


%% prediction comparison time!!!

yfit = CubicSVM.predictFcn(Bigdata);
ultimatecomparison = [yfit,matchstuff];
