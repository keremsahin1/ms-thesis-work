function [ dSegLabels ] = fConvertClassLabels2SegLabels( dClassLabels )
%FCONVERTCLASSLABELS2SEGLABELS Summary of this function goes here
%   Detailed explanation goes here

dClassCnt = max(dClassLabels(:));
dSegLabels = zeros(size(dClassLabels),'double');

dSegCnt = 0;
for dClassNo=1:1:dClassCnt
    cc = bwconncomp(dClassLabels==dClassNo);
    for dCurrSegNo = 1:1:(cc.NumObjects)
        dSegCnt = dSegCnt + 1;
        dSegLabels(cc.PixelIdxList{dCurrSegNo}) = dSegCnt;
    end
end

end

