function [ dOutputImg, dLabels, dSegCnt, dComputTime ] = fProjectImByJung( gInputImg, dLevelCount, sWatershedInputMethod, watershedInputMethodParam )
%FPROJECTIM Summary of this function goes here
% Paper: Combining wavelets and watersheds for robust multiscale image
% segmentation

tic;

dInputImg = double(gInputImg);
dBandCnt = size(dInputImg,3);
[C, S] = wavedec2(dInputImg,dLevelCount,'haar');
dLowestResImg = appcoef2(C,S,'haar',dLevelCount);

switch sWatershedInputMethod
    case 'MSGM'
        sFilterType = watershedInputMethodParam;
        dGradMagImg = fGetGradMagIm(dLowestResImg,sFilterType);
    case 'H-Image'
        dHImgWinSize = watershedInputMethodParam;
        dGradMagImg = fGetHImg(dLowestResImg,dHImgWinSize);
    otherwise
        error('Wrong grad algorithm name!');
end

dLabels = fVincentSoilleWatershed(dGradMagImg,8);

dSimpleImg = fSimplifyImage(dLowestResImg,dLabels);
dOutputImg = dSimpleImg;

for dResLevel=dLevelCount:-1:1
    
    [H V D] = detcoef2('all',C,S,dResLevel);
    dLabelsIncDim = fIncreaseDimension(dLabels,dBandCnt);
    H(dLabelsIncDim~=0)=0;
    V(dLabelsIncDim~=0)=0;
    D(dLabelsIncDim~=0)=0;
    
    % Apply IDWT
    dOutputImg = idwt2(dOutputImg,H,V,D,'haar');
    
    % Upsample dLabels
    dLabels = fUpsample(dLabels);
    
    % Lost pixel correction
    dExtLabels = fExtendImgByZeroPadding(dLabels,3);
    for dRowNo=2:1:(size(dLabels,1)+1)
        for dColNo=2:1:(size(dLabels,2)+1)
            if dExtLabels(dRowNo,dColNo) == 0
                dMinDistance = -1;
                dMinDistRow = 0; dMinDistCol = 0;
                dCenterColor = dOutputImg(dRowNo-1,dColNo-1,:);
                
                for dNeighRowNo=dRowNo-1:1:dRowNo+1
                    for dNeighColNo=dColNo-1:1:dColNo+1
                        if dExtLabels(dNeighRowNo,dNeighColNo) ~= 0
                            dDistance = fGetColorDist(dCenterColor,dOutputImg(dNeighRowNo-1,dNeighColNo-1,:));
                            
                            if (dDistance<dMinDistance) || (dMinDistance<0)
                                dMinDistance=dDistance;
                                dMinDistRow=dNeighRowNo;
                                dMinDistCol=dNeighColNo;
                            end
                        end
                    end
                end
                
                dOutputImg(dRowNo-1,dColNo-1,:) = dOutputImg(dMinDistRow-1,dMinDistCol-1,:);
                dExtLabels(dRowNo,dColNo) = dExtLabels(dMinDistRow,dMinDistCol);
            end
        end
    end
    dLabels(:,:) = dExtLabels(2:size(dLabels,1)+1,2:size(dLabels,2)+1);
    
    % Find and update region boundaries
    if dResLevel ~= 1
        dAppIm = appcoef2(C,S,'haar',dResLevel-1);
        loBoundaries = fGetBoundaries(dLabels,0);
        loBoundariesIncDim = fIncreaseDimension(loBoundaries,dBandCnt);
        dOutputImg(loBoundariesIncDim==1) = 0;
        dAppIm(loBoundariesIncDim~=1) = 0;
        dOutputImg = dOutputImg + dAppIm;
        dLabels(loBoundaries==1) = 0;
    else
        dAppIm = dInputImg;
        loBoundaries = fGetBoundaries(dLabels,0);
        loBoundariesIncDim = fIncreaseDimension(loBoundaries,dBandCnt);
        dOutputImg(loBoundariesIncDim==1)=0;
        dAppIm(loBoundariesIncDim~=1) = 0;
        dOutputImg = dOutputImg + dAppIm;
    end
    
end

[dLabels,dSegCnt] = fRenumberLabels(dLabels);
dComputTime = toc;

end
