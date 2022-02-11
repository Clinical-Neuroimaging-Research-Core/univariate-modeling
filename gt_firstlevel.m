%-----------------------------------------------------------------------
% First-level model for the GT REW task
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% Script created by Jennifer Barredo, PhD; modified by Hannah Swearingen
% Last updated on 02/11/2022

study = '/path/to/analysis/study/directory'; % Example path/to/derivatives/analyses/gt
subjects = readmatrix([study,'/scripts/subjects.txt'])'; % List of subjects to analyze stored in the scripts directory

%% Exp info
% Update to match scan parameters

slices = 68;
refslice = 1;
TR = 1.1;
highpass = 128; 

%% Nuisance regressor weights
drift = 0;
numsess = [0 0];
motion = [0 0 0 0 0 0];

%%

spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)

for subject=subjects
    
    subject = num2str(subject, '%02d');
    disp(['Start processing subject number ',subject])
    subjectdir = fullfile(['/path/to/derivatives/analyses/gt/firstlevel-gt/sub-' subject '/ses-01']);
    
    % subjectdir is subject-level folders for SSRT analysis data; if these
    % folders do not already exist create them with a shell script and move
    % BOLD images and SSRT-related files to each subject's folder

    %% Make batch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(subjectdir)};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = slices;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refslice;

    %% Load scans
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(spm_select('expand',fullfile([subjectdir,'/smoothed_sub-' subject '_ses-01_task-card_dir-AP_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'])));

    %% Load session timing files (in order of session appearance)
    %% First run AP scans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tmp = dlmread(fullfile(subjectdir,'Reward1.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'Reward';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 30; %duration of blocks in seconds
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;

    tmp = dlmread(fullfile(subjectdir,'Punish1.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'Punish';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 30;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;

    tmp = dlmread(fullfile(subjectdir,'Baseline1.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'Baseline';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 15;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;

    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {'Drift'}, 'val', {linspace(-1,1,length(matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans))});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {fullfile(subjectdir,'GT_Realign_AP.txt')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = highpass;  % 2 times the longest task event cycle 


    %% Load run 2 (PA) scans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(spm_select('expand', fullfile([subjectdir,'/smoothed_sub-' subject '_ses-01_task-card_dir-PA_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'])));

    %% Load session timing files (in order of session appearance)
    tmp = dlmread(fullfile(subjectdir,'Reward2.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).name = 'Reward';
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = 30;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;

    tmp = dlmread(fullfile(subjectdir,'Punish2.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).name = 'Punish';
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).duration = 30;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).orth = 1;

    tmp = dlmread(fullfile(subjectdir,'Baseline2.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).name = 'Baseline';
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).onset = tmp(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).duration = 15;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(3).orth = 1;

    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {'Drift'}, 'val', {linspace(-1,1,length(matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans))});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {fullfile(fullfile(subjectdir,'GT_Realign_PA.txt'))};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = highpass;  % 2 times the longest task event cycle 

    %% Masking other essentials
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {'/path/to/mask.nii,1'}; %create a mask
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    %% Estimate the model
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(subjectdir,'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


    %%
    matlabbatch{3}.spm.stats.con.spmmat = {fullfile(subjectdir,'SPM.mat')};
    
    % condition order Reward, Punish, Baseline
    
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'All';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1/6,1/6,1/6,drift,motion,1/6,1/6,1/6,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';    
    
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Reward';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1/2,0,0,drift,motion,1/2,0,0,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Punish';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0,1/2,0,drift,motion,0,1/2,0,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Baseline';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0,0,1/2,drift,motion,0,0,1/2,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Reward-Punish';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0.5,-0.5,0,drift,motion,0.5,-0.5,0,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Reward-Baseline';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0.5,0,-0.5,drift,motion,0.5,0,-0.5,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Punish-Baseline';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0,0.5,-0.5,drift,motion,0,0.5,-0.5,drift,motion,numsess];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';


    spm_jobman('run',matlabbatch);
    display(['Finished processing subject number ',subject])
    cd([study])

end