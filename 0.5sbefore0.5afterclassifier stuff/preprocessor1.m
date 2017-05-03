function [goodleads, good_n] = preprocessor1(rawsigs, tolerance_sd, tolerance_n)
%Function with the goal to drop any leads filled with artifact
% Follows these steps
% 1. Counts the number of values outside the tolerance parameters in each lead
% 2. Counts the number of leads with too many outside values
% 3. Generates a new matrix with less columns
% 4. Fills the new matrix with the good leads

% Produces the good leads in a matrix and a scalar that corresponds to the
% number of good leads

[L,C] = (size(rawsigs));  %L = length, C=channels
S = median(std(rawsigs)); %calculates standard deviation of each lead
M = mean2(rawsigs); %calculates median of each lead
leadindex = zeros(1,C); %index which contains the leads to be dropped

n=1;
while n <= C
    m=1;
    while m <=L
    if rawsigs(m,n) > M + tolerance_sd*S || rawsigs(m,n) < M - tolerance_sd*S
       leadindex(1,n) = leadindex(1,n) + 1;
       m=m+1;
    else
        m=m+1;
    end
    end
    n=n+1;
end

%number of good leads
n = 1;
nbad = 0;
while n <=C
   if leadindex(1,n) >= tolerance_n
    nbad = nbad +1;
    n=n+1;
   else
    n=n+1;
   end
end

goodleads = zeros(L,C-nbad); %maybe use some counter to record the number of leads to be dropped?
n = 1; %n counts the column being checked
i = 0; %i increases when you pass over a lead to be dropped
while n <=C
   if leadindex(1,n) <= tolerance_n
    goodleads(:,n-i) = rawsigs(:,n);
    n=n+1;
   else
    n=n+1;
    i = i+1;
   end
end

good_n = C -i;
end

