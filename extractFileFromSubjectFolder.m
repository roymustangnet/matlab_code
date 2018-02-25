%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select files from subject directory and save them to new subject folder %
% author : supakito, lbj                                                  %
% version: v1.0                                                           %
% time:2018.02.24                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function extractFileFromSubjectFolder(srcRootFolder,desRootFolder,fileName)
    idir=dir(srcRootFolder);
    for i=3:length(idir)
        %%% Get the folder name for each subject under the root folder(srcRootFolder) 
        %%% and then create a folder with the same name under desRootFolder
        subj_name=idir(i).name; 
        des_subj_folder = [desRootFolder, filesep, subj_name];
        %cd(desRootFolder)
        if ~exist(des_subj_folder)
            mkdir(des_subj_folder)
        end
        %%%copy the files from the source to the target folder
        if ~exist([des_subj_folder, filesep, fileName]) 
            src_subj_file = [srcRootFolder filesep subj_name filesep fileName]
            copyfile(src_subj_file,des_subj_folder);
        end
        fprintf('Has copied %d/%d files\r',i-2,length(idir)-2)
    end
end