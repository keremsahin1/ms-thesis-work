function handle = fShowImage( gInputImg, sImgTitle, loShowImg )
%FSHOWIMAGE Checked
% gInputImg can be grayscale or multi-spectral

dInputImg = double(gInputImg);

if loShowImg == true
    %screenSize = get(0, 'ScreenSize');
    handle = figure();
    imshow(dInputImg/(max(dInputImg(:)))), title(sImgTitle);
    %set(handle, 'Position', [0 0 screenSize(3) screenSize(4)]);
end

end

