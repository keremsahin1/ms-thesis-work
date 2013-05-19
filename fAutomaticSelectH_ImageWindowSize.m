function dOptimumH_ImageWindowSize = fAutomaticSelectH_ImageWindowSize(iInputImg,dFilteredImg)

% Result vectors
dAllMoransI = []; dAllVar = [];

for H_IMAGE_WINDOW_SIZE=3:2:15
    [dHImg,dTime_HImg] = fGetHImg(dFilteredImg,H_IMAGE_WINDOW_SIZE);
    [dLabels_HImg_With_WL,dSegCnt_HImg,dSegTime_HImg] = fVincentSoilleWatershed(dHImg,8);
    [dVar_HImg,dMoransI_HImg] = fFindVariance_MoransI_New(iInputImg,dLabels_HImg_With_WL,true);
    
    dAllMoransI = [dAllMoransI,dMoransI_HImg];
    dAllVar = [dAllVar,dVar_HImg];
end

[dAllNormalizedMoransI,dAllNormalizedVar,dAllGoodness2] = fGetGoodness2(dAllMoransI,dAllVar);

[dMinVal dMinIndex] = min(dAllGoodness2);
dOptimumH_ImageWindowSize = (2*dMinIndex) + 1;

end

