%% LAST UPDATED 03/23/2022
% CREATED BY JENNIFER BARREDO, MODIFIED BY HANNAH SWEARINGEN

%% THIS SCRIPT IS DESIGNED TO CREATE A CONN_BATCH.MAT FILE TO BE UPLOADED INTO THE GUI
% This script will take fMRIPrep pre-processed structural and functional images 
% and load them into a CONN model. 

%% UNDERSTANDING SESSIONS / SCANS

% In this script, SESSIONS refers to timepoint (or each individual time a
% subject went to the scanner.
% SCANS refers to the number of runs at each timepoint (e.g. AP Rest, PA
% Rest; Run-1 Rest, Run-2 Rest)


% The sessions and scans variables below are used for as variables
% in the paths during the subject loops so the script can easily find each
% subject's session and scan data

% Realignment files must be created using the fMRIprep confounds.tsv file
% Each session will have 1 single confound file - vertically concatenate
% each scan's realignment file together to get a single realignment file.


%% Set up path environments 
addpath(genpath('/path/to/study/directory/'));

%% Config for no desktop mode
spm defaults fmri
spm_jobman initcfg
spm_get_defaults('cmdline',true)


%% STUDY-SPECIFIC PARAMETERS
study = '/path/to/study/directory';                                            %path to study directory
study_dir = '/path/to/study/derivatives/fmriprep';                   %path to fmriprep directory
analysis_dir = '/path/to/study/derivatives/rest';               %path to analysis folder within derivatives folder
roi_dir = fullfile(analysis_dir,'rois');                                    %path to ROI directory within the analysis directory
TR=1.1;

%% SETTING UP SCANS AND SESSIONS

sessions = {'ses-01','ses-02'};
scans = {'AP','PA'};

%% SUBJECTS
subjects = num2cell(dlmread([study, '/code/test_subjects.txt']))';
NSUBJECTS = length(subjects); 
NSESSIONS = length(sessions);
NSCANS = length(scans);

%% SUBJECT LOOP FOR FILE ARRAYS
STRUCTURAL_FILE = cell(NSUBJECTS,1);
FUNCTIONAL_FILE = cell(NSUBJECTS,NSESSIONS,NSCANS);

for i = 1:NSUBJECTS
    subject = num2str(subjects{i});
    
    for j = 1:NSESSIONS
        session = sessions{j};
        
        if exist(([study_dir, '/sub-' subject '/anat']), 'dir')
            disp('Subject has multiple runs')
            STRUCTURAL_FILE(i,1) = cellstr(fullfile([study_dir,'/sub-' subject '/anat/sub-' subject '_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz']));
        else
            disp('Subject has one run')
            STRUCTURAL_FILE(i,1) = cellstr(fullfile([study_dir,'/sub-' subject, '/' session, '/anat/sub-' subject, '_' session '_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz']));
        end       
         
        REALIGNMENT_FILE(i,j) = cellstr(fullfile([study_dir,'/sub-' subject '/' session '/func/Rest_Realign.txt']));
        
        for k = 1:NSCANS
            scan = scans{k};
            
            FUNCTIONAL_FILE(i,j,k) = cellstr(fullfile([study_dir,'/sub-' subject '/' session '/func/sub-' subject '_' session '_task-rest_dir-' scan '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz']));
             
        end
            

                    
    end
end


%% CREATES CONN BATCH STRUCTURE
clear batch;
cd(analysis_dir);
cwd=pwd;
batch.filename=fullfile(analysis_dir,'rest.mat');            % New conn_*.mat experiment name


%% SETUP BATCH   
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;


%% SETUP CONDITION STRUCTS
batch.Setup.conditions.missingdata = 1;
nconditions=NSESSIONS;

if nconditions==1
    batch.Setup.conditions.names=sessions;
    for ncond=1
        for nsub=1:NSUBJECTS
            for nses=1:NSESSIONS              
                batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
                batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
            end
        end
    end     % rest condition (all sessions)
else

    batch.Setup.conditions.names=sessions;
    for ncond=1
        for nsub=1:NSUBJECTS
            for nses=1:NSESSIONS
                batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; 
                batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
            end
        end
    end     % rest condition (all sessions)
    for ncond=1:nconditions
        for nsub=1:NSUBJECTS
            for nses=1:NSESSIONS
                batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=[];
                batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=[]; 
            end
        end
    end
    for ncond=1:nconditions
        for nsub=1:NSUBJECTS
            for nses=ncond
                batch.Setup.conditions.onsets{1+ncond}{nsub}{nses}=0; 
                batch.Setup.conditions.durations{1+ncond}{nsub}{nses}=inf;
            end
        end
    end % session-specific conditions
end

%% POINT TO STRUCTURAL, FUNCTIONAL IMAGES & 1ST LEVEL COVARIATES

batch.Setup.structurals=STRUCTURAL_FILE; 

batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);

