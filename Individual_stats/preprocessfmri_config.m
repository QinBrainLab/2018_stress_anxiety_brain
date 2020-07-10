%-Configfile for preprovcessfmri.m
%__________________________________________________________________________

%subjectlist=import('subjectlist.txt');
paralist.ServerPath = '/home/qinlab/data';

%-Subject list
paralist.SubjectList = {'11-11-15.1';'11-11-16.1';'11-11-16.3';'11-11-18.1';'11-11-18.2';'11-11-18.3';'11-11-21.1';'11-11-21.2';'11-11-21.3';'11-11-22.1';'11-11-22.2';'11-11-22.3';'11-11-23.1';'11-11-23.2';'11-11-23.3';'11-11-25.1';'11-11-25.2';'11-11-25.3';'11-11-28.1';'11-11-28.2';'11-11-28.3';'11-11-29.1';'11-11-29.2';'11-11-29.3';'11-11-30.1';'11-11-30.2';'11-11-30.3';'11-12-02.1';'11-12-02.2';'11-12-02.3';'11-12-05.1';'11-12-06.2';'11-12-07.1';'11-12-07.2';'11-12-07.3';'11-12-09.1';'11-12-09.2';'11-12-12.1';'11-12-12.2';'11-12-13.1';'11-12-13.2';'11-12-13.3';'11-12-21.2';'11-12-21.3';'11-12-22.1';'11-12-22.2';'11-12-22.3';'11-12-26.1';'11-12-26.2';'11-12-26.3';'11-12-27.1';'11-12-27.2';'11-12-27.3';'11-12-28.1';'11-12-28.2';'11-12-28.3'};

%-Session list
paralist.SessionList = {'nback'};

paralist.InputImgPrefix = 'car';

%-"v" is the 1st version and "o" is the 2nd version of VolRepair pipeline
%-The entire preprocessing to be completed
%-Choose from: 'swar',  'swavr', 'swaor', 'swgcar',  'swgcavr', 'swgcaor'
%-             'swfar', 'swfavr', 'swfaor', 'swgcfar', 'swgcfavr', 'swgcfaor'
paralist.EntirePipeLine = 'swcar'; %'swcar'

%-Additinal subject list for swgc** pipelines due to better SPGR quality,
% one-to-one matched to paralist.SubjectList
paralist.SPGRSubjectList = '';
