function [sigspre] = preprocessor2( rawsigs, Fs1, Min_band, Max_band, Filter_out, filter_order )
%Bandpasses wave data according to parameters
% Program made for handling BCI data. Accept ECoG data and filter according
% to the below parameters
%Rawsigs = ECoG data
%Fs1 = Sampling rate of the ECoG data
%Min_band = The minimum accepted frequency
%Max_band = The maximum accepted frequency
%Filter_out = The frequency to cull - useful for removing mains noise

%Create the filters to be applied
d = designfilt('bandstopiir','FilterOrder',filter_order,... 
'HalfPowerFrequency1', (Filter_out -.1), 'HalfPowerFrequency2', (Filter_out +.1),...
'DesignMethod','butter','SampleRate',Fs1);

d2 = designfilt('bandstopiir','FilterOrder',filter_order,... 
'HalfPowerFrequency1', (Filter_out*2 -.1), 'HalfPowerFrequency2', (Filter_out*2 +.1),...
'DesignMethod','butter','SampleRate',Fs1);

d3 = designfilt('bandstopiir','FilterOrder',filter_order,... 
'HalfPowerFrequency1', (Filter_out*3 -.1), 'HalfPowerFrequency2', (Filter_out*3 +.1),...
'DesignMethod','butter','SampleRate',Fs1);

d4 = designfilt('bandpassiir','FilterOrder',filter_order,...
'HalfPowerFrequency1', Min_band, 'HalfPowerFrequency2',Max_band,...
'SampleRate',Fs1);

sigspre = filtfilt(d4, filtfilt(d3, filtfilt(d2,filtfilt(d,rawsigs))));


end

