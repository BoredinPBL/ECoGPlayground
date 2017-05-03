%This code creates a feature matrix to be used for machine learning
%classifier - it gathers data from the .5s before and after the onset of a
%movement.

clear
clc

%% Load and initialise

load('sub1_fingerstartstops.mat') %gives the time intervals (in ms) that the fingers start and stop moving - made through visual inspection
load('sub1_comp.mat')
rawsigs = train_data; %load the EEG data here

[L,C1] = size(rawsigs);
Fs1 = 1000; %Sampling frequency set to 1000Hz
Fs2 = 25; %frequency of the finger data
filter_order = 2; %used in preprocessor2
Min_band = 2;
Max_band = 500;
Filter_out = 60;
tolerance_sd = 10; %Select the number of standard deviations from the overall MEAN that will be flagged as high
tolerance_n = 1000; %Select the number of high values that can be accepted before a lead is dropped


%% This section should perform the pre-processing of the data. It should
%%bandpass min->max and null out 60Hz. Outsourced to preprocessor2 function

[midsigs, C2] = preprocessor1(rawsigs, tolerance_sd, tolerance_n); %Note C is a scalar value that corresponds to the number of acceptable leads
fprintf('number of leads dropped = %f\n', C1-C2);
sigspre = preprocessor2(midsigs, Fs1, Min_band, Max_band, Filter_out, filter_order);


%% This is where the actual processing begins
%sigspre = 10000*rand(400000,61);
[L,C] = size(sigspre);
brainwavebandset = [0.1 3; 4 7; 8 15; 7.5 12.5; 13 16; 16 31; 32 50; 51 80; 80 100];


%frequency variables
FsFingers = 25;
FsECoG = 1000;

%time variables
timerange = (0.001:0.001:400)*FsECoG;

%% All data loaded, select time of interest in seconds
%thumb

timerangethumb = zeros(length(thumbstartstop),1001);
for n = 1:length(thumbstartstop)
timerangethumb(n,:) = timerange((thumbstartstop(n,1)-500):(thumbstartstop(n,1)+500));
end 
%This populates a matrix where the row corresponds to the nth time the
%thumb moves. The column corresponds to a milisecond with the moment the
%thumb starts moving at point 501

mlearn = zeros(41*length(thumbstartstop),(C*length(brainwavebandset)+1));
for i = 1:length(brainwavebandset)

mlearnworking = zeros(41*length(thumbstartstop),C);
brainwaveband = brainwavebandset(i,:);
for n = 1:length(thumbstartstop)
ActiveECoGRange = sigspre(floor((timerangethumb(n,1)-100)):floor((timerangethumb(n,end))),:); %-100 extension required so the script is able to cut out the zero values
EEGpowerdens = powerwindower(ActiveECoGRange, FsECoG, brainwaveband);
EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
mlearnworking((1:41)+((n-1)*41),:) = EEGpowerdensdowned(4:end,:);
end
mlearn(:,(1:61)+((i-1)*61)) = mlearnworking;

end


for n = 1:length(thumbstartstop)
    mlearn((1:20)+((n-1)*41),C*length(brainwavebandset)+1) = 0;
    mlearn((21:41)+((n-1)*41),C*length(brainwavebandset)+1) = 1;
end

%finger2

timerangefinger2 = zeros(length(finger2startstop),1001);
for n = 1:length(finger2startstop)
timerangefinger2(n,:) = timerange((finger2startstop(n,1)-500):(finger2startstop(n,1)+500));
end 
mlearn2 = zeros(41*length(finger2startstop),(C*length(brainwavebandset)+1));
for i = 1:length(brainwavebandset)

mlearnworking2 = zeros(41*length(finger2startstop),C);
brainwaveband = brainwavebandset(i,:);
for n = 1:length(finger2startstop)
ActiveECoGRange = sigspre(floor((timerangefinger2(n,1)-100)):floor((timerangefinger2(n,end))),:); %-100 extension required so the script is able to cut out the zero values
EEGpowerdens = powerwindower(ActiveECoGRange, FsECoG, brainwaveband);
EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
mlearnworking((1:41)+((n-1)*41),:) = EEGpowerdensdowned(4:end,:);
end
mlearn2(:,(1:61)+((i-1)*61)) = mlearnworking;

end
for n = 1:length(finger2startstop)
    mlearn2((1:20)+((n-1)*41),C*length(brainwavebandset)+1) = 0;
    mlearn2((21:41)+((n-1)*41),C*length(brainwavebandset)+1) = 2;
end

%finger3
timerangefinger3 = zeros(length(finger3startstop),1001);
for n = 1:length(finger3startstop)
timerangefinger3(n,:) = timerange((finger3startstop(n,1)-500):(finger3startstop(n,1)+500));
end 
mlearn3 = zeros(41*length(finger3startstop),(C*length(brainwavebandset)+1));
for i = 1:length(brainwavebandset)

mlearnworking3 = zeros(41*length(finger3startstop),C);
brainwaveband = brainwavebandset(i,:);
for n = 1:length(finger3startstop)
ActiveECoGRange = sigspre(floor((timerangefinger3(n,1)-100)):floor((timerangefinger3(n,end))),:); %-100 extension required so the script is able to cut out the zero values
EEGpowerdens = powerwindower(ActiveECoGRange, FsECoG, brainwaveband);
EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
mlearnworking((1:41)+((n-1)*41),:) = EEGpowerdensdowned(4:end,:);
end
mlearn3(:,(1:61)+((i-1)*61)) = mlearnworking;

end
for n = 1:length(finger3startstop)
    mlearn3((1:20)+((n-1)*41),C*length(brainwavebandset)+1) = 0;
    mlearn3((21:41)+((n-1)*41),C*length(brainwavebandset)+1) = 3;
end

%finger5
timerangefinger5 = zeros(length(finger5startstop),1001);
for n = 1:length(finger5startstop)
timerangefinger5(n,:) = timerange((finger5startstop(n,1)-500):(finger5startstop(n,1)+500));
end 
mlearn5 = zeros(41*length(finger5startstop),(C*length(brainwavebandset)+1));
for i = 1:length(brainwavebandset)

mlearnworking5 = zeros(41*length(finger5startstop),C);
brainwaveband = brainwavebandset(i,:);
for n = 1:length(finger5startstop)
ActiveECoGRange = sigspre(floor((timerangefinger5(n,1)-100)):floor((timerangefinger5(n,end))),:); %-100 extension required so the script is able to cut out the zero values
EEGpowerdens = powerwindower(ActiveECoGRange, FsECoG, brainwaveband);
EEGpowerdensdowned = downsample(EEGpowerdens,25,24);
mlearnworking((1:41)+((n-1)*41),:) = EEGpowerdensdowned(4:end,:);
end
mlearn5(:,(1:61)+((i-1)*61)) = mlearnworking;

end
for n = 1:length(finger5startstop)
    mlearn5((1:20)+((n-1)*41),C*length(brainwavebandset)+1) = 0;
    mlearn5((21:41)+((n-1)*41),C*length(brainwavebandset)+1) = 5;
end


mlearnclassifier = [mlearn;mlearn2;mlearn3;mlearn5];

