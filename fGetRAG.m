function [ stRegions, dEdges, dDistances ] = fGetRAG( gInputImg, gLabels, dBandWeights, dWeightSpec, dWeightSmooth, loIsExistWatershedLines )
%FRM_RAG Summary of this function goes here
% stRegions is a structure containing Area, BoundingBox, Perimeter, PixelList, StdDev, BoundBoxPerim
% dEdges shows the existence of edges as 1s and 0s
% dDistances shows merging cost of every edge and contains 0 for non-edges

dInputImg = double(gInputImg);
dLabels = double(gLabels);
dSegCnt=max(dLabels(:));
[dRowCnt,dColCnt,dBandCnt] = size(dInputImg);

% Find regions and their properties
stRegions=regionprops(dLabels,'Area','BoundingBox','Perimeter','PixelList');
for dSegNo=1:1:dSegCnt
    dPixelList = stRegions(dSegNo).PixelList;
    
    % Get standard deviation
    stRegions(dSegNo).StdDev = fGetStdDev(dInputImg,dPixelList);
    
    % Find bounding box perimeter
    stRegions(dSegNo).BoundBoxPerim=2*(stRegions(dSegNo).BoundingBox(3)+stRegions(dSegNo).BoundingBox(4));
end

% Find edges
dEdges = fGetAdjacentRegions(dLabels,loIsExistWatershedLines);
dEdgeCnt = size(dEdges,1);

% Find merging costs
dDistances = zeros(dEdgeCnt,1);
for dEdgeNo=1:1:dEdgeCnt
    dReg1No=dEdges(dEdgeNo,1); dReg2No=dEdges(dEdgeNo,2);
    
    % Find merged region and get its properties
    [dTopLeftRow,dTopLeftCol,dBottomRightRow,dBottomRightCol] = fGetMergedBoundingBox(stRegions(dReg1No).BoundingBox, stRegions(dReg2No).BoundingBox,dRowCnt,dColCnt);
    dSubLabels = dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol); dSubLabels(dSubLabels==dReg2No) = dReg1No;
    dSubInputIm = dInputImg(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol,:);
    dMergedLabels = fMergeSameLabelledRegs(dSubLabels);
    stMergedReg=regionprops(dMergedLabels==dReg1No,'Area','BoundingBox','Perimeter','PixelList');
    stMergedReg(1).StdDev=fGetStdDev(dSubInputIm,stMergedReg(1).PixelList);
    stMergedReg(1).BoundBoxPerim=2*(stMergedReg(1).BoundingBox(3)+stMergedReg(1).BoundingBox(4));
    
    dDistances(dEdgeNo)=fGetMergingCost(stRegions(dReg1No),stRegions(dReg2No),stMergedReg(1),dBandWeights,dWeightSpec,dWeightSmooth);
end

end
