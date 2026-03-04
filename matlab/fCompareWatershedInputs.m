function fCompareWatershedInputs( iInputImg, iGTImg, dEPSFWindowSize, IsShowImages )
%FCOMPAREWATERSHEDINPUTS Summary of this function goes here
%   To select MS Gradient or H-Image

% Watershed params
WATERSHED_LINE_EXIST = true;
WATERSHED_LINE_NOT_EXIST = false;

%Filter Params
EPSF_P = 10;
EPSF_ITER = 1;

% Result vectors
dAllSegCnt = []; dAllGoodness1 = []; dAllPSNR = []; dAllTime = []; dAllMoransI = []; dAllVar = []; dAllEvRes1 = []; dAllEvRes2 = [];

dGTLabels = fGT2ClassLabel(iGTImg);

fShowImage(iInputImg,'Original Image',true);
fShowImage(iGTImg,'GT Image',true);

%% Filter image
[dFilteredImg,dTime_EPSF] = fEdgePreservedSmoothingFilter(iInputImg,dEPSFWindowSize,EPSF_P,EPSF_ITER);
fShowImage(dFilteredImg,'EPSF Filtered Img',IsShowImages);

%SaveAllFigures('GradType Common');

%% H-Image
for H_IMAGE_WINDOW_SIZE=3:2:15
    [dHImg,dTime_HImg] = fGetHImg(dFilteredImg,H_IMAGE_WINDOW_SIZE);
    fShowImage(dHImg,['H-Image at window size: ' num2str(H_IMAGE_WINDOW_SIZE)],IsShowImages);
    [dLabels_HImg_With_WL,dSegCnt_HImg,dSegTime_HImg] = fVincentSoilleWatershed(dHImg,8);
    dSimpleImg_HImg = fSimplifyImage(iInputImg,dLabels_HImg_With_WL);
    fShowImage(dSimpleImg_HImg,['H-Img Simplified Image at window size: ' num2str(H_IMAGE_WINDOW_SIZE)],IsShowImages);
    dSegmentedImg_HImg = fGetSegmentedImg(iInputImg,dLabels_HImg_With_WL,WATERSHED_LINE_EXIST);
    fShowImage(dSegmentedImg_HImg,['H-Img Segmented Image at window size: ' num2str(H_IMAGE_WINDOW_SIZE)],IsShowImages);
    [dGoodness_HImg,dPSNR_HImg] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_HImg,dLabels_HImg_With_WL);
    [dVar_HImg,dMoransI_HImg] = fFindVariance_MoransI_New(iInputImg,dLabels_HImg_With_WL,WATERSHED_LINE_EXIST);
    [dEvRes1_HImg,dEvRes2_HImg] = fSegDiscrepEval(dGTLabels,dLabels_HImg_With_WL);
    
    dAllSegCnt = [dAllSegCnt;dSegCnt_HImg];
    dAllGoodness1 = [dAllGoodness1;dGoodness_HImg];
    dAllPSNR = [dAllPSNR;dPSNR_HImg];
    dAllTime = [dAllTime;dTime_HImg];
    dAllMoransI = [dAllMoransI,dMoransI_HImg];
    dAllVar = [dAllVar,dVar_HImg];
    dAllEvRes1 = [dAllEvRes1;dEvRes1_HImg];
    dAllEvRes2 = [dAllEvRes2;dEvRes2_HImg];
end
[dAllNormalizedMoransI,dAllNormalizedVar,dAllGoodness2] = fGetGoodness2(dAllMoransI,dAllVar);
%SaveAllFigures('H-Image');

%% Multi-Spectral Gradient Using Sobel
[dGradMagImg,dTime_Grad] = fGetGradMagIm(dFilteredImg,'Sobel');
fShowImage(dGradMagImg,'Grad Mag. Image',IsShowImages);
[dLabels_Grad_With_WL,dSegCnt_Grad,dSegTime_Grad] = fVincentSoilleWatershed(dGradMagImg,8);
dSimpleImg_Grad = fSimplifyImage(iInputImg,dLabels_Grad_With_WL);
fShowImage(dSimpleImg_Grad,'Grad Simplified Image',IsShowImages);
dSegmentedImg_Grad = fGetSegmentedImg(iInputImg,dLabels_Grad_With_WL,WATERSHED_LINE_EXIST);
fShowImage(dSegmentedImg_Grad,'Grad Segmented Image',IsShowImages);
[dGoodness_Grad,dPSNR_Grad] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_Grad,dLabels_Grad_With_WL);
[dVar_Grad,dMoransI_Grad] = fFindVariance_MoransI_New(iInputImg,dLabels_Grad_With_WL,WATERSHED_LINE_EXIST);
[dEvRes1_Grad,dEvRes2_Grad] = fSegDiscrepEval(dGTLabels,dLabels_Grad_With_WL);

dAllSegCnt = [dAllSegCnt, dSegCnt_Grad*ones(7,1)];
dAllGoodness1 = [dAllGoodness1, dGoodness_Grad*ones(7,1)];
dAllPSNR = [dAllPSNR, dPSNR_Grad*ones(7,1)];
dAllTime = [dAllTime, dTime_Grad*ones(7,1)];
dAllEvRes1 = [dAllEvRes1, dEvRes1_Grad*ones(7,1)];
dAllEvRes2 = [dAllEvRes2, dEvRes2_Grad*ones(7,1)];
% SaveAllFigures('MSGM');

figure,plot(3:2:15,dAllSegCnt,'-s'); xlabel('Window Size','fontsize',16); ylabel('Segment Count','fontsize',16);
h = legend('H-Image','MSGM',2);
figure,plot(3:2:15,dAllGoodness1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Goodness1','fontsize',16);
h = legend('H-Image','MSGM',2);
figure,plot(3:2:15,dAllPSNR,'-s'); xlabel('Window Size','fontsize',16); ylabel('PSNR (dB)','fontsize',16);
h = legend('H-Image','MSGM',2);
figure,plot(3:2:15,dAllTime,'-s'); xlabel('Window Size','fontsize',16); ylabel('Time (sec)','fontsize',16);
h = legend('H-Image','MSGM',2);
figure,plot(3:2:15,dAllEvRes1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev1','fontsize',16);
h = legend('H-Image','MSGM',2);
figure,plot(3:2:15,dAllEvRes2,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev2','fontsize',16);
h = legend('H-Image','MSGM',2);

figure,plot(3:2:15,dAllGoodness2,'-s'); xlabel('Window Size','fontsize',16); ylabel('H-Image - Goodness2','fontsize',16);

end

