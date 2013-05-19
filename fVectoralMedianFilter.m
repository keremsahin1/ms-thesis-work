function [ dOutputImg, dComputTime ] = fVectoralMedianFilter( gInputImg, dWinSize )
%FVECTORALMEDIANFILTER Checked
% Paper: Fast Modified Vector Median Filter
% Assumption: gInputImg is an integer class

tic;

dMaxDistVal = double(intmax(class(gInputImg)));
dInputImg = double(gInputImg);

dOutputImg = zeros(size(dInputImg),'double');
[dRowCnt,dColCnt,dBandCnt] = size(dInputImg);
dWindow = zeros(dWinSize,dWinSize,dBandCnt,'double');
dWinCenter = (dWinSize+1)/2;

%Extend input image wrt to the window size
dExtInputImg = fExtendImgByMirroring(dInputImg,dWinSize);

for dRowNo=dWinCenter:1:dRowCnt+(dWinCenter-1)
    for colNo=dWinCenter:1:dColCnt+(dWinCenter-1)
        
        % Copy current dWindow to matrix "dWindow"
        for dWinRowNo=1:1:dWinSize
            for dWinColNo=1:1:dWinSize
                dWindow(dWinRowNo,dWinColNo,:) = dExtInputImg(dRowNo-dWinCenter+dWinRowNo,colNo-dWinCenter+dWinColNo,:);
            end
        end
        
        dMinDistance = dMaxDistVal*sqrt(3)*((dWinSize*dWinSize)-1); % Worst case
        dXMin = 1;
        dYMin = 1;
        for dXFrom=1:1:dWinSize
            for dYFrom=1:1:dWinSize
                dTotDist = 0;
                for dXTo=1:1:dWinSize
                    for dYTo=1:1:dWinSize
                        dDistance = 0;
                        for dBandNo=1:1:dBandCnt
                            dDistance = dDistance + (dWindow(dXFrom,dYFrom,dBandNo) - dWindow(dXTo,dYTo,dBandNo))^2;
                        end
                        dDistance = sqrt(dDistance);                        
                        dTotDist = dTotDist + dDistance;
                    end
                end
                
                if dTotDist<dMinDistance
                    dMinDistance = dTotDist;
                    dXMin = dXFrom;
                    dYMin = dYFrom;
                end
            end
        end
        
        dOutputImg(dRowNo-dWinCenter+1,colNo-dWinCenter+1,:) = dWindow(dXMin,dYMin,:);
    end
end

dComputTime = toc;

end

