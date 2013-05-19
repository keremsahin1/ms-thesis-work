function [ dTopLeftRow, dTopLeftCol, dBottomRightRow, dBottomRightCol ] = fGetMergedBoundingBox( dReg1BoundBox, dReg2BoundBox, dRowCnt, dColCnt )
%FGETMERGEDBOUNDINGBOX Checked
%   Detailed explanation goes here

dReg1TopLeftCol = dReg1BoundBox(1)+0.5;
dReg1TopLeftRow = dReg1BoundBox(2)+0.5;
dReg1BottomRightCol = dReg1TopLeftCol + dReg1BoundBox(3) - 1;
dReg1BottomRightRow = dReg1TopLeftRow + dReg1BoundBox(4) - 1;

dReg2TopLeftCol = dReg2BoundBox(1)+0.5;
dReg2TopLeftRow = dReg2BoundBox(2)+0.5;
dReg2BottomRightCol = dReg2TopLeftCol + dReg2BoundBox(3) - 1;
dReg2BottomRightRow = dReg2TopLeftRow + dReg2BoundBox(4) - 1;

if dReg1TopLeftCol < dReg2TopLeftCol
    dTopLeftCol = dReg1TopLeftCol;
else
    dTopLeftCol = dReg2TopLeftCol;
end

if dReg1TopLeftRow < dReg2TopLeftRow
    dTopLeftRow = dReg1TopLeftRow;
else
    dTopLeftRow = dReg2TopLeftRow;
end

if dReg1BottomRightCol > dReg2BottomRightCol
    dBottomRightCol = dReg1BottomRightCol;
else
    dBottomRightCol = dReg2BottomRightCol;
end

if dReg1BottomRightRow > dReg2BottomRightRow
    dBottomRightRow = dReg1BottomRightRow;
else
    dBottomRightRow = dReg2BottomRightRow;
end

% Extend merged bounding box
if dTopLeftCol > 1
    dTopLeftCol = dTopLeftCol - 1;
end

if dTopLeftRow > 1
    dTopLeftRow = dTopLeftRow - 1;
end

if dBottomRightCol < dColCnt
    dBottomRightCol = dBottomRightCol + 1;
end

if dBottomRightRow < dRowCnt
    dBottomRightRow = dBottomRightRow + 1;
end

end

