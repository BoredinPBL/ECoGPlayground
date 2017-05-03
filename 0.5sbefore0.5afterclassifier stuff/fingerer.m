function [singlecolumn,movementswvalues,movements,t2,blurredmovements] = fingerer(Fs1, Fs2, finger, cutoff)
%Based on the available data about the movement of the fingers, this
%function will produce an output of a matrix with columns equal to the
%number of fingers that is 1 when the finger is moving, and 0 when it is
%not.

%Fingerer 3 also produces a single column matrix which contains numbers
%labelled 1-5 which correspond to each finger

%Fs1 is the sampling frequency of the dataset
%Fs2 is the sampling frequency of the dataglove
%Fs3 is a the desired output frequency
%finger is the matrix which represents the position of each finger in a
%column
%cuttoff is the minimum velocity available for a 
%L is the length of the finger matrix

[L,C] = size(finger);
%T = 1/Fs;
%t = (0:L-1)*T;
T2 = 1/Fs2;
t2 = (0:(L*(Fs2/Fs1)-2))*T2;

movements = diff(downsample(finger,(Fs1/Fs2))); %downsample and get rate of change
movementswvalues = movements;

Ldiffed = (L*(Fs2/Fs1))-1;
singlecolumn = zeros(Ldiffed,1);%create a column vector that can contain 1-5 
absmovements = abs(movements);

n=1;
while n <= C
    m=1;
    while m <=Ldiffed
    if absmovements(m,n) < cutoff
        m=m+1;
    elseif singlecolumn(m,1) ~= 0 && absmovements(m,n) > absmovements(m,singlecolumn(m,1))
        singlecolumn(m,1) = n;
        m=m+1;
    elseif singlecolumn(m,1) == 0 && absmovements(m,n) > cutoff 
        singlecolumn(m,1) = n;
        m=m+1;
    else
        m=m+1;
    end
    end
    n=n+1;
end

%make another output called blurred movements
%find when a number is not equal to zero, keep looking until the number and
%its 25 neighbours are zero then print a whole lotta numbers. Maybe for
%next time. See how blurred holds up
%this time don't downsample
blurredmovements = zeros(Ldiffed,1);

m=1;
    while m <=Ldiffed
        if singlecolumn(m,1) ~= 0
            i = singlecolumn(m,1); %is when the finger starts moving
            n=1;
            while n+m <=Ldiffed
                if singlecolumn(m+n,1) == 0
                    if singlecolumn(m+n+1,1) ==0 && singlecolumn(m+n+2,1) ==0 && singlecolumn(m+n+3,1) == 0 && singlecolumn(m+n+4,1) == 0
                        j = m+n; % is when the finger stops moving
                        break   
                    else
                        n = n+1;
                    end
                else
                    n = n+1;
                end
            end 
            blurredmovements(m:j) = i;
            m = m+1;
        else
            m = m+1;
            
        end
    end

movements(absmovements<cutoff)=0; %treat any values below cuttoff as zero
movements(absmovements>cutoff)=1; %treat any values above cutoff as one

end

