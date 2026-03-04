function [ dLabels, dNewSegCnt] = fRenumberLabels( gLabels )
%FRENUMBERLABELS Checked
% 

dLabels = double(gLabels);

dMaxLabelNo = max(dLabels(:));

% Find existing segment numbers
dExistLabelNos = unique(dLabels(dLabels~=0));
dNewSegCnt = numel(dExistLabelNos);

if dMaxLabelNo ~= dNewSegCnt
    loLabelNoExistnc = false(dMaxLabelNo,1);
    loLabelNoExistnc(dExistLabelNos) = 1;
    
    % Replace segment numbers
    dReplaceInd = dNewSegCnt;
    for dSegNo = 1:1:dNewSegCnt
        % if not available
        if loLabelNoExistnc(dSegNo) == 0
            dReplaceSegNo = dExistLabelNos(dReplaceInd);
            
            dLabels(dLabels==dReplaceSegNo) = dSegNo;
            loLabelNoExistnc(dSegNo) = 1;
            loLabelNoExistnc(dReplaceSegNo) = 0;
            
            dReplaceInd = dReplaceInd - 1;
        end
    end    
end

end
