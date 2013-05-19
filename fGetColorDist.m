function [ dDistance ] = fGetColorDist( gFirstPix, gSecondPix )
%FGETCOLORDIST Checked
%   Detailed explanation goes here

dFirstPix = double(gFirstPix);
dSecondPix = double(gSecondPix);
dBandCnt = size(dFirstPix,3);

dDistance = 0;
for dBandNo=1:1:dBandCnt
    dDistance = dDistance + (dFirstPix(dBandNo)-dSecondPix(dBandNo))^2;
end
dDistance = sqrt(dDistance);

end

