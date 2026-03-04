function dOptimumRM1ScaleThresh = fAutomaticSelectRM1ScaleThreshold(iInputImg, dLabelsBeforeRM_With_WL,dFilteredImg)

% Result vectors
dAllMoransI = []; dAllVar = [];

[structRMResults,dNumOfScaleLevels] = fRegionMerge1_Test(dFilteredImg,dLabelsBeforeRM_With_WL,1,100,1,0,true);

for dLevelNo=1:1:dNumOfScaleLevels
    dLabels_RM_With_WL = structRMResults(dLevelNo).Labels;
    [dVar_RM,dMoransI_RM] = fFindVariance_MoransI_New(iInputImg,dLabels_RM_With_WL,true);
    
    dAllMoransI = [dAllMoransI,dMoransI_RM];
    dAllVar = [dAllVar,dVar_RM];
end

[dAllNormalizedMoransI,dAllNormalizedVar,dAllGoodness2] = fGetGoodness2(dAllMoransI,dAllVar);

[dMinVal dMinIndex] = min(dAllGoodness2);
dOptimumRM1ScaleThresh = 1*dMinIndex;

end