function [ dGradMagIm, dComputTime ] = fGetGradMagIm( gInputImg, sFiltType )
%FGETGRADMAGIM Checked 30.08
% gInputImg can be grayscale or multi-spectral

tic;

dInputImg = double(gInputImg);
dBandCnt = size(dInputImg,3);
dVerGradImg = zeros(size(dInputImg),'double');
dHorGradImg = zeros(size(dInputImg),'double');

% Generate filters
dFiltVer = fspecial(sFiltType);
dFiltHor = dFiltVer';

% Calculate J matrix elements
for dBandNo = 1:1:dBandCnt
    dVerGradImg(:,:,dBandNo) = imfilter(dInputImg(:,:,dBandNo),dFiltVer,'symmetric');
    dHorGradImg(:,:,dBandNo) = imfilter(dInputImg(:,:,dBandNo),dFiltHor,'symmetric');
end

% Calculate J'*J matrix elements
A11=0; A12=0; A22=0;
for dBandNo = 1:1:dBandCnt
    A11 = A11 + dHorGradImg(:,:,dBandNo).^2;
    A12 = A12 + dHorGradImg(:,:,dBandNo).*dVerGradImg(:,:,dBandNo);
    A22 = A22 + dVerGradImg(:,:,dBandNo).^2;
end

% Calculate largest eigenvalue and grad mag im
dLargEigVal = ((A11+A22)+(sqrt(A11.^2 + A22.^2 - 2*A11.*A22 + 4*A12.^2)))/2;
dGradMagIm = sqrt(dLargEigVal);

dComputTime = toc;

end

