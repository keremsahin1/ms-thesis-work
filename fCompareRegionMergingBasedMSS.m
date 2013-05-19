function fCompareRegionMergingBasedMSS( iInputImg, iGTImg, dEPSFWindowSize, dHImageWindowSize, dScaleStep1, dScaleStep2, IsShowImages )
%FCOMPAREREGIONMERGINGBASEDMSS Summary of this function goes here
%   To select best multi-scale segmentation method

% Watershed params
WATERSHED_LINE_EXIST = true;
WATERSHED_LINE_NOT_EXIST = false;

% Filter Params
EPSF_P = 10;
EPSF_ITER = 1;

% Result vectors
dAllSegCnt = zeros(50,2);
dAllGoodness1 = zeros(50,2);
dAllPSNR = zeros(50,2);
dAllTime = zeros(50,2);
dAllMoransI = zeros(3,50);
dAllVar = zeros(3,50);
dAllEvRes1 = zeros(50,2);
dAllEvRes2 = zeros(50,2);
dAllGoodness2 = zeros(50,2);

dGTClassLabels = fGT2ClassLabel(iGTImg);

fShowImage(iInputImg,'Original Image',true);
fShowImage(iGTImg,'GT Image',true);

% Filter image
[dFilteredImg,dTime_EPSF] = fEdgePreservedSmoothingFilter(iInputImg,dEPSFWindowSize,EPSF_P,EPSF_ITER);
fShowImage(dFilteredImg,'EPSF Filtered Img',IsShowImages);

% H-Image
[dHImg,dTime_HImg] = fGetHImg(dFilteredImg,dHImageWindowSize);
fShowImage(dHImg,'H-Img',IsShowImages);
dLabelsBeforeRM_With_WL = fVincentSoilleWatershed(dHImg,8);

dSegmentedImgBeforeRM = fGetSegmentedImg(iInputImg,dLabelsBeforeRM_With_WL,WATERSHED_LINE_EXIST);
fShowImage(dSegmentedImgBeforeRM,'Segmented Image Before Region Merging',IsShowImages);

%% Apply region merging based multiscale segmentation 1
for RM_MSS_SPECTRAL_WEIGTH=1
    for RM_MSS_SMOOTHNESS_WEIGTH=0
        [structRMResults,dNumOfScaleLevels] = fRegionMerge1_Test(dFilteredImg,dLabelsBeforeRM_With_WL,dScaleStep1,50*dScaleStep1,RM_MSS_SPECTRAL_WEIGTH,RM_MSS_SMOOTHNESS_WEIGTH,WATERSHED_LINE_EXIST);       
        for dLevelNo=1:1:dNumOfScaleLevels
            dLabels_RM_With_WL = structRMResults(dLevelNo).Labels;
            dSegCnt_RM1 = structRMResults(dLevelNo).SegCnt;
            dTime_RM1 = structRMResults(dLevelNo).Time;
            dScaleThresh_RM = structRMResults(dLevelNo).ScaleThresh;
            
            dSimpleImg_RM = fSimplifyImage(iInputImg,dLabels_RM_With_WL);
            fShowImage(dSimpleImg_RM,['Simplified Image By Region Merging1 at s: ' num2str(dScaleThresh_RM)],IsShowImages);
            dSegmentedImg_RM = fGetSegmentedImg(iInputImg,dLabels_RM_With_WL,WATERSHED_LINE_EXIST);
            fShowImage(dSegmentedImg_RM,['Segmented Image By Region Merging1 at s: ' num2str(dScaleThresh_RM)],IsShowImages);
            [dGoodness_RM1,dPSNR_RM1] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_RM,dLabels_RM_With_WL);
            [dVar_RM1,dMoransI_RM1] = fFindVariance_MoransI_New(iInputImg,dLabels_RM_With_WL,WATERSHED_LINE_EXIST);
            [dEvRes1_RM1,dEvRes2_RM1] = fSegDiscrepEval(dGTClassLabels,dLabels_RM_With_WL);
            
            dAllSegCnt(dLevelNo,1) = dSegCnt_RM1;
            dAllGoodness1(dLevelNo,1) = dGoodness_RM1;
            dAllPSNR(dLevelNo,1) = dPSNR_RM1;
            dAllTime(dLevelNo,1) = dTime_RM1;
            dAllMoransI(:,dLevelNo) = dMoransI_RM1;
            dAllVar(:,dLevelNo) = dVar_RM1;
            dAllEvRes1(dLevelNo,1) = dEvRes1_RM1;
            dAllEvRes2(dLevelNo,1) = dEvRes2_RM1;
        end
    end
