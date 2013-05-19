function dLabels = fGT2ClassLabel( gGroundTruthImg )
%FGROUNDTRUTH2LABEL Summary of this function goes here
%   gGroundTruthImg = 3 band - uint8 assumption

dGroundTruthImg = double(gGroundTruthImg);
[dRowCnt,dColCnt,~] = size(dGroundTruthImg);
dLabels = zeros(dRowCnt,dColCnt);

for dRowNo=1:1:dRowCnt
    for dColNo=1:1:dColCnt
        dColor = dGroundTruthImg(dRowNo,dColNo,:);
        
        if dColor(1) == 0 && dColor(2) == 0 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 1;     % shadows
        elseif dColor(1) == 0 && dColor(2) == 128 && dColor(3) == 128
            dLabels(dRowNo,dColNo) = 2;     % green-roof buildings
        elseif dColor(1) == 128 && dColor(2) == 64 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 3;     % bare grounds
        elseif dColor(1) == 128 && dColor(2) == 128 && dColor(3) == 128
            dLabels(dRowNo,dColNo) = 4;     % asphalts
        elseif dColor(1) == 255 && dColor(2) == 255 && dColor(3) == 255
            dLabels(dRowNo,dColNo) = 5;     % concretes
        elseif dColor(1) == 0 && dColor(2) == 64 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 6;     % forest
        elseif dColor(1) == 255 && dColor(2) == 128 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 7;     % light bare grounds
        elseif dColor(1) == 0 && dColor(2) == 255 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 8;     % meadow
        elseif dColor(1) == 0 && dColor(2) == 0 && dColor(3) == 255
            dLabels(dRowNo,dColNo) = 9;     % water
        elseif dColor(1) == 255 && dColor(2) == 0 && dColor(3) == 0
            dLabels(dRowNo,dColNo) = 10;     % red-building
        end
    end
end

end
