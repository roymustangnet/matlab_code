%2017.06.01
clear
clc
%load the images preprocessed by conn and mask it
%path for the mask
path_mask='/home/bli/software/REST_V1.8_130615/mask/';
file_name_mask=[path_mask 'BrainMask_05_91x109x91.hdr'];
%load the mask
V_mask=spm_vol(file_name_mask);
Y_mask=spm_read_vols(V_mask);

%path for the images,data are saved in a root directory
root= '/home/bli/MDD/CAP/version_1/ICA_4d_preprocessed_conn/';
frames=[];
%specify the subjects in each group
MDD_pre=[34,39,46,73,76,77,80,81,98,109,83,35,37,38,47,48,59,66,75,107];
MDD_post=[52,62,70,95,91,92,93,100,104,125,101,61,53,56,69,72,87,96,94,111];
Controls=[2,1,18,147,12,16,8,89,58,68,27,21,5,13,25,29,30,79,45,64];
subjects=[MDD_pre MDD_post Controls];

for subj=1:length(subjects)
    file_name_image=[root 'subj_' num2str(subjects(subj),'%04d') '.nii'];
    disp(['processing subj_' num2str(subjects(subj),'%04d')...
        '... Thank you for your patience!']);
    %load the images
    V_image=spm_vol(file_name_image);
    Y_image=spm_read_vols(V_image);

    %apply the mask to the images
    [m,n,l,k]=size(Y_image);
    for i=1:k
        Y_image(:,:,:,i)=Y_image(:,:,:,i).*Y_mask;
    end

    %calculate the mean and std of the masked images
    image_mean=mean(Y_image,4);
    image_sd=std(Y_image,0,4);

    %modified image_sd to deal with voxels that have sd==0;
    for x=1:m 
        for y=1:n
            for z=1:l
                if (image_sd(x,y,z)==0)
                    image_sd(x,y,z)=0.000001;
                end
            end
        end
    end
         
    %normalize the image Y=(Y-mean(Y))/std(Y)
    for i=1:k
        Y_image(:,:,:,i)=(Y_image(:,:,:,i)-image_mean)./image_sd;
    end

%create a directory to save the normalized images
    cd /home/bli/MDD/CAP_17_06_01/Demeaned_Normalised;
    dir_name=['subj_' num2str(subjects(subj),'%04d')];
    mkdir(dir_name); 
    cd (dir_name);

% write the normalized images
% Discarded the first 10 images but want the filenames to remain
    for i=1:k
       V_nor_image=V_mask;
       V_nor_image.fname=['DN_swauvol_' num2str((i+10),'%04d') '.nii']; 
       spm_write_vol(V_nor_image,Y_image(:,:,:,i));   
    end

    %extract time series using a predefined ROI mask 
    path_ROI_mask='/home/bli/MDD/CAP_17_06_01/mask/';
    file_name_ROI_mask=[path_ROI_mask 'DMN_seed_46_28_55_6.rpt.hdr'];
    V_ROI_mask=spm_vol(file_name_ROI_mask);
    Y_ROI_mask=spm_read_vols(V_ROI_mask);

    ROI_TC=zeros(m,n,l,k);
    ROI_TC_mean=zeros(1,k);
    for i=1:k
        ROI_TC(:,:,:,i)=Y_image(:,:,:,i).*Y_ROI_mask;
        ROI_TC_mean(1,i)= mean(mean(mean(ROI_TC(:,:,:,i))));
    end

    % find the first 30 frames; 
    % there is a potential problem here, I am not sure now if we need to get
    % the abs value
    [sorted_ROI_time_course,index]=sort(ROI_TC_mean, 'descend');

    num_frame=30;
    frames_subj=zeros(m,n,l,num_frame);
    for i=1:num_frame
        frames_subj(:,:,:,i)= Y_image(:,:,:,index(i));
    end
    frames(:,:,:,(num_frame*(subj-1)+1):num_frame*subj)=frames_subj;
end

disp('finished selection of frames!');

% calculate the correlation and distance between any pair of frames;
% we just calculated the upper half of the matrix in order to reduce the computing time 
corr_matrix=zeros(num_frame*size(subjects,2),num_frame*size(subjects,2));
for i=1:num_frame*length(subjects)
    for j=1:i
        corr_matrix(i,j)=min(min(corrcoef(frames(:,:,:,i),frames(:,:,:,j))));
        disp(i); 
    end
end

% calculate the full matrix: corr_matrix=corr_matrix+corr_matrix'-eye(n,n)
corr_matrix=corr_matrix+corr_matrix'-eye(num_frame*length(subjects),num_frame*length(subjects));
dis_matrix=1-corr_matrix;

disp('finished calculation of the correlation and distance matrices!');
% clustering 
para.method= 'gaussian';
para.percent = 2.0;
[cluster_lables, center_idxs] = cluster_dp_cici(dis_matrix, para); 




                
            
