function score = CheckResult(predicted, conf_score, resultImages, nbrCircles, plottingOn)

ss = size(resultImages);
sss = size(predicted);
sizePred = sss(2);
sizeX = ss(1); sizeY = ss(2); sizeN = nbrCircles;
union_res = zeros(sizeX,sizeY);
Cent_res = zeros(sizeN,2);
Cent_pred = zeros(sizePred,2);
for r=1:sizeN
union_res = union_res + resultImages(:,:,r);
end;
union_res = im2bw(union_res);
ss = size(union_res);
sizeX = ss(1); sizeY = ss(2);
if (plottingOn), figure(12), end;

if (plottingOn), subplot(2,2,1), imshow(union_res), title('a) result'), hold on, end;
union_res = imfill(union_res,'holes');

Cent_im = zeros(size(union_res));
for r=1:sizeN
%Centroid location result
        S = regionprops(resultImages(:,:,r),'Centroid');
        Cent_res(r,:) = S.Centroid;
        x = floor(Cent_res(r,1));
        y = floor(Cent_res(r,2));
        Cent_im(y,x) = 1;
        sum(sum(Cent_im));
        if (plottingOn), subplot(2,2,1), plot(Cent_res(r,1),Cent_res(r,2),'rx'), hold on, end;
end;

% Union of prediction
union_pred = zeros(size(union_res));
for c = predicted
    c;
%         [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
%         emb_mask = (X.^2 + Y.^2)>(c(3))^2;
        emb_mask = ComputeMask(c,sizeX,sizeY,0);
        union_pred = union_pred + emb_mask;
end;
union_pred = im2bw(union_pred);
union_pred = imfill(union_pred,'holes');

counter = 1;
Cent_res_ = Cent_res;
c_dist = zeros(sizePred,1);
single_rel_int = zeros(sizePred,1);
single_iou = zeros(sizePred,1);
rel_int_more_than_70perc = 0;
for c = predicted
%         [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
%         pred_mask = (X.^2 + Y.^2)>(c(3))^2;
%         pred_mask = ~pred_mask;
        pred_mask = ComputeMask(c,sizeX,sizeY,0);
        %Centroid location predicted
        if (plottingOn), subplot(2,2,1), plot(c(1),c(2),'bx'), hold on, end;
%         [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
%         emb_mask = (X.^2 + Y.^2)>(c(3))^2;
        if (plottingOn), subplot(2,2,1), contour(pred_mask,'Color', 'b', 'lineWidth', 1), hold on, end;
        
        %Distance to closest centroid of result in terms or cell radius
        tmp_res_ = zeros(size(Cent_res_));
        Cent_res_;
        for r = 1: sizeN
            
            if ((Cent_res_(r,1) >0)&(Cent_res_(r,2) >0))
%             tmp_im = zeros(size(A));
%             x = floor(Cent_res_(r,1));
%             y = floor(Cent_res_(r,2));
%             tmp_im(y,x) = 1;
%             if (sum(sum(tmp_im.*~emb_mask)) > 0)
                tmp_res_(r,:) = Cent_res_(r,:);
%             end;
            end;
            
        end;
        
        tmp_dist_ = inf(sizeN,2);
        tmp_iou_ = zeros(sizeN,2);
        tmp_rel_int_ = zeros(sizeN,2);
        
        for t = 1:sizeN
            if ((tmp_res_(t,1) >0) & (tmp_res_(t,2) >0))
                res_mask = resultImages(:,:,t);
                res_mask = imfill(res_mask,'holes');
                tmp_intersection = im2bw(res_mask.*pred_mask);
                tmp_union = im2bw(res_mask+pred_mask);
                tmp_rel_int_(t,2) = sum(sum(tmp_intersection))/sum(sum(pred_mask));
                tmp_iou_(t,2) = sum(sum(tmp_intersection))/sum(sum(tmp_union));
                tmp_iou_(t,1) = t;
                tmp_rel_int_(t,1) = t;
                tmp_dist_(t,2) = (sqrt((tmp_res_(t,2)-c(2))^2 + (tmp_res_(t,1)-c(1))^2))/c(3);
                tmp_dist_(t,1) = t;
            end;
        end;
        
        % Pick closest one
        tmp_dist_s = sortrows(tmp_dist_,2);
        % Pick the one with highest iou
        tmp_iou_s = sortrows(tmp_iou_,2);
        % Pick one with highest rel intersection
        tmp_rel_int_s = sortrows(tmp_rel_int_,2);
        ind_iou = tmp_iou_s(sizeN,1);
        ind_rel_int = tmp_rel_int_s(sizeN,1);
        ind_dist = tmp_dist_s(1,1);
        
        
        if (length(unique([ind_iou ind_rel_int ind_dist]))>1)
            disp 'WARNING: Several optima!'
        end;
        
        ind = ind_iou;
        if ind == 0
            ind = ind_dist; % If iou is 0 - pick closest centroid
        end;
        if strcmp(num2str(ind),'Inf') ~= 1
            c_dist(counter) = tmp_dist_(ind,2);
            single_rel_int(counter) = tmp_rel_int_(ind,2);
            single_iou(counter) = tmp_iou_(ind,2);
            if ((single_rel_int(counter) > 0.7))
                rel_int_more_than_70perc = rel_int_more_than_70perc + 1;
            end;
            % Remove the picked one from list
            for n = 1: sizeN
                if n == ind
                    Cent_res_(n,1) = 0;
                    Cent_res_(n,2) = 0;
                end;
            end;
        end;
        
        
        counter = counter + 1;
end;

if (plottingOn)
    % Plot results vs confidence score to evaluate best method for
    % comparison
    figure(801)
    plot(conf_score, single_rel_int, 'k.'); hold on;
    plot(conf_score, single_iou, 'b.'); hold on;
    plot(conf_score, 2-c_dist, 'r.'); hold on;
end;
if (plottingOn), figure(12), end;

mean_rel_int = mean(single_rel_int);
mean_iou = mean(single_iou);
mean_c_dist = mean(c_dist);
c_intersection = Cent_im.*union_pred;
intersection = union_res.*union_pred;
c_int = sum(sum(c_intersection))/nbrCircles;
rel_int = sum(sum(intersection))/sum(sum(union_pred));
union = im2bw(union_res+union_pred);
iou = sum(sum(intersection))/sum(sum(union));
if (plottingOn), subplot(2,2,2), imshow(intersection), title(strcat(strcat(strcat('rel.int: ',num2str(rel_int)),' iou: '),num2str(iou))), end;

% Returned metrics:

% rel_int: intersection in part of the predicted total. Is 1 if prediction is
% totally enclosed in result. Mostly important if we try to match both location
% and outline). [0 1]

% mean_rel_int: the same as rel_int but mean for all cells

% c_int: part of centroids for result which are enclosed in the total image
% of prediction. Important for location. [0 1]

% mean_c_dist the mean distance between the centroid of each result body
% and the centroid of the closest predicted body (euclidean) expressed as
% part of the predicted bodys radius. If 0, then all centroids for
% prediction coincide with one centroid of result. Important for location.

% iou: intersection over union of total predicted and total result. If
% rel_int = 1, this is a measure of how much of the result image which is
% covered by the prediction (only matters if we try to match both location
% and outline).
%
% mean_iou: same as iou but mean for all cells

% rel_int_more_than_70perc; number of cells with rel_int>0.7
score = [rel_int mean_rel_int c_int mean_c_dist iou mean_iou rel_int_more_than_70perc];
