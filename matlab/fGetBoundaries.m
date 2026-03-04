function [ loBoundaries ] = fGetBoundaries( gLabels, loIsExistWatershedLines)
%FGETBOUNDARIES Summary of this function goes here
% gLabels should be a labeled image


dLabels = double(gLabels);

[dRowCnt,dColCnt] = size(dLabels);
loBoundaries = false(dRowCnt,dColCnt);

if loIsExistWatershedLines == false
    % Find horizontal boundaries
    for dRowNo=1:1:dRowCnt
        for dColNo=1:1:(dColCnt-1)
            if(dLabels(dRowNo,dColNo) ~= dLabels(dRowNo,dColNo+1))
                loBoundaries(dRowNo,dColNo)=1;
                loBoundaries(dRowNo,dColNo+1)=1;
            end
        end
    end
    
    % Find vertical boundaries
    for dColNo=1:1:dColCnt
        for dRowNo=1:1:(dRowCnt-1)
            if(dLabels(dRowNo,dColNo) ~= dLabels(dRowNo+1,dColNo))
                loBoundaries(dRowNo,dColNo)=1;
                loBoundaries(dRowNo+1,dColNo)=1;
            end
        end
    end
else
    loBoundaries = (dLabels==0);
end

end

