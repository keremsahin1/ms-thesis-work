function dStdDev = fGetStdDev( gInputImg, dPixelList)
%FGETSTDDEV Checked
%   Detailed explanation goes here

dInputImg = double(gInputImg);

dBandCnt = size(dInputImg,3);
dPixCnt = size(dPixelList,1);
dStdDev = zeros(dBandCnt,1);
dPixelValues = zeros(dPixCnt,1);

for dBandNo=1:1:dBandCnt
    for dPixNo=1:1:dPixCnt
        dPixX = dPixelList(dPixNo,2);
        dPixY = dPixelList(dPixNo,1);
        
        dPixelValues(dPixNo) = dInputImg(dPixX,dPixY,dBandNo);
    end
    
    dStdDev(dBandNo)=std(dPixelValues,1);
end

end

