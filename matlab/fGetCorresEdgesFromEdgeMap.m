function dCorresEdgeInds = fGetCorresEdgesFromEdgeMap( dEdges, dRegsList )
%FGETADJREGSFROMEDGEMAP Summary of this function goes here
%   Detailed explanation goes here

dCorresEdgeInds = [];
dRegCnt = size(dRegsList,1);
dMaxRegNo = max(dRegsList);

% Form dEdgeCnt matrix
dEdgeCnt = zeros(dMaxRegNo,1);
dEdgeNo = 1;
while dEdges(dEdgeNo,1) <= dMaxRegNo
    dRegNo = dEdges(dEdgeNo,1);
    dEdgeCnt(dRegNo) = dEdgeCnt(dRegNo) + 1;
    dEdgeNo = dEdgeNo + 1;
    
    if dEdgeNo > size(dEdges,1)
        break;
    end
end

% Find ROI of edges
for dListInd=1:1:dRegCnt
    dRegNo = dRegsList(dListInd);
    dEdgesROI = dEdges(1:sum(dEdgeCnt(1:dRegNo)),:);
    [dRows,~,~] = find(dEdgesROI==dRegNo);
    dCorresEdgeInds = [dCorresEdgeInds;dRows];
end

dCorresEdgeInds = sort(unique(dCorresEdgeInds));
end

