function [ dOutputImg, dLabels, dSegCnt, dComputTime ] = fProjectImByKimKim( gInputImg, dLevelCount, sWatershedInputMethod, watershedInputMethodParam )
%FPROJECTIMKIMKIM Summary of this function goes here
% Paper: Multiresolution-based watersheds for efficient image segmentation

tic;

dInputImg = double(gInputImg);
[C, S] = wavedec2(dInputImg,dLevelCount,'haar');
dLowestResImg = appcoef2(C,S,'haar',dLevelCount);

dGradMagImg = GetGradMagImg(dLowestResImg,sWatershedInputMethod,watershedInputMethodParam);
dLabels = fVincentSoilleWatershed(dGradMagImg,8);

dSimpleImg = fSimplifyImage(dLowestResImg,dLabels);
dOutputImg = dSimpleImg;

for dResLevel=dLevelCount:-1:1
    % Apply IDWT
    [H V D] = detcoef2('all',C,S,dResLevel);
    dOutputImg = idwt2(dOutputImg,H,V,D,'haar');
    
    % Upsample dLabels
    dUpsampledLabels = fUpsample(dLabels);
    
    % Get labels of one higher scale
    if dResLevel == 1
        dUpperScaleAppIm = dInputImg;
    else
        dUpperScaleAppIm = appcoef2(C,S,'haar',dResLevel-1);
    end
    dUpperScaleGradMagIm = GetGradMagImg(dUpperScaleAppIm,sWatershedInputMethod,watershedInputMethodParam);
    dUpperScaleLabels = fVincentSoilleWatershed(dUpperScaleGradMagIm,8);
    
    % Refine labels
    dSegCnt = max(dUpperScaleLabels(:));
    stRegionsStats = regionprops(dUpperScaleLabels,'PixelList');
    [dLabelsRowCnt,dLabelsColCnt] = size(dUpperScaleLabels);
    
    for dSegNo=1:1:dSegCnt
        dPixelList = stRegionsStats(dSegNo).PixelList;
        dPixelCnt = size(dPixelList,1);
        dCorresLabelsInds = zeros(dPixelCnt,1,'double');
        
        for dPixNo=1:1:dPixelCnt
            dPixRowNo = dPixelList(dPixNo,2);
            dPixColNo = dPixelList(dPixNo,1);
            
            dCorresLabelsInds(dPixNo) = (dPixColNo-1)*dLabelsRowCnt + dPixRowNo;
        end
        
        dCorresLabels = dUpsampledLabels(dCorresLabelsInds);
        dNewLabel = mode(dCorresLabels(dCorresLabels~=0));
        
        dOldCorresLabelInds = dCorresLabelsInds;
        while isnan(dNewLabel)
            dNewCorresLabelsInds = zeros(9*length(dOldCorresLabelInds),1,'double');
            for dPixNo=1:1:length(dOldCorresLabelInds)
                
                dCenterInd = dOldCorresLabelInds(dPixNo);
                dCurrentNeighInd = zeros(9,1,'double');
                
                for dRowNo=1:1:3
                    for dColNo=1:1:3
                        dCurrentInd = dCenterInd+(dRowNo-2)+(dColNo-2)*dLabelsRowCnt;
                        if (rem(dCurrentInd,dLabelsRowCnt) ~= 0) && (dCurrentInd > 0 && dCurrentInd <= numel(dUpsampledLabels))
                            dCurrentNeighInd((dRowNo-1)*3+dColNo) = dCurrentInd;
                        end
                    end
                end
                
                dNewCorresLabelsInds((dPixNo-1)*9+1:dPixNo*9) = dCurrentNeighInd;
            end
            
            dOldCorresLabelInds = unique(dNewCorresLabelsInds(dNewCorresLabelsInds~=0));
            
            dCorresLabels = dUpsampledLabels(dOldCorresLabelInds);
            dNewLabel = mode(dCorresLabels(dCorresLabels~=0));
        end
        
        dUpperScaleLabels(dCorresLabelsInds) = dNewLabel;
    end
    dLabels = dUpperScaleLabels;
    
    % Merge adjacent regions that have same label
    dLabels = fMergeSameLabelledRegs(dLabels);
    
    % Simplify image
    dOutputImg = fSimplifyImage(dOutputImg,dLabels);
end

[dLabels,dSegCnt] = fRenumberLabels(dLabels);
dComputTime = toc;

end

function dGradMagImg = GetGradMagImg ( gInputImg, sWatershedInputMethod, watershedInputMethodParam )
switch sWatershedInputMethod
    case 'MSGM'
        sFilterType = watershedInputMethodParam;
        dGradMagImg = fGetGradMagIm(gInputImg,sFilterType);
    case 'H-Image'
        dHImgWinSize = watershedInputMethodParam;
        dGradMagImg = fGetHImg(gInputImg,dHImgWinSize);
    otherwise
        error('Wrong grad algorithm name!');
end
end

