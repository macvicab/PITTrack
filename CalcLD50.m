function [LD50] = CalcLD50(D50,db_mm,pathlength,movmem)
% ldist is the thalweg distance for dates 1 and 2
% fimem are the tags found or inferred on both days
z = 1.96;

D50class = floor(log2(D50)*2)/2; % get 0.5 phi size class
%D50class = floor(log2(D50)*2)/2; % get 0.5 phi size class

gooD = log2(db_mm)>=D50class & log2(db_mm)<D50class+0.5;

allmem = gooD & movmem;
nD50 = sum(allmem);


LD50p = mean(log10(pathlength(allmem))); % geometric mean
sd = std(log10(pathlength(allmem)));
CI = z*sd/nD50^0.5;
lowerCI = 10^(LD50p-CI);
upperCI = 10^(LD50p+CI);
LD50 = 10^LD50p;
1;
