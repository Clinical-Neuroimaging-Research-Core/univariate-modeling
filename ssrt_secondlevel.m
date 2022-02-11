%-----------------------------------------------------------------------
% Second-level model for the SSRT task
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% Script created by Jennifer Barredo, PhD; modified by Hannah Swearingen
% Last updated on 02/11/2022

study = '/path/to/analyses/ssrt';
subjectdir = fullfile(['/path/to/analyses/ssrt/firstlevel-ssrt/']); % Point to path of exisiting first-level subject directories
subjects = readmatrix([study,'/scripts/subjects_patients.txt'])'; % List of subjects to analyze stored in the scripts directory
contrasts = {'All','GoCorrect','StopCorrect','StopError','StopCorrect-GoCorrect','StopCorrect-StopError', 'GoCorrect-goError'};

%%
spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true);

%%
for j=1:length(contrasts)
    clear matlabbatch
    mkdir(fullfile(study,'secondlevel-new',contrasts{j}));
    
    for i=1:length(subjects)
        subject = num2str(subjects(i), '%02d');
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{i,1} = (fullfile([subjectdir, 'sub-' subject '/ses-01/', ['con_',sprintf('%04d',j),'.nii,1']]));
    end
    
    matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(fullfile(study,'secondlevel-ssrt',contrasts{j}));
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/path/to/mask.nii,1'};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(study,'secondlevel-ssrt',contrasts{j},'SPM.mat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(study,'secondlevel-ssrt',contrasts{j},'SPM.mat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Mean';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;  % [mean, cov1, cov2];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    spm_jobman('run',matlabbatch);
    display(['Finished processing contrast number ',j])
    cd([study,'/scripts'])
end