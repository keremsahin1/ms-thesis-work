function [ dEvRes1, dEvRes2, dWrongSegmentedPixels ] = fSegDiscrepEval( gGTClassLabels, gFoundLabels )
%FDISCREPANCYEVALUATION Checked 29.08
% Paper: Assessment of Very High Spatial Resolution Satellite Image Segmentations

dGTClassLabels = double(gGTClassLabels);
dFoundLabels = double(gFoundLabels);

dFoundSegCnt = max(dFoundLabels(:));
dGTClassCnt = max(dGTClassLabels(:));

dUpdFoundLabels = zeros(size(dFoundLabels),'double');
dGTSegLabels = zeros(size(dFoundLabels),'double');

dWrongSegmentedPixels = zeros(size(dFoundLabels),'double');

% Generate ground truth segment labels
dGTSegCnt = 0;
for dGTClassNo=1:1:dGTClassCnt
    cc = bwconncomp(dGTClassLabels==dGTClassNo);
    for dCurrSegNo = 1:1:(cc.NumObjects)
        dGTSegCnt = dGTSegCnt + 1;
        dGTSegLabels(cc.PixelIdxList{dCurrSegNo}) = dGTSegCnt;
    end
end

% Update found labels
structRegionPropsFound = regionprops(dFoundLabels,'PixelIdxList');
for dSegNo=1:1:dFoundSegCnt
    dPixelIdxList = structRegionPropsFound(dSegNo).PixelIdxList;
        
    dCorresLabels = dGTSegLabels(dPixelIdxList);
    dUpdFoundLabels(dPixelIdxList) = mode(dCorresLabels);
end

% Create confusion matrix and find wrongly segmented pixels
dConfusMat = zeros(dGTSegCnt,'double');
for dGTSegNo=1:1:dGTSegCnt
    dCorresLabels = dUpdFoundLabels(dGTSegLabels==dGTSegNo);
    
    for dFoundSegNo=1:1:dGTSegCnt
        dConfusMat(dFoundSegNo,dGTSegNo) = length(dCorresLabels(dCorresLabels==dFoundSegNo));
    end
    
    dWrongSegmentedPixels((dGTSegLabels==dGTSegNo) & (dUpdFoundLabels ~= dGTSegNo) & (dUpdFoundLabels ~= 0)) = 1;
end

% Calculate first evaluation measure result
dConfusMatTotalSum = sum(dConfusMat(:));
dConfusMatDiagSum = trace(dConfusMat);

dEvRes1 = ((dConfusMatTotalSum-dConfusMatDiagSum)/dConfusMatTotalSum)*100;

% Calculate second evaluation measure result
dEvRes2 = 0;
for dColNo=1:1:dGTSegCnt
    dRefRegArea = sum(dConfusMat(:,dColNo));
    dWrongPixCnt = dRefRegArea-dConfusMat(dColNo,dColNo);
    
    dEvRes2 = dEvRes2 + dWrongPixCnt*100/dRefRegArea;
end
dEvRes2 = dEvRes2/dGTSegCnt;

end

