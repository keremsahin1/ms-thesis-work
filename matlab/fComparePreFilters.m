function fComparePreFilters( iInputImg, iGTImg, IsShowImages )
%FCOMPAREPREFILTERS Summary of this function goes here
%   To select best preprocessing algorithm

WATERSHED_LINE_EXIST = true;
WATERSHED_LINE_NOT_EXIST = false;

dAllSegCnt = zeros(7,3);
dAllGoodness1 = zeros(7,3);
dAllPSNR = zeros(7,3);
dAllTime = zeros(7,3);
dAllMoransI = zeros(3,7);
dAllVar = zeros(3,7);
dAllEvRes1 = zeros(7,3);
dAllEvRes2 = zeros(7,3);
dAllGoodness2 = zeros(7,2);

dGTLabels = fGT2ClassLabel(iGTImg);

fShowImage(iInputImg,'Original Image',true);
fShowImage(iGTImg,'GT Image',true);

%SaveAllFigures('Preprocessing Common');

%% Case 0: no preprocessing
dGradMagImg_NoPre = fGetGradMagIm(iInputImg,'Sobel');
fShowImage(dGradMagImg_NoPre,'No Preprocessing Grad Mag Image',IsShowImages);
[dLabels_NoPre_With_WL,dSegCnt_NoPre,dSegTime_NoPre] = fVincentSoilleWatershed(dGradMagImg_NoPre,8);
dSimpleImg_NoPre = fSimplifyImage(iInputImg,dLabels_NoPre_With_WL);
fShowImage(dSimpleImg_NoPre,'No Preprocessing Simplified Image',IsShowImages);
dSegmentedImg_NoPre = fGetSegmentedImg(iInputImg,dLabels_NoPre_With_WL,WATERSHED_LINE_EXIST);
fShowImage(dSegmentedImg_NoPre,'No Preprocessing Segmented Image',IsShowImages);
[dGoodness1_NoPre,dPSNR_NoPre] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_NoPre,dLabels_NoPre_With_WL);
[dVar_NoPre,dMoransI_NoPre] = fFindVariance_MoransI_New(iInputImg,dLabels_NoPre_With_WL,WATERSHED_LINE_EXIST);
[dEvRes1_NoPre,dEvRes2_NoPre,dSegErrImg_NoPre] = fSegDiscrepEval(dGTLabels,dLabels_NoPre_With_WL);
fShowImage(dSegErrImg_NoPre,'No Pre. Seg. Error Image',IsShowImages);

dAllSegCnt(:,1) = ones(7,1)*dSegCnt_NoPre;
dAllGoodness1(:,1) = ones(7,1)*dGoodness1_NoPre;
dAllPSNR(:,1) = ones(7,1)*dPSNR_NoPre;
dAllTime(:,1) = zeros(7,1);
dAllEvRes1(:,1) = ones(7,1)*dEvRes1_NoPre;
dAllEvRes2(:,1) = ones(7,1)*dEvRes2_NoPre;
% SaveAllFigures('No Preprocessing');

%% Case 1: PGF
% Create waitbar.
h = waitbar(0,'Testing PGF...');
set(h,'Name','PGF Progress');
dStepNo = 0;
for PGF_WINDOW_SIZE=3:2:15
    dStepNo = dStepNo + 1;
    
    [dPGFOutput,dTime_PGF] = fPeerGroupFiltering(iInputImg,PGF_WINDOW_SIZE);
    fShowImage(dPGFOutput,['PGF Output at window size: ' num2str(PGF_WINDOW_SIZE)],IsShowImages);
    dGradMagImg_PGF = fGetGradMagIm(dPGFOutput,'Sobel');
    fShowImage(dGradMagImg_PGF,['PGF Grad Mag Image at window size: ' num2str(PGF_WINDOW_SIZE)],IsShowImages);
    [dLabels_PGF_With_WL,dSegCnt_PGF,dSegTime_PGF] = fVincentSoilleWatershed(dGradMagImg_PGF,8);
    dSimpleImg_PGF = fSimplifyImage(iInputImg,dLabels_PGF_With_WL);
    fShowImage(dSimpleImg_PGF,['PGF Simplified Image at window size: ' num2str(PGF_WINDOW_SIZE)],IsShowImages);
    dSegmentedImg_PGF = fGetSegmentedImg(iInputImg,dLabels_PGF_With_WL,WATERSHED_LINE_EXIST);
    fShowImage(dSegmentedImg_PGF,['PGF Segmented Image at window size: ' num2str(PGF_WINDOW_SIZE)],IsShowImages);
    [dGoodness_PGF,dPSNR_PGF] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_PGF,dLabels_PGF_With_WL);
    [dVar_PGF,dMoransI_PGF] = fFindVariance_MoransI_New(iInputImg,dLabels_PGF_With_WL,WATERSHED_LINE_EXIST);
    [dEvRes1_PGF,dEvRes2_PGF,dSegErrImg_PGF] = fSegDiscrepEval(dGTLabels,dLabels_PGF_With_WL);
    fShowImage(dSegErrImg_PGF,['PGF Seg. Error Image at window size: ' num2str(PGF_WINDOW_SIZE)],IsShowImages);
    
    dAllSegCnt(dStepNo,2) = dSegCnt_PGF;
    dAllGoodness1(dStepNo,2) = dGoodness_PGF;
    dAllPSNR(dStepNo,2) = dPSNR_PGF;
    dAllTime(dStepNo,2) = dTime_PGF;
    dAllMoransI(:,dStepNo) = dMoransI_PGF;
    dAllVar(:,dStepNo) = dVar_PGF;
    dAllEvRes1(dStepNo,2) = dEvRes1_PGF;
    dAllEvRes2(dStepNo,2) = dEvRes2_PGF;
    
    % Update waitbar
    waitbar(dStepNo/7);
