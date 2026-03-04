function [ dOutputImg, dComputationTime ] = fPeerGroupFiltering( gInputImg, dWinSize )
%FPEERGROUPFILTERING Checked 30.08
% Paper: Peer Group Filtering and Perceptual Color Image Quantization
% Assumption: dWinSize is odd
% Assumption: no impulse noise

tic;

dInputImg = double(gInputImg);
dOutputImg = dInputImg;
[dRowCnt,dColCnt,dBandCnt] = size(dInputImg);
dGaussianWeights = fspecial('gaussian',dWinSize,1);

k = dWinSize*dWinSize;
J = zeros(k,1,'double');

dDistMat = zeros(dWinSize,dWinSize,'double');
dWinCenter = (dWinSize+1)/2;
dWindow = zeros(dWinSize,dWinSize,dBandCnt,'double');

% Extend input img
dExtInputImg = fExtendImgByMirroring(dInputImg,dWinSize);

for dRowNo=dWinCenter:1:dRowCnt+(dWinCenter-1)
    for dColNo=dWinCenter:1:dColCnt+(dWinCenter-1)
        
        % Copy current window
        for dWinRowNo=1:1:dWinSize
            for dWinColNo=1:1:dWinSize
                dWindow(dWinRowNo,dWinColNo,:) = dExtInputImg(dRowNo-dWinCenter+dWinRowNo,dColNo-dWinCenter+dWinColNo,:);
            end
        end
        
        % Find Euclidean distances between center pixel and other pixels
        for dWinRowNo=1:1:dWinSize
            for dWinColNo=1:1:dWinSize
                dDistance = 0;
                for dBandNo=1:1:dBandCnt
                    dDistance = dDistance + (dWindow(dWinCenter,dWinCenter,dBandNo) - dWindow(dWinRowNo,dWinColNo,dBandNo))^2;
                end
                dDistMat(dWinRowNo,dWinColNo) = sqrt(dDistance);
            end
        end
        
        % Sort these distances
        [dDistSorted dIndices] = sort(dDistMat(:));
        
        % Calculate Fisher's criterion for every case
        for i=1:1:k
            a1 = 0; a2 = 0; s1Sq = 0; s2Sq = 0;
            
            % Find a1
            for j=0:1:(i-1)
                a1 = a1 + dDistSorted(j+1);
            end
            a1 = a1/i;
            
            %Find a2
            for j=i:1:(k-1)
                a2 = a2 + dDistSorted(j+1);
            end
            
            if i~=k
                a2 = a2/(k-i);
            else
                a2 = 0;
            end
            
            %Find s1Sq
            for j=0:1:(i-1)
                s1Sq = s1Sq + (dDistSorted(j+1)-a1)^2;
            end
            
            %Find s2Sq
            for j=i:1:(k-1)
                s2Sq = s2Sq + (dDistSorted(j+1)-a2)^2;
            end
            
            %Find J(i)
            J(i) = ((a1-a2)^2)/(s1Sq+s2Sq);
        end
        
        % Find peer group size
        [~,dPeerGroupSize] = max(J);
        dModifGaussWeights = dGaussianWeights;
        dModifGaussWeights(dIndices((dPeerGroupSize+1):k)) = 0;
        
        % Find weighted average
        dWeightedTotal = 0; dTotalWeights = 0;
        for dWinRowNo=1:1:dWinSize
            for dWinColNo=1:1:dWinSize
                dWeight = dModifGaussWeights(dWinRowNo,dWinColNo);
                dTotalWeights = dTotalWeights + dWeight;
                dWeightedTotal = dWeightedTotal + dWeight*dWindow(dWinRowNo,dWinColNo,:);
            end
        end
        dWeightedAvg = dWeightedTotal/dTotalWeights;
        
        % Update output image
        dOutputImg(dRowNo-dWinCenter+1,dColNo-dWinCenter+1,:) = dWeightedAvg;
    end
end

dComputationTime = toc;

end
