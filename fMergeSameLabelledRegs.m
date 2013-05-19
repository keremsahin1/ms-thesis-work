function dLabels = fMergeSameLabelledRegs( gLabels )
%FMERGESAMELABELLEDREGS2 Checked
% Detailed explanation goes here

dLabels = double(gLabels);
[dRowCnt,dColCnt] = size(dLabels);

for dRowNo=1:1:dRowCnt
    for dColNo=1:1:dColCnt
        if dLabels(dRowNo,dColNo) == 0
            if dRowNo>1 && dRowNo<dRowCnt
                if dColNo>1 && dColNo<dColCnt
                    dLabels = checkBothDirec(dLabels,dRowNo,dColNo);
                else
                    dLabels = checkVerDirec(dLabels,dRowNo,dColNo);
                end
            else
                if dColNo>1 && dColNo<dColCnt
                    dLabels = checkHorDirec(dLabels,dRowNo,dColNo);
                end
            end         
        end
    end
end
end

function dLabels = checkHorDirec ( dLabels, dRowNo, dColNo )
if ((dLabels(dRowNo,dColNo-1) == dLabels(dRowNo,dColNo+1)) && (dLabels(dRowNo,dColNo+1) ~= 0))
    dLabels(dRowNo,dColNo) = dLabels(dRowNo,dColNo-1);
end
end

function dLabels = checkVerDirec ( dLabels, dRowNo, dColNo )
if ((dLabels(dRowNo-1,dColNo) == dLabels(dRowNo+1,dColNo)) && (dLabels(dRowNo+1,dColNo) ~= 0))
    dLabels(dRowNo,dColNo) = dLabels(dRowNo-1,dColNo);
end
end

function dLabels = checkBothDirec ( dLabels, dRowNo, dColNo )
    
dLabels = checkHorDirec(dLabels,dRowNo,dColNo);
dLabels = checkVerDirec(dLabels,dRowNo,dColNo);

dWindow = dLabels(dRowNo-1:dRowNo+1,dColNo-1:dColNo+1);
dUniqueLabels = unique(dWindow(dWindow~=0));
if numel(dUniqueLabels) == 1
    dLabels(dRowNo,dColNo) = dUniqueLabels(1);
end

end

