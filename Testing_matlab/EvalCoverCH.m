function selectedCircles = EvalCoverCH(map_,circles,nbrCells,plottingOn)


ss = size(map_);
sizeX = ss(1); sizeY = ss(2);
selectedCircles = zeros(3,nbrCells);
sss = size(circles);
sizePred = sss(2);
if (plottingOn), figure(43), end;
if (plottingOn), subplot(2,2,1), imshow(map_), title('a) low + high'), end;
% Arrange to maximaise cover of convex hull
    
F= zeros(size(map_)); 
    S = regionprops(map_,'all');
    size(S.ConvexImage);
    x0 = ceil(S.BoundingBox(1));
    x1 = floor(S.BoundingBox(3)+S.BoundingBox(1));
    y0 = ceil(S.BoundingBox(2));
    y1 = floor(S.BoundingBox(4)+S.BoundingBox(2));
    F(y0:y1,x0:x1) = S.ConvexImage;
    kh = floor(S.ConvexHull);

    combos0 = combntns(1:sizePred,min(nbrCells,sizePred));
    ss = size(combos0); nbrCombos = ss(1);
    iou_0 = zeros(nbrCombos,1);
    neg_iou_0 = zeros(nbrCombos,1);
    ol_0 = zeros(nbrCombos,1);
    for i = 1:nbrCombos
        % Compute for this combination
        tmp = zeros(size(map_));
        com = combos0(i,:);
        for j = 1:length(com)
            %Add this circle
            ind = com(j);
            c = circles(:,ind);
        [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
        emb_mask = (X.^2 + Y.^2)>(c(3))^2;
        tmp = tmp + ~emb_mask;
        end;
%         figure()
%         imshow(tmp), hold on, plot(kh(:,1),kh(:,2),'r-'), hold on;
        overlap = im2bw(tmp-1); ol_0(i) = sum(sum(overlap))/sum(sum(im2bw(tmp)));
        int = sum(sum(im2bw(tmp.*F)));
        union = sum(sum(im2bw(tmp+F)));
        iou_0(i) = int/union;
        neg_iou_0 = sum(sum(im2bw(tmp.*~F)))/sum(sum(im2bw(F)));
        
%         title(iou);
    end;
    
    % Selection criteria
    iou_0 = iou_0./(ol_0+neg_iou_0);
    best_combo = combos0(argmax(iou_0),:);
    
    counter = 1;
    if (plottingOn), subplot(2,2,4), imshow(map_), title('a) low + high'), hold on, end;
    for j = 1:length(best_combo)
            %Add this circle
            ind = best_combo(j);
            c = circles(:,ind);
            selectedCircles(:,counter) = c;
            counter = counter + 1;
        [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
        emb_mask = (X.^2 + Y.^2)>(c(3))^2;
        tmp = tmp + ~emb_mask;
        if (plottingOn), subplot(2,2,4), contour(~emb_mask,'Color', 'b', 'lineWidth', 1), hold on, end;
    end;
%         figure()
%         imshow(tmp), hold on, plot(kh(:,1),kh(:,2),'r-'), hold on;
        int = sum(sum(im2bw(tmp.*F)));
        union = sum(sum(im2bw(tmp+F)));
        best_iou = int/union;
%         title(iou);
    if (plottingOn),subplot(2,2,4), plot(kh(:,1),kh(:,2),'r-'), hold on, title('a) combining c.hull'), hold on, end;
