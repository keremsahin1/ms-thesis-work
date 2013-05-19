function [ dGoodness, dPSNR ] = fFindSegmentationAccuracy( gOrigIm, gSimpleIm, gLabels )
%FFINDSEGMENTATIONACCURACY Checked 26.08
% Assumption: gOrigIm is an integer class

dOrigIm = double(gOrigIm);
dSimpleIm = double(gSimpleIm);
dLabels = double(gLabels);

% Normalize the input image and simplified image
dOrigIm = dOrigIm / (max(dOrigIm(:)));
dSimpleIm = dSimpleIm / (max(dSimpleIm(:)));

dMaxDistVal = 1;
dBandCnt = size(dOrigIm,3);
dSegCnt = max(dLabels(:));

structRegionProps = regionprops(dLabels,'Area','PixelList');
dGoodnessSecTerm = 0;
dMSE = 0;
dTotalArea = 0;
for dSegNo=1:1:dSegCnt
    Ak = structRegionProps(dSegNo).Area;
    dPixelList = structRegionProps(dSegNo).PixelList;
    
    Dk=0;
    for dPixNo=1:1:size(dPixelList,1)
        
        dRowNo = dPixelList(dPixNo,2);
        dColNo = dPixelList(dPixNo,1);
        
        dDistance = 0;
        for dBandNo=1:1:dBandCnt
            dDistance = dDistance + (dOrigIm(dRowNo,dColNo,dBandNo)-dSimpleIm(dRowNo,dColNo,dBandNo))^2;
        end
        
        Dk = Dk + sqrt(dDistance);
        dMSE = dMSE + dDistance;
    end
    
    dTotalArea = dTotalArea + Ak;
    dGoodnessSecTerm = dGoodnessSecTerm + ((Dk^2)/(sqrt(Ak)));
end
dGoodness = sqrt(dSegCnt)*dGoodnessSecTerm/dTotalArea;

dMSE = dMSE/dTotalArea;
dPSNR = 10*log10(((dMaxDistVal*sqrt(dBandCnt))^2)/dMSE);

end

