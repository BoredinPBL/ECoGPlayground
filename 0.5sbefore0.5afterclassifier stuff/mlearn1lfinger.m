%A version of the feature extractor that receives the time sections in
%seconds rather than in 

clear
clc

%% Load and initialise

load('sigspre')
load('matlab-blurredmovements.mat')
load('Randpowerdensities.mat')
load('thumbmoving.mat') %gives the time intervals (in ms) that the thumb starts and stops moving
[L,C] = size(sigspre);


%frequency variables
FsFingers = 25;
FsECoG = 1000;

%scale-up the finger data
longstuff = elongate((FsECoG/FsFingers),blurredmovements);
%manually shift data back 40ms to synchronise data and match matricies
longstuff(end:end+40,:) = 0;

%time variables
timerange = (0.001:0.001:400)*FsECoG;

timerangethumb = zeros(length(thumbstartstop),1001);
for n = 1:length(thumbstartstop)
timerangethumb(n,:) = timerange((thumbstartstop(n,1)-500):(thumbstartstop(n,1)+500));
end 
%This look populates a matrix where the row corresponds to the nth time the
%thumb moves. The column corresponds to a milisecond with the moment the
%thumb starts moving at point 501


brainwavebandset = [0.1 3; 4 7; 8 15; 7.5 12.5; 13 16; 16 31; 32 50; 51 80; 80 100];
%% All data loaded, select time of interest in seconds

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
