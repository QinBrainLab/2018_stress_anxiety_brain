% Preprocess fMRI data with a specified pipeline
%__________________________________________________________________________
 
function preprocessfmri_qin(ConfigFile)

CurrentDir = pwd;

disp('==================================================================');
fprintf('Current directory: %s\n', CurrentDir);
fprintf('Script: %s\n', which('preprocessfmri.m'));
fprintf('Configfile: %s\n', ConfigFile);
fprintf('\n');

ConfigFile = strtrim(ConfigFile);
if ~strcmp(ConfigFile(end-1:end), '.m')
  ConfigFile = [ConfigFile, '.m'];
end

if ~exist(fullfile(CurrentDir, ConfigFile), 'file')
  fprintf('Error: cannot find the configuration file ... \n');
  return;
end

ConfigFile = ConfigFile(1:end-2);
eval(ConfigFile);
clear ConfigFile;

SubjectList     = strtrim(paralist.SubjectList);
SessionList     = strtrim(paralist.SessionList);
InputImgPrefix  = strtrim(paralist.InputImgPrefix);
WholePipeLine   = strtrim(paralist.EntirePipeLine);
PipeLine        = WholePipeLine(1:end-length(InputImgPrefix));
SPGRSubjectList = strtrim(paralist.SPGRSubjectList);
ServerPath = strtrim(paralist.ServerPath); %Shaozheng added

disp('-------------- Contents of the Parameter List --------------------');
disp(paralist);
clear paralist;
disp('==================================================================');

%==========================================================================
%-Hard-coded configurations
%-Must notify tianwenc@stanford.edu if you make any changes below
DataType = 'nii';
OutputFolder = 'smoothed_spm8';
%ServerPath = '/fs/musk1';
SmoothWidth  = [6 6 6];
BoundingBoxDim = [-90 -126 -72; 90 90 108];
TemplatePath = '/home/qinlab/SPM/spm8_scripts/BatchTemplates';
SPGRFolder = 'anatomy';
SPGRFileName = 'I';
%SPGRFileName = 'skullstrip_mprg';
%==========================================================================

if any(~ismember(DataType, {'nii', 'img'}))
  disp('Error: wrong data type specified');
  return;
end

if any(SmoothWidth < 0)
  disp('Error: smoothing kernel width cannot be negative');
  return;
end

if ~exist(TemplatePath, 'dir')
  disp('Error: template folder does not exist!');
  return;
end
% genghaiyang edit, what is flipflag?
if ismember('f', WholePipeLine)
  FlipFlag = 1;
else
  FlipFlag = 0;
end

Subjects = ReadList(SubjectList);
NumSubj  = length(Subjects);
Sessions = ReadList(SessionList); % what format is ?
NumSess  = length(Sessions);

if ~isempty(SPGRSubjectList)
  SPGRSubjects = ReadList(SPGRSubjectList);
  NumSPGRSubj = length(SPGRSubjects);
else
  SPGRSubjects = Subjects; % what is SPGR
  NumSPGRSubj = NumSubj;
end

if NumSPGRSubj ~= NumSubj
  disp('Number of functional subjects is not equal to the number of SPGR subjects');
  return;
end

NumTotalSess = NumSubj*NumSess;
ErrMsg = cell(NumTotalSess, 1);
ErrMsgFlag = zeros(NumTotalSess, 1);
TotalSessionDir = cell(NumTotalSess, 1);

VolRepairFlag = zeros(NumTotalSess, 1);
VolRepairDir = cell(NumTotalSess, 1);

% PipeLineFamily = {'swar', 'swavr', 'swgcar', 'swgcavr', ...
%   'swfar', 'swfavr', 'swgcfar', 'swgcfavr', ...
%   'swaor', 'swgcaor', 'swfaor', 'swgcfaor'};
% 
% if any(~ismember(WholePipeLine, PipeLineFamily))
%   disp('Error: unrecognized entire pipeline to be implemented');
%   return;
% end

