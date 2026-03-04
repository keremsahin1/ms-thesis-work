function dEdges = fGetAdjacentRegions( gLabels, loIsExistWatershedLines )
%FGETADJACENTREGIONS Checked
% 

dLabels = double(gLabels);

% size of dLabels
dSize = size(dLabels);

% compute matrix of absolute differences in the first direction
dVerDif = abs(diff(dLabels, 1, 1));

% find non zero values (region changes)
[dRegChX dRegChY] = find(dVerDif);

% get values of consecutive changes
if loIsExistWatershedLines == true
    % delete values close to border
    dRegChY = dRegChY(dRegChX<dSize(1)-1);
    dRegChX = dRegChX(dRegChX<dSize(1)-1);
    
    dNode1 = dVerDif(sub2ind(size(dVerDif), dRegChX, dRegChY));
    dNode2 = dVerDif(sub2ind(size(dVerDif), dRegChX+1, dRegChY));
else
    dNode1 = dLabels(sub2ind(size(dLabels), dRegChX, dRegChY));
    dNode2 = dLabels(sub2ind(size(dLabels), dRegChX+1, dRegChY));
end

% find changes separated with 2 pixels
dInd = find(dNode2 & dNode1~=dNode2);
dEdges = unique([dNode1(dInd) dNode2(dInd)], 'rows');

% compute matrix of absolute differences in the second direction
dHorDif = abs(diff(dLabels, 1, 2));

% find non zero values (region changes)
[dRegChX dRegChY] = find(dHorDif);

% get values of consecutive changes
if loIsExistWatershedLines == true
    % delete values close to border
	dRegChX = dRegChX(dRegChY<dSize(2)-1);
	dRegChY = dRegChY(dRegChY<dSize(2)-1);
    
    dNode1 = dHorDif(sub2ind(size(dHorDif), dRegChX, dRegChY));
    dNode2 = dHorDif(sub2ind(size(dHorDif), dRegChX, dRegChY+1));
else
    dNode1 = dLabels(sub2ind(size(dLabels), dRegChX, dRegChY));
    dNode2 = dLabels(sub2ind(size(dLabels), dRegChX, dRegChY+1));
end

% find changes separated with 2 pixels
dInd = find(dNode2 & dNode1~=dNode2);
dEdges = [dEdges ; unique([dNode1(dInd) dNode2(dInd)], 'rows')];

% format output to have increasing order of n1,  n1<n2, and
% increasing order of n2 for n1=constant.
dEdges = sortrows(sort(dEdges, 2));

% remove eventual double dEdges
dEdges = unique(dEdges, 'rows');
