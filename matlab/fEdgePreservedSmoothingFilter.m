function [ dOutputImg, dComputTime ] = fEdgePreservedSmoothingFilter( iInputImg, dWinSize, p , dIterCnt)
%FEDGEPRESERVEDSMOOTHINGFILTER Summary of this function goes here
% Paper: Color Reduction for Complex Document Images
% Assumption: iInputImg is an integer class

tic;

dMaxChangeVal = double(intmax(class(iInputImg)));

dInputImg = double(iInputImg);
dOutputImg = dInputImg;
[dRowCnt,dColCnt,dBandCnt] = size(dInputImg);
dWindow = zeros(dWinSize,dWinSize,dBandCnt,'double');
dConvMask = zeros(dWinSize,dWinSize);
dWinCenter = (dWinSize+1)/2;

for dIterNo=1:1:dIterCnt
    
    % Extend input img
    dExtInputImg = fExtendImgByMirroring(dInputImg,dWinSize);
    
    for dRowNo=dWinCenter:1:dRowCnt+(dWinCenter-1)
        for colNo=dWinCenter:1:dColCnt+(dWinCenter-1)
            % Copy current dWindow to matrix "dWindow"
            for dWinRowNo=1:1:dWinSize
                for dWinColNo=1:1:dWinSize
                    dWindow(dWinRowNo,dWinColNo,:) = dExtInputImg(dRowNo-dWinCenter+dWinRowNo,colNo-dWinCenter+dWinColNo,:);
                end
            end
            
            % Find Manhattan color distances between center pixel and
            % other pixels, calculate conv mask params
            for dWinRowNo=1:1:dWinSize
                for dWinColNo=1:1:dWinSize
                    dDistance=0;
                    for dBandNo=1:1:dBandCnt
                        dDistance = dDistance + abs(dWindow(dWinCenter,dWinCenter,dBandNo) - dWindow(dWinRowNo,dWinColNo,dBandNo));
                    end
                    
                    di = (dDistance)/(dBandCnt*dMaxChangeVal);
                    ci = (1-di)^p;
                    
                    dConvMask(dWinRowNo,dWinColNo) = ci;
                end
            end
            % Conv mask center should be 0 instead of 1
            % dConvMask(dWinCenter,dWinCenter) = 0;
            dTotalC = sum(dConvMask(:));
            
            % Apply convolution to all bands
            dFiltered = zeros(dBandCnt,1,'double');            
            for dWinRowNo=1:1:dWinSize
                for dWinColNo=1:1:dWinSize
                    for dBandNo=1:1:dBandCnt
                        dFiltered(dBandNo) = dFiltered(dBandNo) + dWindow(dWinRowNo,dWinColNo,dBandNo)*dConvMask(dWinRowNo,dWinColNo);
                    end
                end
            end
            
            % Update output
            for dBandNo=1:1:dBandCnt
                dOutputImg(dRowNo-dWinCenter+1,colNo-dWinCenter+1,dBandNo) = (dFiltered(dBandNo)/dTotalC);
            end
        end
    end
    
    dInputImg = dOutputImg;
end

dComputTime = toc;

end

