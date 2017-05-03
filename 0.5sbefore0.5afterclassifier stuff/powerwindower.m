function [EEGpowerdens] = powerwindower(sigspre, Fs, brainwaveband)
%The purpose of this function is to compress the data from the ECoG from BCI
%convert the 
%   Detailed explanation goes here

[L,C] = (size(sigspre));
EEGpowerdens = zeros(L,C);


m=1:C;
n=100;
while (n <= L)
    EEGpowerdens(n,m) = bandpower(sigspre(((n-99:n)),m),Fs, brainwaveband);
    n = n+25;
end
