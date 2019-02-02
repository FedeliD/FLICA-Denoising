%% Demo script to run your own date through FLICA, more info based on the flica webside: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLICA.

%% some info should be chaged based on your own data, sunch as lines 5-6 in render_surfaces.sh, the data path should be changed; lines 30 and 56 in render_surfaces.sh, the number should be changed based on your own data.

%% install ImageMagic, epstopdf first
%% download flica from FSL webside, and put it under Matlab folder

%% VBM data are threshold at 10% mean GM density value to remove closer to zero voxels
%% fmri cope data are threshold at z=2.3 before put into LICA

%% lines in flica.m from 138 to 148 have been adjusted for missing data


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
Yfiles = {'all_FA_skeletonised.nii.gz.nii.gz', 'all_MD_skeletonised.nii.gz.nii.gz','all_MO_skeletonised.nii.gz','GM_mod_merg_s3.nii.gz','COPE_func.nii.gz','?h.thick.fsaverage.mgh','?h.pial.area.fsaverage.mgh'};
[Y,fileinfo] = flica_load(Yfiles);
% fileinfo.shortNames = {'First modality', 'Second modality'};

%% Run FLICA
clear opts
% Define the component number
opts.num_components = 15;  
% Define the number of iterations, Convergence is declared when the change in F per iteration drops below 0.1. Check the F for each iteration to define the iteration number.
opts.maxits = 2000;

Morig = flica(Y, opts);
[M, weights] = flica_reorder(Morig);

%% Save results
%outdir = '/Volumes/micc.mclean.harvard.edu/MJ_Data_Fusion/Reorg_Data/LICA_FINAL/licaout133_15com_MJ_FINAL/LICA_denoised/LICA_ALL6_13COM/';
mkdir lica_rm_com8_15COM;
outdir = '/Users/HJ/Desktop/LICA_struct_DTI46/licaout133_15com_highsmooth/LICA_denoised/lica_rm_com8_15COM/';
flica_save_everything(outdir, M, fileinfo);

%% Produce correlation plots, design.txt is the covariable info
design = load('/Users/HJ/Desktop/LICA_struct_DTI46/design.txt');
clear des
des.age = design(:,1);
des.sex = design(:,2);
des.onset = design(:,3);
des.grams = design(:,4);
des.dur = design(:,5);
des.SSWV = design(:,6);
des.CM = design(:,7);
des.STUDY = design(:,8);
des.TOT_ACC = design(:,9);
des.TOT_OMIS = design(:,10);
des.TOT_COMM = design(:,11);
des.AVG_RT = design(:,12);
des.CT_RT = design(:,13);
des.INTER_ACC = design(:,14);
des.INTER_RT = design(:,15);
flica_posthoc_correlations(outdir, des);

clear


% %% Produce the report using command-line scripts:
% % cd(outdir)
%%% convert_pdftopng should be changed based on your own design.txt
% % ./convert_pdftopng.sh
% % dos('/Users/lnickerson/Desktop/FLICA/render_surfaces.sh');
% % dos('/Users/lnickerson/Desktop/FLICA/surfaces_to_volumes_all.sh fsaverage /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz');
% % dos('/Users/lnickerson/Desktop/FLICA/render_lightboxes_all.sh');
% % dos('/Users/lnickerson/Desktop/FLICA/flica_report.sh /Users/lnickerson/Desktop/Collabs/SZ_lICA/SZ_FLICA_10_02_12/flica_patients/')
% % dos('open index.html')
% % 
