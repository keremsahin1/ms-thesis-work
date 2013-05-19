function [ dPixelClusteredLabels, dObjectClusteredLabels ] = fClustering( dFilteredImg, dLabels, k )
%FCLUSTERÝNG Summary of this function goes here
%   Detailed explanation goes here

[dRowCnt,dColCnt] = size(dLabels);
dSegCnt = max(dLabels(:));
[dHueImg,dSatImg,dValueImg] = rgb2hsv(dFilteredImg/max(dFilteredImg(:)));

dHueImg=(dHueImg-min(dHueImg(:)))/(max(dHueImg(:)-min(dHueImg(:))));
dSatImg=(dSatImg-min(dSatImg(:)))/(max(dSatImg(:)-min(dSatImg(:))));
dValueImg=(dValueImg-min(dValueImg(:)))/(max(dValueImg(:)-min(dValueImg(:))));

dAllFeatVecs = zeros(dRowCnt*dColCnt,3,'double');

for dPixNo=1:1:dRowCnt*dColCnt
    [I J] = ind2sub(size(dLabels),dPixNo);
    dAllFeatVecs(dPixNo,1) = dHueImg(I,J);
    dAllFeatVecs(dPixNo,2) = dSatImg(I,J);
    dAllFeatVecs(dPixNo,3) = dValueImg(I,J);
end

IDX = kmeans(dAllFeatVecs,k);

dPixelClusteredLabels = dLabels;
for dPixNo=1:1:dRowCnt*dColCnt
    dPixelClusteredLabels(dPixNo) = IDX(dPixNo);
end

dObjectClusteredLabels = dLabels;
for dSegNo=1:1:dSegCnt
    dObjectClusteredLabels(dObjectClusteredLabels==dSegNo) = mode(dPixelClusteredLabels(dObjectClusteredLabels==dSegNo));
end
dObjectClusteredLabels = fMergeSameLabelledRegs(dObjectClusteredLabels);
dObjectClusteredLabels = fConvertClassLabels2SegLabels(dObjectClusteredLabels);

end

