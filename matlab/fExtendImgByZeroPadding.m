function gOutputImg = fExtendImgByZeroPadding( gInputImg, dWinSize )
%FEXTENDIMGBYMIRRORING Checked
%   Detailed explanation goes here

dExtSize = (dWinSize-1)/2;
[dRowCnt dColCnt dBandCnt] = size(gInputImg);
gOutputImg = zeros(dRowCnt+2*dExtSize,dColCnt+2*dExtSize,dBandCnt,class(gInputImg));

% Copy input to output
gOutputImg(1+dExtSize:dRowCnt+dExtSize,1+dExtSize:dColCnt+dExtSize,:) = gInputImg;

end
