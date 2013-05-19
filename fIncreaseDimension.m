function [ gOutputImg ] = fIncreaseDimension( gInputImg, dDimCnt )
%FINCREASEDIMENSION Checked
%   Detailed explanation goes here


gOutputImg = gInputImg;

for dDimNo = 2:1:dDimCnt
    gOutputImg(:,:,dDimNo) = gInputImg;
end

end