end
[dNormalizedMoransI,dNormalizedVar,dAllGoodness2(:,1)] = fGetGoodness2(dAllMoransI,dAllVar);

%% Apply region merging based multiscale segmentation 2
for RM_MSS_SPECTRAL_WEIGTH=1
    for RM_MSS_SMOOTHNESS_WEIGTH=0       
        [structRMResults,dNumOfScaleLevels] = fRegionMerge2_Test(dFilteredImg,dLabelsBeforeRM_With_WL,dScaleStep2,50*dScaleStep2,RM_MSS_SPECTRAL_WEIGTH,RM_MSS_SMOOTHNESS_WEIGTH,WATERSHED_LINE_EXIST);        
        for dLevelNo=1:1:dNumOfScaleLevels
            dLabels_RM_With_WL = structRMResults(dLevelNo).Labels;
            dSegCnt_RM2 = structRMResults(dLevelNo).SegCnt;
            dTime_RM2 = structRMResults(dLevelNo).Time;
            dScaleThresh_RM = structRMResults(dLevelNo).ScaleThresh;
            
            dSimpleImg_RM = fSimplifyImage(iInputImg,dLabels_RM_With_WL);
            fShowImage(dSimpleImg_RM,['Simplified Image By Region Merging2 at s: ' num2str(dScaleThresh_RM)],IsShowImages);
            dSegmentedImg_RM = fGetSegmentedImg(iInputImg,dLabels_RM_With_WL,WATERSHED_LINE_EXIST);
            fShowImage(dSegmentedImg_RM,['Segmented Image By Region Merging2 at s: ' num2str(dScaleThresh_RM)],IsShowImages);
            [dGoodness_RM2,dPSNR_RM2] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_RM,dLabels_RM_With_WL);
            [dVar_RM2,dMoransI_RM2] = fFindVariance_MoransI_New(iInputImg,dLabels_RM_With_WL,WATERSHED_LINE_EXIST);
            [dEvRes1_RM2,dEvRes2_RM2] = fSegDiscrepEval(dGTClassLabels,dLabels_RM_With_WL);
            
            dAllSegCnt(dLevelNo,2) = dSegCnt_RM2;
            dAllGoodness1(dLevelNo,2) = dGoodness_RM2;
            dAllPSNR(dLevelNo,2) = dPSNR_RM2;
            dAllTime(dLevelNo,2) = dTime_RM2;
            dAllMoransI(:,dLevelNo) = dMoransI_RM2;
            dAllVar(:,dLevelNo) = dVar_RM2;
            dAllEvRes1(dLevelNo,2) = dEvRes1_RM2;
            dAllEvRes2(dLevelNo,2) = dEvRes2_RM2;
			
        end
    end
end
[dNormalizedMoransI,dNormalizedVar,dAllGoodness2(:,2)] = fGetGoodness2(dAllMoransI,dAllVar);


figure,plot(1:1:50,dAllSegCnt,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Segment Count','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllGoodness1,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Goodness1','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllPSNR,'-s'); xlabel('Scale Step','fontsize',16); ylabel('PSNR (dB)','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllTime,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Time (sec)','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllEvRes1,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Ev1','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllEvRes2,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Ev2','fontsize',16);
h = legend('RM1','RM2',2);
figure,plot(1:1:50,dAllGoodness2,'-s'); xlabel('Scale Step','fontsize',16); ylabel('Goodness2','fontsize',16);
h = legend('RM1','RM2',2);

end

