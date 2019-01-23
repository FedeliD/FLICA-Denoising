%% Demo script to run your own date through FLICA.

%% Set up: fill in DIRs
addpath /DIR/fsl/etc/matlab/
addpath /DIR/freesurfer/matlab
outdir = '/Volumes/data7/lnickerson/Killgore/DARPA/LICA_07_2014/flicaOUTPUT_15comps_minusS030/'
%% Load data
cd /Volumes/Data7/lnickerson/Killgore/DARPA/LICA_07_2014
Yfiles = {'all_FA_30zeroed.nii.gz', 'all_MD_30zeroed.nii.gz', 'all_MO_30zeroed.nii.gz', 'GM_mod_merg_s3_4mm_30zeroed.nii.gz','?h.area.pial.10B_30zeroed.mgh','?h.thickness.10B_30zeroed.mgh','all_NBACK_spmT_0002_nonan_30zeroed.nii.gz'};
% NOTE that these should be downsampled to around 20k voxels in the mask,
% per modality... hoping to increase this memory/cpu-related limitation.
[Y,fileinfo] = flica_load(Yfiles);
fileinfo.shortNames = {'FA', 'MD', 'MO','GM_mod','Pial Area','Thickness','NBACK'};

%% Run FLICA
clear opts
opts.num_components = 8;
opts.maxits = 5000;
Morig = flica(Y, opts);

[M, weights] = flica_reorder(Morig);

%% Save results
flica_save_everything(outdir, M, fileinfo);

%% Produce correlation plots
%des=dataset('XLSFile','LICA_Covariates_All_08_2014.xlsx') % NOTE!!! do not actually use this, this is just the file that contains variables/values. 
%do the following: design = [paste the values of the covariates from above
%spreadsheet];
clear des
des.Age=design(:,1);
des.Sex=design(:,2);
des.Speed_PB=design(:,3);
des.Speed=design(:,4);
des.LB_Speed=design(:,5);
des.LBPB_Speed=design(:,6);
des.Lapses=design(:,7);
des.Sqrt_Lapses=design(:,8);
des.Bott10_Speed=design(:,9);
des.Top10_Speed=design(:,10);
des.GABA_vmpfc=design(:,11);
des.GABA_dlpfc=design(:,12);

flica_posthoc_correlations_uncorr(outdir, des);

%% Produce the report using command-line scripts:
cd(outdir)
dos('~/Desktop/FLICA/render_surfaces.sh');
dos('~/Desktop/FLICA/render_lightboxes_all.sh');
dos('~/Desktop/FLICA/flica_html_report.sh')
dos('open index.html')