end
[dAllNormalizedMoransI,dAllNormalizedVar,dAllGoodness2(:,1)] = fGetGoodness2(dAllMoransI,dAllVar);
% Close waitbar.
close(h);
% SaveAllFigures('PGF');

%% Case 2: EPSF
% Create waitbar.
h = waitbar(0,'Testing EPSF...');
set(h,'Name','EPSF Progress');
dStepNo = 0;
for EPSF_ITER=1
    for EPSF_WINDOW_SIZE=3:2:15
        for EPSF_P=10
            dStepNo = dStepNo + 1;
            
            [dEPSFOutput,dTime_EPSF] = fEdgePreservedSmoothingFilter(iInputImg,EPSF_WINDOW_SIZE,EPSF_P,EPSF_ITER);
            fShowImage(dEPSFOutput,['EPSF Output at window size: ' num2str(EPSF_WINDOW_SIZE) ' and at s: ' num2str(EPSF_P)],IsShowImages);
            dGradMagImg_EPSF = fGetGradMagIm(dEPSFOutput,'Sobel');
            fShowImage(dGradMagImg_EPSF,['EPSF Grad Mag Image at window size: ' num2str(EPSF_WINDOW_SIZE) ' and at s: ' num2str(EPSF_P)],IsShowImages);
            [dLabels_EPSF_With_WL,dSegCnt_EPSF,dSegTime_EPSF] = fVincentSoilleWatershed(dGradMagImg_EPSF,8);
            dSimpleImg_EPSF = fSimplifyImage(iInputImg,dLabels_EPSF_With_WL);
            fShowImage(dSimpleImg_EPSF,['EPSF Simplified Image at window size: ' num2str(EPSF_WINDOW_SIZE) ' and at s: ' num2str(EPSF_P)],IsShowImages);
            dSegmentedImg_EPSF = fGetSegmentedImg(iInputImg,dLabels_EPSF_With_WL,WATERSHED_LINE_EXIST);
            fShowImage(dSegmentedImg_EPSF,['EPSF Segmented Image at window size: ' num2str(EPSF_WINDOW_SIZE) ' and at s: ' num2str(EPSF_P)],IsShowImages);
            [dGoodness_EPSF,dPSNR_EPSF] = fFindSegmentationAccuracy(iInputImg,dSimpleImg_EPSF,dLabels_EPSF_With_WL);
            [dVar_EPSF,dMoransI_EPSF] = fFindVariance_MoransI_New(iInputImg,dLabels_EPSF_With_WL,WATERSHED_LINE_EXIST);
            [dEvRes1_EPSF,dEvRes2_EPSF,dSegErrImg_EPSF] = fSegDiscrepEval(dGTLabels,dLabels_EPSF_With_WL);
            fShowImage(dSegErrImg_EPSF,['EPSF Seg. Error Image at window size: ' num2str(EPSF_WINDOW_SIZE)],IsShowImages);
            
            dAllSegCnt(dStepNo,3) = dSegCnt_EPSF;
            dAllGoodness1(dStepNo,3) = dGoodness_EPSF;
            dAllPSNR(dStepNo,3) = dPSNR_EPSF;
            dAllTime(dStepNo,3) = dTime_EPSF;
            dAllMoransI(:,dStepNo) = dMoransI_EPSF;
            dAllVar(:,dStepNo) = dVar_EPSF;
            dAllEvRes1(dStepNo,3) = dEvRes1_EPSF;
            dAllEvRes2(dStepNo,3) = dEvRes2_EPSF;
            
            % Update waitbar
            waitbar(dStepNo/7);
        end
    end
end
[dAllNormalizedMoransI,dAllNormalizedVar,dAllGoodness2(:,2)] = fGetGoodness2(dAllMoransI,dAllVar);
% Close waitbar.
close(h);
%SaveAllFigures('EPSF');

figure,plot(3:2:15,dAllSegCnt,'-s'); xlabel('Window Size','fontsize',16); ylabel('Segment Count','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);
figure,plot(3:2:15,dAllGoodness1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Goodness1','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);
figure,plot(3:2:15,dAllPSNR,'-s'); xlabel('Window Size','fontsize',16); ylabel('PSNR (dB)','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);
figure,plot(3:2:15,dAllTime,'-s'); xlabel('Window Size','fontsize',16); ylabel('Time (sec)','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);
figure,plot(3:2:15,dAllEvRes1,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev1','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);
figure,plot(3:2:15,dAllEvRes2,'-s'); xlabel('Window Size','fontsize',16); ylabel('Ev2','fontsize',16);
h = legend('No Pre-filter','PGF','EPSF',3);

figure,plot(3:2:15,dAllGoodness2,'-s'); xlabel('Window Size','fontsize',16); ylabel('Goodness2','fontsize',16);
h = legend('PGF','EPSF',2);

end

