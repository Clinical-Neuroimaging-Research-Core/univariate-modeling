study = '/path/to/analyses/ssrt';
subjects = readmatrix([study,'/scripts/subjects.txt'])'; % List of subjects to analyze stored in the scripts directory


%first loop for session1 of SSRT (dir-AP)
for subject=subjects
    subjectdir = fullfile(['/path/to/analyses/ssrt/firstlevel-ssrt/sub-' num2str(subject) '/ses-01']);
    cd(subjectdir);
    confounds = tdfread(['sub-' num2str(subject) '_ses-01_task-ssrt_dir-AP_desc-confounds_timeseries.tsv']);
    x=confounds.rot_x;
    y=confounds.rot_y;
    z=confounds.rot_z;
    roll=confounds.trans_x;
    pitch=confounds.trans_y;
    yaw=confounds.trans_z;
    realignAP = horzcat(x,y,z,roll,pitch,yaw);
    writematrix(realignAP, 'SSRT_Realign_AP.txt')
end

study = '/path/to/analyses/ssrt';
subjects = readmatrix([study,'/scripts/subjects.txt'])'; % List of subjects to analyze stored in the scripts directory


%second loop for session2 of SSRT (dir-PA)
for subject=subjects
    subjectdir = fullfile(['/path/to/analyses/ssrt/firstlevel-ssrt/sub-' num2str(subject) '/ses-01']);
    cd(subjectdir);
    confounds = tdfread(['sub-' num2str(subject) '_ses-01_task-ssrt_dir-PA_desc-confounds_timeseries.tsv']);
    x=confounds.rot_x;
    y=confounds.rot_y;
    z=confounds.rot_z;
    roll=confounds.trans_x;
    pitch=confounds.trans_y;
    yaw=confounds.trans_z;
    realignPA = horzcat(x,y,z,roll,pitch,yaw);
    writematrix(realignPA, 'SSRT_Realign_PA.txt')
end
