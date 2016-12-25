function resultImage = ExtractOutline(image,plottingOn)

R_ = image(:,:,1);
G_ = image(:,:,2);
B_ = image(:,:,3);

resultImage = im2bw(R_-G_);

if (plottingOn), figure(11), end;
if (plottingOn), subplot(2,2,1), imshow(resultImage), title('a) outline'), end;
if (plottingOn), subplot(2,2,2), imshow(G_), title('a) green'), end;
if (plottingOn), subplot(2,2,3), imshow(R_), title('a) red'), end;
if (plottingOn), subplot(2,2,4), imshow(B_), title('a) blue'), end;