function imageOut = ProcessHumTL(imageIn, plottingOn)
    % Process image and return processed logical bw image
    A = imageIn;
    ss = size(A);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(23), end;
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    A = edge(A, 'log'); % log?
    if (plottingOn), subplot(2,2,1), imshow(A), title('a) Edges'), end;
    A = imdilate(A,se3);
    A = imopen(A,se5);
    A = imfill(A,'holes');
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
    if (plottingOn), subplot(2,2,2), imshow(A),title('b) Open+largest'),  end;
    D = bwdist(~A);
    % Erode
    D0 = imerode(D,se5);
    % Threshold
    D1 = zeros(size(D));
    D1(find(D>0.5*max(max(D)))) = 1;
    % Hmaxima
    D2 = imhmax(D,0.3*max(max(D)));
    
    if (plottingOn), subplot(2,2,3), imshow(D0,[]), title('c) Distance'), end;
    
    [x,y] = find(A==1);
    k = convhull(x,y);
    if (plottingOn), subplot(2,2,4), ...
    plot(y,-x,'k.',y(k),-x(k),'r-'), ...
    axis([0 ss(1) -ss(2) 0 ]), axis square, ...
    title('d) Convex hull'), end;
    else
        subplot(2,2,4), plot(0,0,'k.');
    end;
    imageOut = A;
    