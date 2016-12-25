function filteredCircles2 = filter_circles(circles)



filteredCircles = circles;
filteredCircles2 = [];
idx_delete = [];
idx = 1;
n=1;
for fc=filteredCircles
    idx2 = 1;
    for c=circles
        alreadyDeleted = 0;
        for i=1:length(idx_delete)
            if (idx2 == idx_delete(i))
                alreadyDeleted = 1;
            end;
        end;
    if ((idx~=idx2)&&(fc(3) <= c(3))&&(alreadyDeleted==0))
%         delta_x = abs(fc(0)-c(0));
%         delta_y = abs(fc(1)-c(1));
%         dist = sqrt(delta_x*delta_x+delta_y*delta_y);
        if (check_intersection(fc,c)==1)
            if (fc(3) >= c(3))
                idx_delete(n) = idx;
                n = n+1;
            end;
        end;
    end;
    idx2 = idx2+1;
    end;
    idx = idx+1;
end;
idx_delete = unique(idx_delete);
idx_delete = sort(idx_delete,'descend');
ss = size(circles);
len_circles = ss(2);
n=1;
		if (length(idx_delete) < len_circles)
            for i=1:len_circles
                del = 0;
			for j=1:length(idx_delete)
                if (i==idx_delete(j))
                    del = 1;
                end;
            end;
            if (del == 0)
                filteredCircles2(:,n) = circles(:,i); 
                n=n+1;
            end;
            end;
        else
            
			filteredCircles = [];
        end;