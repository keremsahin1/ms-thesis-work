function [ dRenumberedLabels, dSegCnt, dComputTime ] = fRegionMerge2( gInputImg, gLabels, dScaleThresh, dWeightSpec, dWeightSmooth, loIsExistWatershedLines )
%FRM_ECOGNITION Summary of this function goes here
% Paper: Segmentation of Multi-spectral Satellite Images Based on Watershed
% Algorithm

tic;

dInputImg = double(gInputImg);
dLabels = double(gLabels);

[dRowCnt,dColCnt,dBandCnt] = size(dInputImg);
dBandWeights = zeros(dBandCnt,1);

% Obtain RAG
for dBandNo=1:1:dBandCnt
    dBandWeights(dBandNo) = 1/dBandCnt;
end

[stRegions,dEdges,dDistances]=fGetRAG(dInputImg,dLabels,dBandWeights,dWeightSpec,dWeightSmooth,loIsExistWatershedLines);

% Get minimum distance and corresponding edge
[dMinDistVal,dMinDistEdgeIndex]=min(dDistances);
dRegNo1=dEdges(dMinDistEdgeIndex,1);
dRegNo2=dEdges(dMinDistEdgeIndex,2);

while dMinDistVal<=dScaleThresh
    
    % Find merged region and its properties
    [dTopLeftRow,dTopLeftCol,dBottomRightRow,dBottomRightCol] = fGetMergedBoundingBox(stRegions(dRegNo1).BoundingBox,stRegions(dRegNo2).BoundingBox,dRowCnt,dColCnt);
    dSubLabels = dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol); dSubLabels(dSubLabels==dRegNo2) = dRegNo1;
    dSubInputIm = dInputImg(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol,:);
    dMergedLabels = fMergeSameLabelledRegs(dSubLabels);
    stMergedReg=regionprops(dMergedLabels==dRegNo1,'Area','BoundingBox','Perimeter','PixelList');
    stMergedReg(1).StdDev=fGetStdDev(dSubInputIm,stMergedReg(1).PixelList);
    stMergedReg(1).BoundingBox(1) = stMergedReg(1).BoundingBox(1) + (dTopLeftCol-1);
    stMergedReg(1).BoundingBox(2) = stMergedReg(1).BoundingBox(2) + (dTopLeftRow-1);
    stMergedReg(1).BoundBoxPerim=2*(stMergedReg(1).BoundingBox(3)+stMergedReg(1).BoundingBox(4));
    
    % Update regions structure and labels
    stRegions(dRegNo1) = stMergedReg(1);
    dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol) = dMergedLabels;
    
    % Remove the edge and distance between merged regions
    dEdges = [dEdges(1:dMinDistEdgeIndex-1,:); dEdges(dMinDistEdgeIndex+1:end,:)];
    dDistances = [dDistances(1:dMinDistEdgeIndex-1); dDistances(dMinDistEdgeIndex+1:end)];
    
    % Convert dRegNo2s to dRegNo1s
    [dEdges,dUpdates] = fUpdateEdges(dEdges,dRegNo2,dRegNo1);
    
    % Remove repeated edges and sort edges
    [dEdges, dRowSortInd] = sortrows(dEdges);
    [dEdges, dUniqueRowInd, ~] = unique(dEdges,'rows');
    
    dDistances = dDistances(dRowSortInd); dDistances = dDistances(dUniqueRowInd);
    dUpdates = dUpdates(dRowSortInd); dUpdates = dUpdates(dUniqueRowInd);
    
    % Update distances
    [dUpdateRow,~,~] = find(dUpdates);
    for dUpdateNo=1:1:size(dUpdateRow,1)
        dRegNo1=dEdges(dUpdateRow(dUpdateNo),1); dRegNo2=dEdges(dUpdateRow(dUpdateNo),2);
        
        % Find merged region and its properties
        [dTopLeftRow,dTopLeftCol,dBottomRightRow,dBottomRightCol] = fGetMergedBoundingBox(stRegions(dRegNo1).BoundingBox,stRegions(dRegNo2).BoundingBox,dRowCnt,dColCnt);
        dSubLabels = dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol); dSubLabels(dSubLabels==dRegNo2) = dRegNo1;
        dMergedLabels = fMergeSameLabelledRegs(dSubLabels);
        dSubInputIm = dInputImg(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol,:);
        stMergedReg=regionprops(dMergedLabels==dRegNo1,'Area','BoundingBox','Perimeter','PixelList');
        stMergedReg(1).StdDev=fGetStdDev(dSubInputIm,stMergedReg(1).PixelList);
        stMergedReg(1).BoundingBox(1) = stMergedReg(1).BoundingBox(1) + (dTopLeftCol-1);
        stMergedReg(1).BoundingBox(2) = stMergedReg(1).BoundingBox(2) + (dTopLeftRow-1);
        stMergedReg(1).BoundBoxPerim=2*(stMergedReg(1).BoundingBox(3)+stMergedReg(1).BoundingBox(4));
        
        dDistances(dUpdateRow(dUpdateNo))=fGetMergingCost(stRegions(dRegNo1),stRegions(dRegNo2),stMergedReg(1),dBandWeights,dWeightSpec,dWeightSmooth);
    end
    
    % Get minimum distance and corresponding edge
    [dMinDistVal,dMinDistEdgeIndex]=min(dDistances);
    dRegNo1=dEdges(dMinDistEdgeIndex,1);
    dRegNo2=dEdges(dMinDistEdgeIndex,2);
end

% Save current scale

[dRenumberedLabels,dSegCnt] = fRenumberLabels(dLabels);
dComputTime = toc;

end
