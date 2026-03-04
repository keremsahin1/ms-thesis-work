function [ dAvgVar, dMoransI ] = fFindVariance_MoransI_New( gInputImg, gLabels, loIsExistWatershedLines )
%FFINDVARIANCE_MORANSI Checked
% gInputImg can be any dimensional

dInputImg = double(gInputImg);
dLabels = double(gLabels);

dAdjRegs = fGetAdjacentRegions(dLabels,loIsExistWatershedLines);
%dAdjRegs = fGetAdjacentRegions_8Connected(dLabels);
dEdgeCnt = size(dAdjRegs,1);

structRegionsStats = regionprops(dLabels,'Area','PixelList');
dSegCnt = max(dLabels(:));
dBandCnt = size(dInputImg,3);
dSegMeanColors = zeros(dSegCnt,dBandCnt,'double');

% Find average mean and variance of the image

dTotalAreaOfAllSegments = 0;
dTotalColorOfAllSegments = zeros(dBandCnt,1,'double');
dTotalWeightedVarOfAllSegments = zeros(dBandCnt,1,'double');
for dSegNo=1:1:dSegCnt
    dAreaOfCurrentSegment = structRegionsStats(dSegNo).Area;
    dPixelListOfCurrentSegment = structRegionsStats(dSegNo).PixelList;
    
	% Get current segment's pixel values and mean color
    dPixValsOfCurrentSegment = zeros(dAreaOfCurrentSegment,dBandCnt,'double');
    dTotalColorOfCurrentSegment = zeros(dBandCnt,1,'double');
    for dPixNo=1:1:dAreaOfCurrentSegment
	    dPixX = dPixelListOfCurrentSegment(dPixNo,2);
        dPixY = dPixelListOfCurrentSegment(dPixNo,1);
		
		dPixValsOfCurrentSegment(dPixNo,:) = dInputImg(dPixX,dPixY,:);
		dTotalColorOfCurrentSegment = dTotalColorOfCurrentSegment + dPixValsOfCurrentSegment(dPixNo,:)';
    end
    dSegMeanColors(dSegNo,:) = dTotalColorOfCurrentSegment/dAreaOfCurrentSegment;
    
    for dBandNo=1:1:dBandCnt
        dTotalWeightedVarOfAllSegments(dBandNo) = dTotalWeightedVarOfAllSegments(dBandNo) + dAreaOfCurrentSegment*var(dPixValsOfCurrentSegment(:,dBandNo));
    end
    
    dTotalAreaOfAllSegments = dTotalAreaOfAllSegments + dAreaOfCurrentSegment;
	dTotalColorOfAllSegments = dTotalColorOfAllSegments + dTotalColorOfCurrentSegment;
end

dAvgVar = dTotalWeightedVarOfAllSegments/dTotalAreaOfAllSegments;
dAvgMean = dTotalColorOfAllSegments/dTotalAreaOfAllSegments;

% Find Moran's I

% find denominator
dSegMean2AvgMeanDist = zeros(dSegCnt,dBandCnt,'double');
dMoransIDenom = zeros(dBandCnt,1,'double');
for dSegNo=1:1:dSegCnt

    dSegMean2AvgMeanDist(dSegNo,:) = dSegMeanColors(dSegNo,:)-dAvgMean';
	
    dMoransIDenom = dMoransIDenom + dSegMean2AvgMeanDist(dSegNo,:)'.^2;
end
dMoransIDenom = dMoransIDenom * dEdgeCnt;

% find nominator
dMoransINom = zeros(dBandCnt,1,'double');
for dEdgeNo=1:1:dEdgeCnt
    
    dFromSegNo = dAdjRegs(dEdgeNo,1);
    dToSegNo = dAdjRegs(dEdgeNo,2);
    
    dMoransINom = dMoransINom + dSegMean2AvgMeanDist(dFromSegNo,:)'.*dSegMean2AvgMeanDist(dToSegNo,:)';
    
end
dMoransINom = dMoransINom * dSegCnt;

dMoransI = dMoransINom./dMoransIDenom;


end
