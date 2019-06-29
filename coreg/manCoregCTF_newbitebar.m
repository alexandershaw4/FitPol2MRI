 function []=manCoregCTF_newbitebar(startpath)
%% manual coregistration script for fitting CTF MRI derived headshapes
%% to meglab polhemus headshape files 
%% GRB 22nd March 2000
%% load in a figure (transmri)  with controls that calls various sub routines:
%% translatex,y,z.m, rotatex,y,z.m, updateviews.m and RunAlign.m
%% GRB June 6th 2000
%% change h_mritext to include the full path
%% GRB June 9th 2000
%% changed order of prompts, added startpath
%%
%% AH 10/10/2001 modified version of manCoregCTF; reads in the headshape as obtained with the 4th coil procedure, 
%% instead of the polhemius system
%% AH 13 Feb 2002: remove outliers from the 4th coil procedure, using Remove_headshape_outliers


dbstop if error
manxfm_newbitebar

UseBadIndices = 1;

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load the polhemus headshape points
%%[filename, pathname] = uigetfile([pathname '*.hsf'], 'Give the polhemus headshape file');
%%polfilepath=pathname;
%%hsf_filename=[pathname,filesep, filename];
%%[Hx, Hy, Hz]=rdhsf(hsf_filename);
%%startpoints=[Hx*1000 Hy*1000 Hz*1000];
%% plot the polhemus points and tag them
%%h_startpoints= plot3(startpoints(:,1),startpoints(:,2),startpoints(:,3),'b.');
%%set(h_startpoints,'Tag','startpoints');
%% set text box
%%h_poltext=findobj(gcf,'Tag','poltext');
%%set(h_poltext,'String',filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load the headshape points as obtained with the 4th coil method
% check if the 4th coil positions are given in a mat file or as a txt file
ButtonAnswer=questdlg('Give the type of inputfile (i.e. txt-file containing the output of FindCoils or a mat file containing the headshape points)', ...
                       'File Input Question', 'output of FindCoils','mat file','output of FindCoils ');
switch ButtonAnswer
  case 'output of FindCoils', 
    [filename, pathname] = uigetfile('*.txt','Give the file that contains the 4th coil locations?');
    polfilepath=pathname;
    hsf_filename=fullfile(pathname, filename);
    [fourthcoilpos, badindices, NA, LE, RE] = RdFindCoilsOutput(hsf_filename);
    % read in the fourth coil positions, ALREADY in the nasion-ear co-ordinate system
    %[junk, badindices, NA, LE, RE, fourthcoilpos] = RdFindCoilsOutput(hsf_filename);
    %if UseBadIndices
    %  startpoints = fourthcoilpos*10; %convert to mm
    %  disp('Using all headshape points (including points with calibration warnings)')
    %else
    %  good_indices = setdiff([1:size(fourthcoilpos,1)], badindices); 
    %  startpoints = fourthcoilpos(good_indices, :)*10; % convert to mm
    %  disp(['Removed ',num2str(length(badindices)),' headshape points out of ',num2str(size(fourthcoilpos,1)),' (= ',num2str((length(badindices)/size(fourthcoilpos,1))*100),'%), because of calibration warnings'])
    %end    
    % ask the user the indices of the points that should be used
    prompt={'Enter the index of the 1st headshape point:','Enter the index of the last headshape point:'};
    def = {'1', num2str(size(fourthcoilpos,1))}; dlgTitle = 'Input of indices for headshape points';
    lineNo = 1;
    answer = inputdlg(prompt,dlgTitle,lineNo,def);
    answer = cell2struct(answer,{'ans1','ans2'},1);
    ind1 = str2num((answer.ans1)); ind2 = str2num((answer.ans2));
    good_indices = [ind1:ind2];  
    startpoints = fourthcoilpos(good_indices, :)*10; % convert to mm
    startpoints = Remove_headshape_outliers(startpoints);
   case 'mat file', 
    [filename, pathname] = uigetfile('*.mat','Give the file that contains the headshape locations [in cm]?');
    polfilepath=pathname;
    hsf_filename=fullfile(pathname, filename);
    file_output = load(hsf_filename);
%    if ~exist(file_output.fourthcoilpos)
%	   error('The inputfile should contain a variable named fourthcoilpos')
%    else
           % convert to mm
	   startpoints = file_output.fourthcoilpos_mid*10;
%    end
end; % switch 



%% plot the headshape points and tag them
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





