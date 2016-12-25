function intersect = check_intersection(cell1,cell2)
intersect = 0;

% 	# Check if bodies overlap to any extent. Return 1 if they do
	delta_x = abs(cell1(1)-cell2(1));
	delta_y = abs(cell1(2)-cell2(2));
% 	# print 'idx: ' + str(idx)
% 	# print 'idx2: ' + str(idx2)
	dist = sqrt(delta_x^2+delta_y^2);
% 	# print 'dist ' + str(dist)
% 	# print 'radius: ' + str(fc[2])
if cell1(3) > cell2(3)
    cellBig = cell1;
else
    cellBig = cell2;
end;

if cell2(3) <= cell1(3)
    cellSmall = cell2;
else
    cellSmall = cell1;
end;

	if (dist < cellBig(3)*0.8) % Higher number = less cells
		intersect = 1;
    end;
	if (dist + cellSmall(3) < cellBig(3)*1.5) % Higher number = less cells
		intersect = 1;
    end;