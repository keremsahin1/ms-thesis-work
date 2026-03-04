function [ gOutputImg ] = fUpsample( gInputImg )
%FUPSAMPLE Checked
% 

[dRowCnt,dColCnt,dBandCnt] = size(gInputImg);
gOutputImg = zeros(2*dRowCnt,2*dColCnt,dBandCnt,class(gInputImg));

for dBandNo=1:1:dBandCnt
    gRowsUpSamp = zeros(dRowCnt*2,dColCnt,class(gInputImg));
    for dRowNo=1:1:dRowCnt
        gRowsUpSamp(2*dRowNo-1,:) = gInputImg(dRowNo,:,dBandNo);
        gRowsUpSamp(2*dRowNo,:) = gInputImg(dRowNo,:,dBandNo);
    end
    
    for dColNo=1:1:dColCnt
        gOutputImg(:,2*dColNo-1,dBandNo) = gRowsUpSamp(:,dColNo);
        gOutputImg(:,2*dColNo,dBandNo) = gRowsUpSamp(:,dColNo);
    end
end

end

