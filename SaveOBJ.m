% v 286 333 230
    % v 286 332 230
    % v 286 331 230
    path_o = strcat(path, strcat('OBJ\\t_',strcat(t_str,'\\')));
    fid = fopen(strcat(path_o,'2.obj'), 'w');
    fprintf(fid,'# Image file path: %s\n', path);
    fprintf(fid,'# Mode: GFP\n');
    fprintf(fid,'# t: %s\n\n', t_str);
    for z = z_min:z_max
        [x,y] = find(I_gfp_all(:,:,z)==1);
        for i = 1:length(x)
            fprintf(fid,'v %d %d %d\n', x(i)*x_scaling, y(i)*y_scaling, z*z_scaling);
        end;
    end;
    fclose(fid);
    fid = fopen(strcat(path_o,'3.obj'), 'w');
    fprintf(fid,'# Image file path: %s\n', path);
    fprintf(fid,'# Mode: RFP\n');
    fprintf(fid,'# t: %s\n\n', t_str);
    for z = z_min:z_max
        [x,y] = find(I_rfp_all(:,:,z)==1);
        for i = 1:length(x)
            fprintf(fid,'v %d %d %d\n', x(i)*x_scaling, y(i)*y_scaling, z*z_scaling);
        end;
    end;
    fclose(fid);
    fid = fopen(strcat(path_o,'100.obj'), 'w');
    fprintf(fid,'# Image file path: %s\n', path);
    fprintf(fid,'# Mode: ZP\n');
    fprintf(fid,'# t: %s\n\n', t_str);
    % Find the position and average over position and radius.
    I_zp_av = zeros(size(I_tl_));
    z_av = round(z_min + (z_max-z_min)/2);
    for z = z_min:z_max
        I_zp_av(im2bw(I_zp_all(:,:,z), 0.5)) = 1;
    end;
    I_zp_av_ol = bwmorph(im2bw(I_zp_av, 0.5), 'remove');
    [x,y] = find(I_zp_av_ol==1);
    for i = 1:length(x)
        fprintf(fid,'v %d %d %d\n', x(i)*x_scaling, y(i)*y_scaling, z_av*z_scaling);
    end;
    fclose(fid);
    