spm('defaults', 'fmri');
spm_jobman('initcfg');
delete(get(0, 'Children'));%?

SessCnt = 0;
for iSubj = 1:NumSubj
  YearId = ['20', Subjects{iSubj}(1:2)];
  fprintf('Processing subject: %s\n', Subjects{iSubj});
  
  SPGRDir = fullfile(ServerPath, YearId, SPGRSubjects{iSubj}, 'mri', SPGRFolder);
  SPGRFile = '';
  if ismember('c', WholePipeLine)
    unix(sprintf('gunzip -fq %s', fullfile(SPGRDir, [SPGRFileName, '*.gz'])));
    ListFile = dir(fullfile(SPGRDir, [SPGRFileName, '*']));
    SPGRFile = fullfile(SPGRDir, ListFile(1).name);
  end
  
  for iSess = 1:NumSess
    SessCnt = SessCnt + 1;
    ErrCnt = 1;
    fprintf('---> session: %s\n', Sessions{iSess});
    
    TotalSessionDir{SessCnt} = fullfile(ServerPath, YearId, Subjects{iSubj}, 'fmri', ...
      Sessions{iSess});
    
    TempDir = fullfile(TotalSessionDir{SessCnt}, ['temp_', WholePipeLine]);
    
    UnnormDir = fullfile(TotalSessionDir{SessCnt}, 'unnormalized');
    if isempty(InputImgPrefix)
      if ~exist(TempDir, 'dir')
        mkdir(TempDir);
      else
        unix(sprintf('/bin/rm -rf %s', fullfile(TempDir, '*')));
      end
      unix(sprintf('cp -af %s %s', fullfile(UnnormDir, ['I.', DataType, '.gz']), ...
        TempDir));
      unix(sprintf('gunzip -fq %s', fullfile(TempDir, 'I*.gz')));
    end
    
    OutputDir = fullfile(ServerPath, YearId, Subjects{iSubj}, 'fmri', ...
      Sessions{iSess}, OutputFolder);
    PfileDir = fullfile(ServerPath, YearId, Subjects{iSubj}, 'fmri', ...
      Sessions{iSess}, 'Pfiles');
    VolRepairDir{SessCnt} = TempDir;
    
    if ~exist(OutputDir, 'dir')
      mkdir(OutputDir);
    end
    
    OutputLog = fullfile(OutputDir, 'log');
    if ~exist(OutputLog, 'dir')
      mkdir(OutputLog);
    end
    
    if ~isempty(InputImgPrefix)
      if ~exist(TempDir, 'dir')
        ErrMsg{SessCnt}{ErrCnt} = sprintf('Directory does not exist: %s\n', TempDir);
        disp(ErrMsg{SessCnt}{ErrCnt});
        ErrCnt = ErrCnt + 1;
        ErrMsgFlag(SessCnt) = 1;
        continue;
      end
      ListFile = dir(fullfile(TempDir, 'meanI*'));
      if isempty(ListFile)
        ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no meanI* image found when InputImgPrefix is not empty');
        disp(ErrMsg{SessCnt}{ErrCnt});
        ErrCnt = ErrCnt + 1;
        ErrMsgFlag(SessCnt) = 1;
        continue;
      else
        MeanImgFile = fullfile(TempDir, ListFile(1).name);
      end
    end
    
    PrevPrefix = InputImgPrefix;
    nstep = length(PipeLine);
    
    for cnt = 1:nstep
      
      p = PipeLine(nstep-cnt+1);
      
      switch p
        case 'r'
          ListFile = dir(fullfile(TempDir, [PrevPrefix, 'I*.gz']));
          if ~isempty(ListFile)
            unix(sprintf('gunzip -fq %s', fullfile(TempDir, [PrevPrefix, 'I*.gz'])));
          else
            [InputImgFile, SelectErr] = preprocessfmri_selectfiles(TempDir, PrevPrefix, DataType);
            if SelectErr == 1
              ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no scans selected');
              disp(ErrMsg{SessCnt}{ErrCnt});
              ErrCnt = ErrCnt + 1;
              ErrMsgFlag(SessCnt) = 1;
              break;
            end
            preprocessfmri_realign(WholePipeLine, CurrentDir, TemplatePath, InputImgFile, TempDir)
            unix(sprintf('/bin/rm -rf %s', fullfile(TempDir, '*.mat')));
          end
          
          ListFile = dir(fullfile(OutputDir, ['rp_', PrevPrefix, 'I*.txt*.gz']));
          if ~isempty(ListFile)
            unix(sprintf('gunzip -fq %', fullfile(OutputDir, ['rp_', PrevPrefix, 'I*.txt*.gz'])));
          else
            ListFile = dir(fullfile(OutputDir, ['rp_', PrevPrefix, 'I*.txt']));
            if isempty(ListFile)
              unix(sprintf('cp -af %s %s', fullfile(TempDir, ['rp_', PrevPrefix, 'I*.txt']), OutputDir));
            end
          end
          
          ListFile = dir(fullfile(TempDir, ['mean', PrevPrefix, 'I*', DataType]));
          MeanImgFile = fullfile(TempDir, ListFile(1).name);
          
          
          if strcmpi(DataType, 'img')
            P = spm_select('ExtFPList', TempDir, ['^r', PrevPrefix, 'I.*\.img']);
          else
            P = fullfile(TempDir, ['r', PrevPrefix, 'I.nii']);
          end
          VY = spm_vol(P);
          NumScan = length(VY);
          disp('calculating the global signals ...');
          fid = fopen(fullfile(OutputDir, 'VolumRepair_GlobalSignal.txt'), 'w+');
          for iScan = 1:NumScan
            fprintf(fid, '%.4f\n', spm_global(VY(iScan)));
          end
          fclose(fid);
          
        case 'v' % what is VolRepair?
          VolFlag = preprocessfmri_VolRepair(TempDir, DataType, PrevPrefix);
          VolRepairFlag(SessCnt) = VolFlag;
          nifti3Dto4D(TempDir, PrevPrefix);
          unix(sprintf('gunzip -fq %s', fullfile(TempDir, ['v', PrevPrefix, 'I*.gz'])));
          
          if VolFlag == 1
            disp('Skipping Art_Global (v) step ...');
            break;
          else
            unix(sprintf('mv -f %s %s', fullfile(TempDir, 'art_deweighted.txt'), OutputDir));
            %unix(sprintf('mv -f %s %s', fullfile(TempDir, 'ArtifactMask.nii'), OutputLog));
            unix(sprintf('mv -f %s %s', fullfile(TempDir, 'art_repaired.txt'), OutputLog));
            unix(sprintf('mv -f %s %s', fullfile(TempDir, '*.jpg'), OutputLog));
          end
          
         case 'o'
          VolFlag = preprocessfmri_VolRepair_OVersion(TempDir, DataType, PrevPrefix);
          VolRepairFlag(SessCnt) = VolFlag;
          %nifti3Dto4D(TempDir, PrevPrefix);
          unix(sprintf('mv -f %s %s', fullfile(TempDir, ['v', PrevPrefix, 'I.nii.gz']), fullfile(TempDir, ['o', PrevPrefix, 'I.nii.gz'])));
          unix(sprintf('gunzip -fq %s', fullfile(TempDir, ['o', PrevPrefix, 'I*.gz'])));
          
          
          if VolFlag == 1
            disp('Skipping Art_Global (o) step ...');
            break;
          else
            unix(sprintf('mv -f %s %s', fullfile(TempDir, 'art_deweighted.txt'), fullfile(OutputDir, 'art_deweighted_o.txt')));
            %unix(sprintf('mv -f %s %s', fullfile(TempDir, 'ArtifactMask.nii'), OutputLog));
            unix(sprintf('mv -f %s %s', fullfile(TempDir, 'art_repaired.txt'), fullfile(OutputLog, 'art_repaired_o.txt')));
            unix(sprintf('mv -f %s %s', fullfile(TempDir, '*.jpg'), OutputLog));
          end
          
          
        case 'f'
          preprocessfmri_FlipZ(TempDir, PrevPrefix);
          
        case 'a'
          [InputImgFile, SelectErr] = preprocessfmri_selectfiles(TempDir, PrevPrefix, DataType);
          if SelectErr == 1
            ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no scans selected');
            disp(ErrMsg{SessCnt}{ErrCnt});
            ErrCnt = ErrCnt + 1;
            ErrMsgFlag(SessCnt) = 1;
            break;
          end
          preprocessfmri_slicetime(WholePipeLine, TemplatePath, InputImgFile, FlipFlag, PfileDir, TempDir); % what is the difference?
          
        case 'c'
          [InputImgFile, SelectErr] = preprocessfmri_selectfiles(TempDir, PrevPrefix, DataType);
          if SelectErr == 1
            ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no scans selected');
            disp(ErrMsg{SessCnt}{ErrCnt});
            ErrCnt = ErrCnt + 1;
            ErrMsgFlag(SessCnt) = 1;
            break;
          end
          preprocessfmri_coreg(WholePipeLine, TemplatePath, DataType, SPGRFile, MeanImgFile, TempDir, InputImgFile, PrevPrefix);
          break;
          
        case 'w'
          [InputImgFile, SelectErr] = preprocessfmri_selectfiles(TempDir, PrevPrefix, DataType);
          if SelectErr == 1
            ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no scans selected');
            disp(ErrMsg{SessCnt}{ErrCnt});
            ErrCnt = ErrCnt + 1;
            ErrMsgFlag(SessCnt) = 1;
            break;
          end
          preprocessfmri_normalize(WholePipeLine, CurrentDir, TemplatePath, BoundingBoxDim, [PipeLine, InputImgPrefix], InputImgFile, MeanImgFile, TempDir, SPGRFile);
          
        case 'g'
          ListFile = dir(fullfile(SPGRDir, 'seg', '*seg_sn.mat'));
          if isempty(ListFile)
            ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no segmentation has been done, use preprocessfmri_seg.m');
            disp(ErrMsg{SessCnt}{ErrCnt});
            ErrCnt = ErrCnt + 1;
            ErrMsgFlag(SessCnt) = 1;
            break;
          else
            if strcmp(DataType, 'img')
              ImgListFile = dir(fullfile(TempDir, [PrevPrefix, 'I*.img']));
              HdrListFile = dir(fullfile(TempDir, [PrevPrefix, 'I*.hdr']));
              NumFile = length(ImgListFile);
              for iFile = 1:NumFile
                unix(sprintf('cp -af %s %s', fullfile(TempDir, ImgListFile(iFile).name), ...
                  fullfile(TempDir, ['g', ImgListFile(iFile).name])));
                unix(sprintf('cp -af %s %s', fullfile(TempDir, HdrListFile(iFile).name), ...
                  fullfile(TempDir, ['g', HdrListFile(iFile).name])));
              end
            else
              ListFile = dir(fullfile(TempDir, [PrevPrefix, 'I.nii']));
              unix(sprintf('cp -af %s %s', fullfile(TempDir, ListFile(1).name), ...
                fullfile(TempDir, ['g', ListFile(1).name])));
            end
          end
          
        case 's'
          [InputImgFile, SelectErr] = preprocessfmri_selectfiles(TempDir, PrevPrefix, DataType);
          if SelectErr == 1
            ErrMsg{SessCnt}{ErrCnt} = sprintf('Error: no scans selected');
            disp(ErrMsg{SessCnt}{ErrCnt});
            ErrCnt = ErrCnt + 1;
            ErrMsgFlag(SessCnt) = 1;
            break;
          end
          preprocessfmri_smooth(WholePipeLine, TemplatePath, InputImgFile, TempDir, SmoothWidth);
          
      end
      PrevPrefix = [PipeLine((nstep-cnt+1):nstep), InputImgPrefix];
      disp('------------------------------------------------------------');
    end
    
    if strcmp(PrevPrefix(1), 's')
      for iInter = 2:length(PrevPrefix)
        InterPrefix = PrevPrefix(iInter:end);
        ListFile = dir(fullfile(TempDir, [InterPrefix, 'I*']));
        NumFile = length(ListFile);
        for iInterFile = 1:NumFile
          unix(sprintf('/bin/rm -rf %s', fullfile(TempDir, ListFile(iInterFile).name)));
        end
      end
      unix(sprintf('/bin/rm -rf %s', fullfile(TempDir, '*.mat*')));
      unix(sprintf('gzip -fq %s', fullfile(TempDir, [PrevPrefix, 'I*'])));
      unix(sprintf('gzip -fq %s', fullfile(OutputDir, 'mean*I*')));
      unix(sprintf('gzip -fq %s', fullfile(TempDir, 'mean*I*')));
      unix(sprintf('mv -f %s %s', fullfile(TempDir, 'mean*I*'), OutputDir));
      unix(sprintf('mv -f %s %s', fullfile(TempDir, [PrevPrefix, 'I*']), OutputDir));
      unix(sprintf('mv -f %s %s', fullfile(TempDir, 'log', '*.mat'), fullfile(OutputDir, 'log')));
      unix(sprintf('mv -f %s %s', fullfile(TempDir, 'log', '*.pdf'), fullfile(OutputDir, 'log')));
      ListFile = dir(fullfile(OutputDir, '*.mat*'));
      if ~isempty(ListFile)
        unix(sprintf('/bin/rm -rf %s', fullfile(OutputDir, '*.mat*')));
      end
      ListFile = dir(fullfile(OutputDir, '*.jpg*'));
      if ~isempty(ListFile)
        unix(sprintf('/bin/rm -rf %s', fullfile(OutputDir, '*.jpg*')));
      end
      unix(sprintf('/bin/rm -rf %s', TempDir));
    end
  end
  if all(ismember('sc', [PipeLine, InputImgPrefix]))
    unix(sprintf('gzip -fq %s', SPGRFile));
  end
