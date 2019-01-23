%% Demo script to run your own date through FLICA.

%% Set up:

addpath /usr/local/fmrib/fmt/
setenv('FREESURFER_HOME','/Applications/freesurfer/')
setenv('SUBJECTS_DIR','/Users/lnickerson/Desktop/Collabs/SZ_lICA/SZ_FLICA_10_02_12/flica_patients')
setenv('FSLOUTPUTTYPE','NIFTI_GZ')
setenv('FSLDIR','/usr/local/FSL')
%% Load data
% Yfiles = {'file1.nii.gz', 'file2.mgh'};
% NOTE that these should be downsampled to around 20k voxels in the mask,
% per modality... hoping to increase this memory/cpu-related limitation.
% Yfiles = {'LICA_denoised_all6_FA.nii.gz', 'LICA_denoised_all6_MD.nii.gz','LICA_denoised_all6_MO.nii.gz','LICA_denoised_all6_GM.nii.gz','LICA_denoised_all6_func.nii.gz','LICA_denoised_all6_?h.thickness10.mgh','LICA_denoised_all6_?h.area.pial10.mgh'};
% Yfiles = {'all133_FA.nii.gz', 'all133_MD.nii.gz','all133_GM_S4.nii.gz','all133_?h.thickness.fwhm10.mgh','all133_?h.area.pial.fwhm10.mgh'};
Yfiles = {'lica133_rm_com8_FA.nii.gz', 'lica133_rm_com8_MD.nii.gz','lica133_rm_com8_GM.nii.gz','lica133_rm_com8_?h.thickness10.mgh','lica133_rm_com8_?h.area.pial10.mgh'};

[Y,fileinfo] = flica_load(Yfiles);
% fileinfo.shortNames = {'First modality', 'Second modality'};

%% Run FLICA
clear opts
opts.num_components = 17;
opts.maxits = 2000;

Morig = flica(Y, opts);
[M, weights] = flica_reorder(Morig);

%% Save results
%outdir = '/Volumes/micc.mclean.harvard.edu/MJ_Data_Fusion/Reorg_Data/LICA_FINAL/licaout133_15com_MJ_FINAL/LICA_denoised/LICA_ALL6_13COM/';
mkdir licaout133_17com_struc;
outdir = '/Users/HJ/Desktop/LICA_struct_DTI46/licaout133_15com_highsmooth/LICA_denoised/licaout133_17com_struc/';
flica_save_everything(outdir, M, fileinfo);

%% Produce correlation plots
design = load('/Users/HJ/Desktop/LICA_struct_DTI46/design133.txt');
clear des
des.age = design(:,1);
des.sex = design(:,2);
des.onset = design(:,3);
des.grams = design(:,4);
des.dur = design(:,5);
des.Tim = design(:,6);
des.CM = design(:,7);
des.PP = design(:,8);
flica_posthoc_correlations(outdir, des);


clear Y
Yfiles = {'lica133_rm_com8_FA.nii.gz', 'lica133_rm_com8_MD.nii.gz','lica133_rm_com8_GM.nii.gz','lica133_rm_com8_?h.thickness10.mgh','lica133_rm_com8_?h.area.pial10.mgh'};

[Y,fileinfo] = flica_load(Yfiles);
% fileinfo.shortNames = {'First modality', 'Second modality'};

%% Run FLICA
clear opts
opts.num_components = 23;
opts.maxits = 2000;

Morig = flica(Y, opts);
[M, weights] = flica_reorder(Morig);

%% Save results
%outdir = '/Volumes/micc.mclean.harvard.edu/MJ_Data_Fusion/Reorg_Data/LICA_FINAL/licaout133_15com_MJ_FINAL/LICA_denoised/LICA_ALL6_13COM/';
mkdir licaout133_23com_struc;
outdir = '/Users/HJ/Desktop/LICA_struct_DTI46/licaout133_15com_highsmooth/LICA_denoised/licaout133_23com_struc/';
flica_save_everything(outdir, M, fileinfo);

%% Produce correlation plots
design = load('/Users/HJ/Desktop/LICA_struct_DTI46/design133.txt');
clear des
des.age = design(:,1);
des.sex = design(:,2);
des.onset = design(:,3);
des.grams = design(:,4);
des.dur = design(:,5);
des.Tim = design(:,6);
des.CM = design(:,7);
des.PP = design(:,8);
flica_posthoc_correlations(outdir, des);
% 
% clear opts M* w*
% opts.num_components = 30;
% opts.maxits = 2000;
% 
% Morig = flica(Y, opts);
% [M, weights] = flica_reorder(Morig);
% 
% %% Save results
% %outdir = '/Volumes/micc.mclean.harvard.edu/MJ_Data_Fusion/Reorg_Data/LICA_FINAL/licaout133_15com_MJ_FINAL/LICA_denoised/LICA_ALL6_13COM/';
% mkdir licaout133_30com_highsmooth;
% outdir = '/Users/HJ/Desktop/LICA_struct_DTI46/licaout133_30com_highsmooth/';
% flica_save_everything(outdir, M, fileinfo);
% 
% %% Produce correlation plots
% design = load('/Users/HJ/Desktop/LICA_struct_DTI46/design133.txt');
% clear des
% des.age = design(:,1);
% des.sex = design(:,2);
% des.onset = design(:,3);
% des.grams = design(:,4);
% des.dur = design(:,5);
% des.Tim = design(:,6);
% des.CM = design(:,7);
% des.PP = design(:,8);
% flica_posthoc_correlations(outdir, des);
% 
% %% Produce the report using command-line scripts:
% % cd(outdir)
% % %only run flica_report? I think all the other functions are included in
% % %that script
% % ./convert_pdftopng.sh
% % dos('/Users/lnickerson/Desktop/FLICA/render_surfaces.sh');
% % dos('/Users/lnickerson/Desktop/FLICA/surfaces_to_volumes_all.sh fsaverage /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz');
% % dos('/Users/lnickerson/Desktop/FLICA/render_lightboxes_all.sh');
% % dos('/Users/lnickerson/Desktop/FLICA/flica_report.sh /Users/lnickerson/Desktop/Collabs/SZ_lICA/SZ_FLICA_10_02_12/flica_patients/')
% % dos('open index.html')
% % 
% % 
% /Users/HJ/Documents/MATLAB/FLICA/convert_pdftopng_R01.sh
% /Users/HJ/Documents/MATLAB/FLICA/render_surfaces.sh
% /Users/HJ/Documents/MATLAB/FLICA/surfaces_to_volumes_all.sh fsaverage /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
% /Users/HJ/Documents/MATLAB/FLICA/render_lightboxes_all.sh 
% /Users/HJ/Documents/MATLAB/FLICA/flica_report.sh .