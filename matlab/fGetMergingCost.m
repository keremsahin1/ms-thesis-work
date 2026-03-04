function dMergCost = fGetMergingCost( stReg1, stReg2, stRegMerged, dBandWeights, dWeightSpec, dWeightSmooth )
%FRM_MERGINGCOST Checked
%   Detailed explanation goes here

dWeightShape = 1 - dWeightSpec;
dWeightCompact = 1 - dWeightSmooth;

% Get properties of individual objects
nObj_1=stReg1.Area; nObj_2=stReg2.Area;
sigmaObj_1=stReg1.StdDev; sigmaObj_2=stReg2.StdDev;
lObj_1=stReg1.Perimeter; lObj_2=stReg2.Perimeter;
bObj_1=stReg1.BoundBoxPerim; bObj_2=stReg2.BoundBoxPerim;

% Get properties of merged object
nMerged=stRegMerged.Area;
sigmaMerged=stRegMerged.StdDev;
lMerged=stRegMerged.Perimeter;
bMerged=stRegMerged.BoundBoxPerim;

% Get merging cost
hSpec = 0;
for dBandNo=1:1:size(dBandWeights,1)
    hSpec = hSpec + dBandWeights(dBandNo)*(nMerged*sigmaMerged(dBandNo)-(nObj_1*sigmaObj_1(dBandNo)+nObj_2*sigmaObj_2(dBandNo)));
end

hSmooth=nMerged*(lMerged/bMerged)-(nObj_1*(lObj_1/bObj_1)+nObj_2*(lObj_2/bObj_2));
hCompact=nMerged*(lMerged/sqrt(nMerged))-(nObj_1*(lObj_1/sqrt(nObj_1))+nObj_2*(lObj_2/sqrt(nObj_2)));
hShape=dWeightCompact*hCompact+dWeightSmooth*hSmooth;

dMergCost=dWeightSpec*hSpec+dWeightShape*hShape;

end

