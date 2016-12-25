clear all; close all;
pause on;

path = 'C:\\MMU\\HMC data\\Fertilitech test images\\12_3_20\\';
% path = 'C:\\MMU\\PROJECTS\\Juan Carlos embryo modelling\\emb1_8-11CS_EcadGFP_H2BRFP_3divisions\\';

plotMain = 0;
x_range = 500;
y_range = 500;
t_min = 80;
t_max = 80;
t_step = 1;
z_min = 20;
z_max = 20;
z_step = 1;
x_scaling = 0.189; % µm/pxl todo
y_scaling = 0.189; % µm/pxl
z_scaling = 1.263; % µm/pxl
z_range = z_max-z_min +1;
I_tl_all = zeros(x_range,y_range,z_range);
Nmin = 3;
Nmax = 3;
Nstep = 1;
n_z = (z_max-z_min)/z_step;
n_t = (t_max-t_min)/t_step;
n_n = (Nmax-Nmin)/Nstep;
% Metrics:

n_metrics = 1;
metrics = zeros(n_t,n_z,Nmax,n_metrics);
cells = zeros(n_t,n_z,Nmax,3); % store center(x,y) and radius

for t = t_min:t_step:t_max
    if (t < 10), t_str= strcat('00',num2str(t));
    elseif (t < 100), t_str=strcat('0',num2str(t));
    else, t_str = num2str(t); 
    end;
    for z = z_min:z_step:z_max
    if (z < 10), z_str= strcat('0',num2str(z));
    
    else, z_str = num2str(z); 
    end;
    for N = Nmin:Nstep:Nmax
    path_t = strcat(path, strcat('D1900.01.01_S0012_I000_W03_P',strcat(t_str,'_F')));
%     path_t = strcat(path, strcat('Stack\\t_',strcat(t_str,'\\')));
    
%     if (z < 10), z_str= strcat('0',num2str(z));
%     else, z_str = num2str(z);
%     end;
%     
    notestr =strcat( strcat('t',t_str),strcat('_z',z_str)) % For display at runtime only
    % Prepare images
    filename_tl = strcat(path_t,strcat(num2str(z_str),'.jpg'));
%     filename_tl = strcat(path_t,strcat('tl_z',strcat(num2str(z_str),strcat('_t',strcat(t_str,'.png')))));
    I_tl = imread(filename_tl);
    
%      file_test_res = 'C:\\Temp\\Focal scan testimages\\7_3.bmp';
%      I_tl_result = imread(file_test_res);
    
%     I_tl_result = ExtractOutline(I_tl_result,1);
    I_tl_ = I_tl(:,:,1);
    %I_tl_ = double(I_tl_); %For processing
    
    % Morphological processing
%     I_tl_bw1 = ProcessHumTL_1(I_tl_,1)
%     I_tl_bw2 = ProcessHumTL_2(I_tl_,1)
%     I_tl_bw3 = ProcessHumTL_3(I_tl_,1)
%     I_tl_bw4 = ProcessHumTL_4(I_tl_,1);
%     I_tl_bw5 = ProcessHumTL_5(I_tl_,1);
%     I_tl_bw6 = ProcessHumTL_6(I_tl_,1);
      I_tl_bw46 = ProcessHumTL_46(I_tl_,I_tl_result,N, 1);
% I_tl_bw41 = ProcessHumTL_41(I_tl_,1);

    % pause;
    end; %N
    end; %z

end; %t