for nsub=1:NSUBJECTS
    for nses=1:NSESSIONS
        for nsca=1:NSCANS
            if ~isnan(FUNCTIONAL_FILE{nsub,nses,nsca})
                batch.Setup.functionals{nsub}{nses}{nsca}=FUNCTIONAL_FILE{nsub,nses,nsca};
            end
        end
    end
end


batch.Setup.covariates.names={'realignment'};
batch.Setup.covariates.files{1}=repmat({{}},[NSUBJECTS,1]);

for nsub=1:NSUBJECTS
    for nses=1:NSESSIONS
        batch.Setup.covariates.files{1}{nsub}{nses}=REALIGNMENT_FILE{nsub,nses};
    end
end

%% POINT TO ANATOMICALS & MASKS
batch.Setup.voxelmask = 1;
batch.Setup.voxelmaskfile = fullfile([analysis_dir], 'nstb_binary.nii');

for i = 1:NSUBJECTS
    subject = num2str(subjects{i});
    if exist(([study_dir, '/sub-' subject '/anat']), 'dir')
        batch.Setup.masks.Grey(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/anat/sub-' subject '_label-GM_probseg.nii.gz']));
        batch.Setup.masks.White(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/anat/sub-' subject '_label-WM_probseg.nii.gz']));
        batch.Setup.masks.CSF(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/anat/sub-' subject '_label-CSF_probseg.nii.gz']));
    else
        batch.Setup.masks.Grey(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/' session '/anat/sub-' subject '_ses-01_label-GM_probseg.nii.gz']));
        batch.Setup.masks.White(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/' session '/anat/sub-' subject '_ses-01_label-WM_probseg.nii.gz']));
        batch.Setup.masks.CSF(i,1) = cellstr(fullfile([study_dir, '/sub-' subject '/' session '/anat/sub-' subject '_ses-01_label-CSF_probseg.nii.gz']));
    end
end      
    

%% SET UP ROIs
batch.Setup.rois.names = {'R_Insula','R_MidTemporal','R_Opercularis', 'R_SMA'};

batch.Setup.rois.files{1} = {cellstr(fullfile(roi_dir,'R_Insula.nii'))};
batch.Setup.rois.multiplelabels(1) = 1;
batch.Setup.rois.files{2} = {cellstr(fullfile(roi_dir,'R_MidTemporal.nii'))};
batch.Setup.rois.multiplelabels(2) = 1;
batch.Setup.rois.files{3} = {cellstr(fullfile(roi_dir,'R_Opercularis.nii'))};
batch.Setup.rois.multiplelabels(3) = 1;
batch.Setup.rois.files{4} = {cellstr(fullfile(roi_dir,'R_SMA.nii'))};
batch.Setup.rois.multiplelabels(4) = 1;


%% DECLARE OUTPUT FILES
batch.Setup.outputfiles(2) = 1;
batch.Setup.outputfiles(6) = 1;
batch.Setup.analyses = [1,2,3];


%% RUN SETUP 
batch.Setup.overwrite='Yes'; 
batch.Setup.done=1;

%% Run Smoothing
%fMRIprep does not smooth images
batch.Setup.preprocessing.steps={'functional_smooth'};
batch.Setup.preprocessing.fwhm=6;                                           %smoothing kernal fwhm (mm)


%% BATCH.Denoising PERFORMS DenoISING STEPS (confound removal & filtering) %!
batch.Denoising.filter = [0.008 0.1];
batch.Denoising.detrending = 1; 
batch.Denoising.confounds.names = {'White Matter','CSF','realignment'};
batch.Denoising.confounds.dimensions = {10,10,[],[],1};
batch.Denoising.confounds.deriv = {0,0,1,0,1};
batch.Denoising.overwrite = 'Yes';
batch.Denoising.done = 1;


%% RUN DENOISING
batch.Denoising.overwrite = 'Yes';
batch.Denoising.done = 1;


%% FIRST-LEVEL ANALYSIS
batch.Analysis.measure=1; % Bivarite correlation


%% RUN ANALYSIS 
batch.Analysis.overwrite='Yes'; 
batch.Analysis.done=1;


%% Run all analyses                           
conn_batch(batch);



