function imageOut = ProcessHumTL_5(imageIn, plottingOn)
% MORPHOLOGICAL + DISTANCE TO CONVEX HULL
    % Process image and return processed logical bw image
    A = imageIn;
    ss = size(A);
    sizeX = ss(1); sizeY = ss(2);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(35), end;
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A = del2(double(A));
    A = imhmax(A,0.1*max(max(A)));
    
    A = imclose(A,se3);
    B = zeros(size(A));
    B(find(A>0.1*max(max(A)))) = 1;
    
    A = imclose(B,se3);
    B = bwlabel(A,4);
    S = regionprops(B,'Area');
    Area = zeros(size(S));
    for i = 1:length(S)
    Area(i) = S(i).Area;
    end;
    label = argmax(Area);
    A = zeros(size(imageIn));
    if (Area(label) > 1000)
    A(B==label) = 1;
    A = imfill(A,'holes');
    if (plottingOn), subplot(2,2,1), imshow(A), title('a) Laplace etc'), end;
    end;
    
    F = zeros(size(A));
    S = regionprops(A,'all');
    size(S.ConvexImage)
    x0 = floor(S.BoundingBox(1));
    x1 = floor(S.BoundingBox(3)+S.BoundingBox(1));
    y0 = floor(S.BoundingBox(2));
    y1 = floor(S.BoundingBox(4)+S.BoundingBox(2));
    F(y0:y1-1,x0:x1-1) = S.ConvexImage;
    D = bwdist(~F);
    if (plottingOn), subplot(2,2,2), imshow(F), title('a) c.hull'), end;
    if (plottingOn), subplot(2,2,2), imshow(D,[]), title('a) Dist of c.hull'), end;
    
    D(find(A==1)) = 0;
    D(find(D<0.2*max(max(D)))) = 0;
    %G = bwmorph(G,'remove');
    if (plottingOn), subplot(2,2,3), imshow(D,[]), title('a) Dist masked'), end;

    imageOut = A;
    