function [ dLabels, dSegCnt, dProcTime ] = fRainfallingWatershed( gInputImg, dRelDrowThresh, dNeighSize )
%FRAINFALLINGWATERSHED Checked 26.08
% Paper: A Fast Sequential Rainfalling Watershed Segmentation Algorithm
% Assumption: gInputImg is 2D

tic;

dInputImg = double(gInputImg);
dDrowThresh = dRelDrowThresh*max(dInputImg(:));

% Form dNeighMask
if dNeighSize == 4
    dNeighMask = [0 1 0; 1 0 1; 0 1 0];
elseif dNeighSize == 8
    dNeighMask = [1/(sqrt(2)) 1 1/(sqrt(2)); 1 0 1; 1/(sqrt(2)) 1 1/(sqrt(2))];
else
    error('Error: Wrong neighbourhood size for rainfalling watershed!');
end

% Form dLabels and loMinimaIm
[dRowCnt,dColCnt,~] = size(dInputImg);
dLabels = double(reshape(1:(dRowCnt*dColCnt),dRowCnt,dColCnt));
loMinimaIm = true(dRowCnt,dColCnt);

% Extend dInputImg and dLabels
dExtInpImg=fExtendImgByMirroring(dInputImg,3);
dExtLabels=fExtendImgByMirroring(dLabels,3);

% Step1: Visit all pixels in dInputImg in video scanning order
for dRowNo = 1:1:dRowCnt
    for dColNo = 1:1:dColCnt
        if dInputImg(dRowNo,dColNo) >= dDrowThresh
            dLabelsWindow = dExtLabels(dRowNo:(dRowNo+2),dColNo:(dColNo+2));
            dInputImgWindow = dExtInpImg(dRowNo:(dRowNo+2),dColNo:(dColNo+2));
            dSpecDists = dInputImgWindow - dInputImg(dRowNo,dColNo);
            dSpecDescents = dSpecDists .* dNeighMask;
            [dSteepDesc dSteepDescInd] = min(dSpecDescents(:));
            
            if dSteepDesc < 0
                dLabels(dRowNo,dColNo) = dLabelsWindow(dSteepDescInd);
                loMinimaIm(dRowNo,dColNo) = 0;
            end
        end
    end
end

% Step2: Propagate each pixel until the local minima
for dRowNo = 1:1:dRowCnt
    for dColNo = 1:1:dColCnt
        dNext = dLabels(dRowNo,dColNo);
        while dNext ~= dLabels(dNext)
            dNext = dLabels(dNext);
        end
        
        dLabels(dRowNo,dColNo) = dNext;
    end
end

% Step3: Apply connected component labeling to loMinimaIm
dConnMinimaIm = double(labelmatrix(bwconncomp(loMinimaIm,dNeighSize)));

% Step4: Replace label values with dConnMinimaIm labels
for dPixNo = 1:1:(dRowCnt*dColCnt)
    dLabels(dPixNo) = dConnMinimaIm(dLabels(dPixNo));
end

[dLabels,dSegCnt]=fRenumberLabels(dLabels);

dProcTime=toc;
