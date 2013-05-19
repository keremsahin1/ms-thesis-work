function gOutputImg = fExtendImgByMirroring( gInputImg, dWinSize )
%FEXTENDIMGBYMIRRORING Checked
%   Detailed explanation goes here

dExtSize = (dWinSize-1)/2;
[dRowCnt dColCnt dBandCnt] = size(gInputImg);
gOutputImg = zeros(dRowCnt+2*dExtSize,dColCnt+2*dExtSize,dBandCnt,class(gInputImg));

% Copy input to output
gOutputImg(1+dExtSize:dRowCnt+dExtSize,1+dExtSize:dColCnt+dExtSize,:) = gInputImg;

% Extend in vertical direction
for dRowNo = 1:1:dExtSize
    gOutputImg(dRowNo,:,:) = gOutputImg(2*dExtSize+1-dRowNo,:,:);
    gOutputImg(dRowCnt+dExtSize+dRowNo,:,:) = gOutputImg(dRowCnt+dExtSize+1-dRowNo,:,:);
end

% Extend in horizontal direction
for dColNo = 1:1:dExtSize
    gOutputImg(:,dColNo,:) = gOutputImg(:,2*dExtSize+1-dColNo,:);
    gOutputImg(:,dColCnt+dExtSize+dColNo,:) = gOutputImg(:,dColCnt+dExtSize+1-dColNo,:);
end

end
