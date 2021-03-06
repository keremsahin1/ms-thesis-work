function [ dRenumberedLabels, dSegCnt, dComputTime  ] = fRegionMerge1( gInputImg, gLabels, dScaleThresh, dWeightSpec, dWeightSmooth, loIsExistWatershedLines )
%FRM_ECOGNITION2 Summary of this function goes here
% Paper: A new process for the segmentation of high resolution remote
% sensing imagery

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

dSegCnt=max(dLabels(:));
dSegNumbers = 1:1:dSegCnt;

% Form dSegAreas matrix
dSegAreas=zeros(dSegCnt,1);
for dSegNo=1:1:size(dSegAreas,1)
    dSegAreas(dSegNo)=stRegions(dSegNo).Area;
end

% Find Cmin
Cmin=min(dSegAreas(dSegAreas~=0));

while dScaleThresh>=Cmin
    % Find mergable edges
    dMinScaleRegs=dSegNumbers(dSegAreas==Cmin)';
    dMergableEdgeInds = fGetCorresEdgesFromEdgeMap(dEdges,dMinScaleRegs);
    
    if isempty(dMergableEdgeInds)~=1
        % Find merging costs of mergable edges
        dMergableEdgeDists=dDistances(dMergableEdgeInds);
        
        % Find regions that have minimum merging cost
        [~,dMinDistEdgeInd]=min(dMergableEdgeDists);
        
        % Find corresponding regions
        dRegNo1=dEdges(dMergableEdgeInds(dMinDistEdgeInd),1); dRegNo2=dEdges(dMergableEdgeInds(dMinDistEdgeInd),2);
        
        % Remove the edge and distance between merged regions
        dEdges = [dEdges(1:dMergableEdgeInds(dMinDistEdgeInd)-1,:); dEdges(dMergableEdgeInds(dMinDistEdgeInd)+1:end,:)];
        dDistances = [dDistances(1:dMergableEdgeInds(dMinDistEdgeInd)-1); dDistances(dMergableEdgeInds(dMinDistEdgeInd)+1:end)];
    else
        warning('Region that has no neighbor!');
        [r,c,v] = find(dLabels==dMinScaleRegs(1));
        dPortion = dLabels(r-2:r+2,c-2:c+2);
        
        dRegNo2 = dMinScaleRegs(1);
        dRegNo1 = mode(dPortion(dPortion~=0 & dPortion~=dRegNo2));
    end
    
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
    
    % Update regions structure and labels
    stRegions(dRegNo2).Area = 0;
    stRegions(dRegNo1) = stMergedReg(1);
    dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol) = dMergedLabels;
    
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
        dUpdRegNo1=dEdges(dUpdateRow(dUpdateNo),1); dUpdRegNo2=dEdges(dUpdateRow(dUpdateNo),2);
        
        % Find merged region and its properties
        [dTopLeftRow,dTopLeftCol,dBottomRightRow,dBottomRightCol] = fGetMergedBoundingBox(stRegions(dUpdRegNo1).BoundingBox,stRegions(dUpdRegNo2).BoundingBox,dRowCnt,dColCnt);
        dSubLabels = dLabels(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol); dSubLabels(dSubLabels==dUpdRegNo2) = dUpdRegNo1;
        dMergedLabels = fMergeSameLabelledRegs(dSubLabels);
        dSubInputIm = dInputImg(dTopLeftRow:dBottomRightRow, dTopLeftCol:dBottomRightCol,:);
        stMergedReg=regionprops(dMergedLabels==dUpdRegNo1,'Area','BoundingBox','Perimeter','PixelList');
        stMergedReg(1).StdDev=fGetStdDev(dSubInputIm,stMergedReg(1).PixelList);
        stMergedReg(1).BoundingBox(1) = stMergedReg(1).BoundingBox(1) + (dTopLeftCol-1);
        stMergedReg(1).BoundingBox(2) = stMergedReg(1).BoundingBox(2) + (dTopLeftRow-1);
        stMergedReg(1).BoundBoxPerim=2*(stMergedReg(1).BoundingBox(3)+stMergedReg(1).BoundingBox(4));
        
        dDistances(dUpdateRow(dUpdateNo))=fGetMergingCost(stRegions(dUpdRegNo1),stRegions(dUpdRegNo2),stMergedReg(1),dBandWeights,dWeightSpec,dWeightSmooth);
    end
    
    % Update dSegAreas matrix
    dSegAreas(dRegNo1)=stRegions(dRegNo1).Area; dSegAreas(dRegNo2)=stRegions(dRegNo2).Area;
    
    % Find Cmin
    Cmin=min(dSegAreas(dSegAreas~=0));
end

[dRenumberedLabels,dSegCnt] = fRenumberLabels(dLabels);
dComputTime = toc;

end
