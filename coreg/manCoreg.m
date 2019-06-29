path(path,'/mnt/home/users/megadmin/mfiles/coreg');

%% load in the figure with the controls
transmri
%%
%% now load in the reference points
% LOAD AND SCALE MRI POINTS (ref)
% Load in the headpoints extracted from the mri
[filename, pathname] = uigetfile('/mnt/home/users/gareth/matlab/dmalign/refunscaled500.mat', 'Give the headpoints file');
% scale the mri headpoints
load([pathname,filesep,filename]) 

%Apply the scaling as known from the MRI scan
prompt={'PxScaling [mm]:','PyScaling [mm]:','SliceScaling [mm]:'};
def={'1.1','1.1','1.9'};
dlgTitle='Scaling as known from the MRI scan';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
PxScaling=str2num(char(answer(1)));
PyScaling=str2num(char(answer(2)));
SliceScaling=str2num(char(answer(3)));
ref(:,1)=ref(:,1).*PxScaling;
ref(:,2)=ref(:,2).*PyScaling;
ref(:,3)=ref(:,3).*SliceScaling;

%%
%% plot the mri points
h_mripoints=plot3(ref(:,1),ref(:,2),ref(:,3),'c.');
set(h_mripoints,'Tag','mripoints');
rotate3d on
%%
%% load the headshape points
[filename, pathname] = uigetfile('*.hsf', 'Give the headshapefile');
hsf_filename=[pathname,filesep, filename];
[Hx, Hy, Hz]=rdhsf(hsf_filename);
startpoints=[Hx*1000 Hy*1000 Hz*1000];
save('hsf1000','startpoints','hsf_filename');

[filename, pathname] = uigetfile('*xfm.mat', 'Give an initial transformation matrix');
xfm_filename=[pathname,filesep, filename];
load(xfm_filename,'R12','T1','T2');
startpoints=[Hx*1000 Hy*1000 Hz*1000];
transpoints=do_trans(R12,T1,T2,startpoints);
 %% origin at zero
%transpoints=[startpoints(:,1)-mean(startpoints(:,1)) startpoints(:,2)-mean(startpoints(:,2)) startpoints(:,3)-mean(startpoints(:,3))];
  %% origin at centre of refpoints
%transpoints=[transpoints(:,1)+mean(ref(:,1)) transpoints(:,2)+mean(ref(:,2))  transpoints(:,3)+mean(ref(:,3))]  ;
%%
%% plot the head shape points
hold on;
h_headpoints=plot3(transpoints(:,1), transpoints(:,2),transpoints(:,3),'go');
set(h_headpoints,'Tag','headpoints');
	






