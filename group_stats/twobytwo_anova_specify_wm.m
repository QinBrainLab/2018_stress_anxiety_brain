%-----------------------------------------------------------------------
% Job saved on 22-Jul-2015 15:42:40 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function twobytwo_anova_specify_wm(ConfigFile)
fprintf('Configfile: %s\n', ConfigFile);
fprintf('\n');
CurrentDir=pwd;
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

parentdir  = strtrim(paralist.parentdir);
control_sublist = paralist.control_sublist;
stress_sublist = paralist.stress_sublist;
designdir = paralist.designdir;

for subindex=1:length(control_sublist)
    %control_2back_scans{subindex,1}=[parentdir '/control_2back/con_PPI_2back_' control_sublist{subindex} '.img']; %_con_0002.nii
    control_2back_scans{subindex,1}=[parentdir '/la_2back/' control_sublist{subindex} '_con_0002.nii']; %
    %control_0back_scans{subindex,1}=[parentdir '/control_0back/con_PPI_0back_' control_sublist{subindex} '.img'];
    control_0back_scans{subindex,1}=[parentdir '/la_0back/' control_sublist{subindex} '_con_0001.nii'];
end
for subindex=1:length(stress_sublist)
    %stress_2back_scans{subindex,1}=[parentdir '/stress_2back/con_PPI_2back_' stress_sublist{subindex} '.img'];
    stress_2back_scans{subindex,1}=[parentdir '/ha_2back/' stress_sublist{subindex} '_con_0002.nii'];
    %stress_0back_scans{subindex,1}=[parentdir '/stress_0back/con_PPI_0back_' stress_sublist{subindex} '.img'];
    stress_0back_scans{subindex,1}=[parentdir '/ha_0back/' stress_sublist{subindex} '_con_0001.nii'];
    
end

matlabbatch{1}.spm.stats.factorial_design.dir = {designdir};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'anxiety_group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'nback';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;% befor is all wrong i used 1
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = stress_2back_scans;
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                    2];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = stress_0back_scans;
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    1];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = control_2back_scans;
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    2];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = control_0back_scans;
                       
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm_jobman('run',matlabbatch);
end