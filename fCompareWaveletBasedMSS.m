function fCompareWaveletBasedMSS( iInputImg, iGTImg, dEPSFWindowSize, dHImageWindowSize, IsShowImages )
%FCOMPAREWAVELETBASEDMSS Summary of this function goes here
%   To select best multi-scale segmentation method

% Watershed params
WATERSHED_LINE_EXIST = true;
WATERSHED_LINE_NOT_EXIST = false;

% Filter Params
EPSF_P = 10;
EPSF_ITER = 1;

% Result vectors
dAllSegCnt = zeros(3,2);
dAllGoodness1 = zeros(3,2);
dAllPSNR = zeros(3,2);
dAllTime = zeros(3,2);
dAllMoransI = zeros(3,2);
dAllVar = zeros(3,2);
dAllEvRes1 = zeros(3,2);
dAllEvRes2 = zeros(3,2);
dAllGoodness2 = zeros(3,2);

dGTClassLabels = fGT2ClassLabel(iGTImg);

fShowImage(iInputImg,'Original Image',true);
fShowImage(iGTImg,'GT Image',true);

%% Filter image
[dFilteredImg,dTime_EPSF] = fEdgePreservedSmoothingFilter(iInputImg,dEPSFWindowSize,EPSF_P,EPSF_ITER);
fShowImage(dFilteredImg,'EPSF Filtered Img',IsShowImages);

% SaveAllFigures('MSS Common');

%% Apply wavelet based multiscale segmentation of Jung
dStepNo = 0;
for WAVELET_MSS_RES_LEVEL=1:1:3
    dStepNo = dStepNo + 1;
    
    [dProjectedImg_Jung,dLabels_Jung_Without_WL,dSegCnt_Jung,dTime_Jung] = fProjectImByJung(dFilteredImg, WAVELET_MSS_RES_LEVEL, 'H-Image', dHImageWindowSize);
    fShowImage(dProjectedImg_Jung,['Projected Image By Jung at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    dSimpleImg_Jung = fSimplifyImage(iInputImg,dLabels_Jung_Without_WL);
    fShowImage(dSimpleImg_Jung,['Simplified Image By Jung at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    dSegmentedImg_Jung = fGetSegmentedImg(iInputImg,dLabels_Jung_Without_WL,WATERSHED_LINE_NOT_EXIST);
    fShowImage(dSegmentedImg_Jung,['Segmented Image By Jung at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    [dGoodness_Jung,dPSNR_Jung] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_Jung,dLabels_Jung_Without_WL);
    [dVar_Jung,dMoransI_Jung] = fFindVariance_MoransI_New(iInputImg,dLabels_Jung_Without_WL,WATERSHED_LINE_NOT_EXIST);
    [dEvRes1_Jung,dEvRes2_Jung] = fSegDiscrepEval(dGTClassLabels,dLabels_Jung_Without_WL);
    
    dAllSegCnt(dStepNo,1) = dSegCnt_Jung;
    dAllGoodness1(dStepNo,1) = dGoodness_Jung;
    dAllPSNR(dStepNo,1) = dPSNR_Jung;
    dAllTime(dStepNo,1) = dTime_Jung;
    dAllMoransI(:,dStepNo) = dMoransI_Jung;
    dAllVar(:,dStepNo) = dVar_Jung;
    dAllEvRes1(dStepNo,1) = dEvRes1_Jung;
    dAllEvRes2(dStepNo,1) = dEvRes2_Jung;
end
[dNormalizedMoransI,dNormalizedVar,dAllGoodness2(:,1)] = fGetGoodness2(dAllMoransI,dAllVar);
% SaveAllFigures('Wavelet Based MSS By Jung');

%% Apply wavelet based multiscale segmentation of Kim&Kim
dStepNo = 0;
for WAVELET_MSS_RES_LEVEL=1:1:3
    dStepNo = dStepNo + 1;
    
    [dProjectedImg_KimKim,dLabels_KimKim_With_WL,dSegCnt_KimKim,dTime_KimKim] = fProjectImByKimKim(dFilteredImg, WAVELET_MSS_RES_LEVEL, 'H-Image', dHImageWindowSize);
    fShowImage(dProjectedImg_KimKim,['Projected Image By KimKim at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    dSimpleImg_KimKim = fSimplifyImage(iInputImg,dLabels_KimKim_With_WL);
    fShowImage(dSimpleImg_KimKim,['Simplified Image By KimKim at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    dSegmentedImg_KimKim = fGetSegmentedImg(iInputImg,dLabels_KimKim_With_WL,WATERSHED_LINE_EXIST);
    fShowImage(dSegmentedImg_KimKim,['Segmented Image By KimKim at s: ' num2str(WAVELET_MSS_RES_LEVEL)],IsShowImages);
    [dGoodness_KimKim,dPSNR_KimKim] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_KimKim,dLabels_KimKim_With_WL);
    [dVar_KimKim,dMoransI_KimKim] = fFindVariance_MoransI_New(iInputImg,dLabels_KimKim_With_WL,WATERSHED_LINE_EXIST);
    [dEvRes1_KimKim,dEvRes2_KimKim] = fSegDiscrepEval(dGTClassLabels,dLabels_KimKim_With_WL);
    
    dAllSegCnt(dStepNo,2) = dSegCnt_KimKim;
    dAllGoodness1(dStepNo,2) = dGoodness_KimKim;
    dAllPSNR(dStepNo,2) = dPSNR_KimKim;
    dAllTime(dStepNo,2) = dTime_KimKim;
    dAllMoransI(:,dStepNo) = dMoransI_KimKim;
    dAllVar(:,dStepNo) = dVar_KimKim;
    dAllEvRes1(dStepNo,2) = dEvRes1_KimKim;
    dAllEvRes2(dStepNo,2) = dEvRes2_KimKim;
end
[dNormalizedMoransI,dNormalizedVar,dAllGoodness2(:,2)] = fGetGoodness2(dAllMoransI,dAllVar);
% SaveAllFigures('Wavelet Based MSS By KimKim');

figure,plot(1:1:3,dAllSegCnt,'-s'); xlabel('Window Size','fontsize',16); ylabel('Segment Count','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllGoodness1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Goodness1','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllPSNR,'-s'); xlabel('Window Size','fontsize',16); ylabel('PSNR (dB)','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllTime,'-s'); xlabel('Window Size','fontsize',16); ylabel('Time (sec)','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllEvRes1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev1','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllEvRes2,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev2','fontsize',16);
h = legend('Jung','Kim&Kim',2);
figure,plot(1:1:3,dAllGoodness2,'-s'); xlabel('Window Size','fontsize',16); ylabel('Goodness2','fontsize',16);
h = legend('Jung','Kim&Kim',2);

end