end

cd(CurrentDir);

disp('==================================================================');
if sum(ErrMsgFlag) == 0
  if ~strcmp(PrevPrefix(1), 's') && ismember('c', WholePipeLine)
    disp('Please check coregistration quality');
  else
    disp('Preprocessing finished');
  end
else
  c = fix(clock);
  ErrFile = sprintf('ErrMsg_preprocessfmri_%d_%d_%d_%d_%d_%d.txt', c);
  fprintf('Please check: %s\n', ErrFile)
  ErrIndex = find(ErrMsgFlag == 1);
  fid = fopen(ErrFile, 'w+');
  for i = 1:length(ErrIndex)
    fprintf(fid, '%s\n', TotalSessionDir{ErrIndex(i)});
    for j = 1:length(ErrMsg{ErrIndex(i)})
      fprintf(fid, '---> %s\n', ErrMsg{ErrIndex(i)}{j});
    end
  end
  fclose(fid);
end

if ismember('v', PipeLine)
  if sum(VolRepairFlag) > 0
    disp('Please check: VolumeRepair_Flagged_Subjects_Sessions.txt for flagged subject_sessions');
    flagfid = fopen('VolumeRepair_Flagged_Subjects_Sessions.txt', 'w');
    VolRepIndx = find(VolRepairFlag == 1);
    for i = 1:length(VolRepIndx)
      fprintf(flagfid, '%s\n', VolRepairDir{VolRepIndx(i)});
    end
    fclose(flagfid);
  end
end

delete(get(0, 'Children'));
clear all;
close all;
disp('==================================================================');

end




