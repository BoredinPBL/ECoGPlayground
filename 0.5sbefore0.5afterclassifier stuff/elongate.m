function [ longstuff ] = elongate(multiplier,shortstuff)
%quick little function which kind of upsamples. Useful for my finger
%movement functions
%   Take finger classification data and upsample it without filling it with
%   zeros
%  multiplier needs to be given to specify by what factor the matrix needs
%  to be elongated by. Fills all the new points in with finger
%  classification number

n=1;
longstuff = zeros(multiplier*length(shortstuff),1);
while (n <=length(shortstuff))
     if shortstuff(n) ~= 0
        interesting = shortstuff(n);
        i = 1 + (multiplier*(n-1));
        j = multiplier*n;
        longstuff(i:j) = interesting;
        n = n+1;
    else
        n= n+1;
    end
end

end

