function [ dEdges, dUpdates ] = fUpdateEdges( dEdges, dConvertFromReg, dConvertToReg )
%FUPDATEEDGES Summary of this function goes here
%   Detailed explanation goes here

% Convert dRegNo2s to dRegNo1s
dEdgeNo = 1;
dUpdates = false(size(dEdges,1),1);
while (dEdgeNo <= size(dEdges,1)) && (dEdges(dEdgeNo,1) < dConvertToReg)
    if dEdges(dEdgeNo,2) == dConvertFromReg || dEdges(dEdgeNo,2) == dConvertToReg
        dEdges(dEdgeNo,2) = dConvertToReg;
        dUpdates(dEdgeNo) = 1;
    end
    dEdgeNo = dEdgeNo + 1;
end
while (dEdgeNo <= size(dEdges,1)) && (dEdges(dEdgeNo,1) == dConvertToReg)
    dUpdates(dEdgeNo) = 1;
    dEdgeNo = dEdgeNo + 1;
end
while (dEdgeNo <= size(dEdges,1)) && (dEdges(dEdgeNo,1) < dConvertFromReg)
    if dEdges(dEdgeNo,2) == dConvertFromReg
        dEdges(dEdgeNo,2) = dConvertToReg;
        dUpdates(dEdgeNo) = 1;
        if dEdges(dEdgeNo,2) < dEdges(dEdgeNo,1)
            dTempRegNo2 = dEdges(dEdgeNo,2);
            dEdges(dEdgeNo,2) = dEdges(dEdgeNo,1);
            dEdges(dEdgeNo,1) = dTempRegNo2;
        end
    end
    dEdgeNo = dEdgeNo + 1;
end
while (dEdgeNo <= size(dEdges,1)) && (dEdges(dEdgeNo,1) == dConvertFromReg)
    dEdges(dEdgeNo,1) = dConvertToReg;
    dUpdates(dEdgeNo) = 1;
    dEdgeNo = dEdgeNo + 1;
end
end

