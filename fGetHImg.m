function [ dHImage, dComputTime ] = fGetHImg( gInputImg, dWinSize )
%FGETHIMG Checked 01.09
% Paper: Unsupervised Image Segmentation Using Local Homogeneity Analysis

tic;

dInputImg = double(gInputImg);

[dRowCnt dColCnt dBandCnt] = size(dInputImg);
dHImage = zeros(dRowCnt,dColCnt,'double');
dHImgBands = zeros(size(dInputImg),'double');
dWinCenter = (dWinSize+1)/2;
dHorMask = zeros(dWinSize,dWinSize,'double');
dVerMask = zeros(dWinSize,dWinSize,'double');

% Construct dMask matrix
for dRowNo = 1:1:dWinSize
    for dColNo = 1:1:dWinSize
        dHypot = sqrt((dRowNo-dWinCenter)^2 + (dColNo-dWinCenter)^2);
        
        dHorMask(dRowNo,dColNo) = (dColNo-dWinCenter)/dHypot;
        dVerMask(dRowNo,dColNo) = (dRowNo-dWinCenter)/dHypot;
    end
end
dHorMask(dWinCenter,dWinCenter) = 0; dVerMask(dWinCenter,dWinCenter) = 0;

% Extend input image wrt to the window size
dExtInputIm=fExtendImgByMirroring(dInputImg,dWinSize);

% Get H-image of every band
for dBandNo = 1:1:dBandCnt
    for dRowNo = 1:1:dRowCnt
        for dColNo = 1:1:dColCnt
            dWindow = dExtInputIm(dRowNo:(dRowNo+dWinSize-1),dColNo:(dColNo+dWinSize-1),dBandNo);
            dDiff = dWindow - dInputImg(dRowNo,dColNo,dBandNo);
            dHorDiff = dDiff.*dHorMask;
            dVerDiff = dDiff.*dVerMask;
            dHImgBands(dRowNo,dColNo,dBandNo) = sqrt(sum(dHorDiff(:))^2 + sum(dVerDiff(:))^2);
        end
    end
    
    dHImage = dHImage + dHImgBands(:,:,dBandNo).^2;
end
dHImage = sqrt(dHImage);

dComputTime = toc;

end

