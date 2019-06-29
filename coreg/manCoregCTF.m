 function []=manCoregCTF(startpath)
%% manual coregistration script for fitting CTF MRI derived headshapes
%% to meglab polhemus headshape files 
%% GRB 22nd March 2000
%% load in a figure (transmri)  with controls that calls various sub routines:
%% translatex,y,z.m, rotatex,y,z.m, updateviews.m and RunAlign.m
%% GRB June 6th 2000
%% change h_mritext to include the full path
%% GRB June 9th 2000: changed order of prompts, added startpath
%% AH, 26 Aug 2005: changed so that new forlmat polhemus files can be used


%%dbstop if error

manxfm

%%manCoregCTF
%% now load in the reference points (points extracted from the mri in CTF software)
[filename, pathname] = uigetfile([startpath filesep '*.erode'], 'Give the mri-eroded headshape file');
mriinfo=rdmrihead([pathname filename]);

[mri_Hx,mri_Hy,mri_Hz]=ReadCtfHsf([pathname,filesep,filename]); hsfpathname=pathname;
%% now create an array in mm
ref=[mri_Hx';mri_Hy';mri_Hz']'.*1000;
%% plot the mri points and tag them
h_mripoints=plot3(ref(:,1),ref(:,2),ref(:,3),'r.');
view([0 0 1]);
set(h_mripoints,'Tag','mripoints');
h_mritext=findobj(gcf,'Tag','mritext');
set(h_mritext,'String',[pathname filename]);
hold on;
rotate3d on
%%
%% load in any start-up transformation file
[filename, pathname] = uigetfile([pathname '*xfm.mat'], 'Give an initial transformation matrix (cancel if none)');
if isstr(filename),
   xfm_filename=[pathname,filesep, filename];
   load(xfm_filename,'R12','T1','T2');
	   else, 
  % start with an identitytransform
  filename='no transform';
  R12=[1 0 0;0 1 0;0 0 1];
  T1=[0 0 0];T2=[0 0 0];
  pathname= hsfpathname;
  end; % if isstr(filename)


% AH, 26 Aug 2005
answer = questdlg('Are the polhemus file in the old or new format?', 'polhemus question', 'old','new','new');
switch answer,
     case 'new',
	   newpol2oldpol(pathname, []);
     case 'old',
        % don't do anything
end; % switch


%% load the polhemus headshape points
[filename, pathname] = uigetfile([pathname '*.hsf'], 'Give the polhemus headshape file');
polfilepath=pathname;
hsf_filename=[pathname,filesep, filename];
[Hx, Hy, Hz]=rdhsf(hsf_filename);
startpoints=[Hx*1000 Hy*1000 Hz*1000];
%% plot the polhemus points and tag them
h_startpoints= plot3(startpoints(:,1),startpoints(:,2),startpoints(:,3),'b.');
set(h_startpoints,'Tag','startpoints');
%% set text box
h_poltext=findobj(gcf,'Tag','poltext');
set(h_poltext,'String',filename);



h_transtext=findobj(gcf,'Tag','transtext');
set(h_transtext,'String',filename);

%% keep a copy of current path hidden in the figure for other routines to use
h_pathtext=findobj(gcf,'Tag','pathtext');
%% pass on the path to the polhemus headshape file 
set(h_pathtext,'String',polfilepath);

%% translate the polhemus points based on this transform
transpoints=do_trans(R12,T1,T2,startpoints);
%%
%% plot the translated polhemus points
hold on;
h_headpoints=plot3(transpoints(:,1), transpoints(:,2),transpoints(:,3),'ro');
set(h_headpoints,'Tag','headpoints');

%% make the original points invisible
set(h_startpoints,'Visible','off');

view([0 0 1])	
updateviews;





