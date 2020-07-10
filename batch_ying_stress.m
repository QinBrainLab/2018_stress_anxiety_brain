% written by Liangying, 9/22/2019
% this script is for multisubjects using batch
% add spm12 toolbox in your path
% you  need to create the logfile.txt manually(locates in target_dir/test/logfile.txt , test is the name of test.mat storing batch)
% Delete the REST toolbox in yourclee path since it can cause conflict with spm
%% settings
clear;
clc;
target_dir = 'C:/Users/liuxiaomiao/Desktop/haiyang/RESULT/Network2/stress/Network_conn';
roi_rootdir = 'C:/Users/liuxiaomiao/Desktop/haiyang/RESULT/Network2/stress/ROI';
roi_form  = 'nii';
roi_list = dir (fullfile (roi_rootdir, ['*.', roi_form]));  %.nii
roi_list = struct2cell (roi_list);
roi_list = roi_list(1, :)';
roi_N = length(roi_list);     % automatically adding grey matter,white matter,CSF,atlas,network later

sub_dir = 'C:/Users/liuxiaomiao/Desktop/haiyang/RESULT/Network2/stress/sub_stress.txt';
fid = fopen(sub_dir);
subj = textscan(fid,'%s');
fclose(fid);
sub_N = length(subj{1});  % not length(subj)

con_N = 2;  % the number of conditions: 0 back + 2 back
sess_N = 1; % the number of sessions 
durations = [27,27,27,27,27,27];  % for 0back/2back
%durations = [27,27,27,27];       % for 0back/1back/2back
load('C:/Users/liuxiaomiao/Desktop/haiyang/RESULT/Network2/stress/Edata_onset/onset1.mat');  
load('C:/Users/liuxiaomiao/Desktop/haiyang/RESULT/Network2/stress/Edata_onset/onset2.mat');

TR = 2;

raw_dir = 'D:/brainbnu/haiyang/data_ghy';
func_dir = cell(sub_N,1);
struc_dir = cell(sub_N,1);
mvm_dir = cell(sub_N,1);
wm_dir = cell(sub_N,1);
csf_dir = cell(sub_N,1);
roi_dir = cell(roi_N,1);   % the directory of ROI lists
FUNCTIONAL_FILE = cell(sub_N,sess_N);
STRUCTURAL_FILE = cell(sub_N,sess_N);
batch.Setup.functionals =  repmat({{}},[sub_N,1]);
batch.Setup.structurals =  repmat({{}},[sub_N,1]);

%% Selects functional / anatomical volumes
for i = 1:sub_N
    year = ['20',subj{1}{i}(1:2)];
    eval(['func_dir{i} = fullfile(raw_dir ,year, subj{1}{i} ,''fmri'',''nback'',''smoothed_spm8'',''swcarI.nii'')']);
    eval(['struc_dir{i} = fullfile(raw_dir ,year, subj{1}{i} ,''mri'',''anatomy'',''wI.nii'')']);  % wI, no need for 'structural_normalize'
    eval(['mvm_dir{i} = fullfile(raw_dir , year,subj{1}{i} ,''fmri'',''nback'',''smoothed_spm8'',''rp_I.txt'')']); 
    tmp1 = fullfile(' ',raw_dir ,year, subj{1}{i} ,'fmri','WM','smoothed_spm8','wcarI.nii.gz');
    unix(['gunzip', tmp1]);
    tmp2 = fullfile(' ',raw_dir ,year, subj{1}{i} ,'fmri','WM','smoothed_spm8','meanarI.nii.gz');
    unix(['gunzip', tmp2]);
end

for i = 1: roi_N
    eval('roi_dir{i} = fullfile(roi_rootdir , roi_list{i})');
end

for i = 1:sub_N
    for j = 1:sess_N
    FUNCTIONAL_FILE{i,j}= func_dir{i};
    STRUCTURAL_FILE{i,j}= struc_dir{i};
    end
end

%% CONN New experiment
clear batch;
batch.filename=fullfile(target_dir,'conn_project001.mat');
batch.Setup.overwrite = 1;
%if ~isempty(dir(batch.filename)), 
%    Ransw=questdlg('conn_singlesubject01 project already exists, Overwrite?','warning','Yes','No','No');
%    if ~strcmp(Ransw,'Yes'), return; end; 
%end

%% CONN Setup
for i = 1:sub_N
    for j = 1:sess_N
        batch.Setup.functionals{i}{j} = FUNCTIONAL_FILE{i,j};
        batch.Setup.structurals{i}{j} = STRUCTURAL_FILE{i,j};
    end
end

batch.Setup.nsubjects = sub_N;
batch.Setup.RT=TR;

% rois
batch.Setup.rois.add = 1;
batch.Setup.rois.mask = 1;
for i = 1:roi_N
    batch.Setup.rois.names{i} = roi_list{i}(1:end-4);
    batch.Setup.rois.files{i}=  roi_dir{i};
end

batch.Setup.conditions.names{1}= '0back';    %can't be the {'0back'},can't add {}
batch.Setup.conditions.names{2}= '2back';

for j = 1:sub_N
    for k = 1:sess_N
            batch.Setup.conditions.onsets{1}{j}{k}=onset1(j,:);
            batch.Setup.conditions.durations{1}{j}{k}= durations;
     end
end

for j = 1:sub_N
    for k = 1:sess_N
            batch.Setup.conditions.onsets{2}{j}{k}=onset2(j,:);
            batch.Setup.conditions.durations{2}{j}{k}= durations;
     end
end

% covariates
batch.Setup.covariates.names= {'mvm'};   % six parameters of head movements, stored in rp_*.txt
batch.Setup.covariates.files{1}=repmat({{}},[sub_N,1]);
for i = 1:sub_N
    for j = 1:sess_N
        batch.Setup.covariates.files{1}{i}{j} = mvm_dir{i};
    end
end

batch.Setup.analyses=[1];                             % seed-to-voxel and ROI-to-ROI pipelines
%batch.Setup.preprocessing.steps={'structural_normalize'};   % realign the structual imgaes to MNI space (functional imgeas have been done)
batch.Setup.isnew=1;
batch.Setup.done=1;
%% CONN Denoising
batch.Denoising.filter=[0.008,inf];          % frequency filter (band-pass values, in Hz),inf(infinite)
batch.Denoising.done=1;
%% CONN Analysis
batch.Analysis.analysis_number=1;       % Sequential number identifying each set of independent first-level analyses
batch.Analysis.measure=1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
batch.Analysis.weight=2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
batch.Analysis.sources={};              % (defaults to all ROIs)
batch.Analysis.done=1;
batch.Analysis.type = 1;

%% RUN CONN BATCH STRUCTURE
conn_batch(batch);

%% CONN Display
%launches conn gui to explore results
conn
conn('load',fullfile(target_dir,'conn_project001.mat'));
%conn gui_results
