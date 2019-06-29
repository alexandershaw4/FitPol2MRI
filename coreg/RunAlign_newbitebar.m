function  []=RunAlign_newbitebar()
%% Called from a button press in figure transmri (part of manCoregCTF)
%% reads three sets of tagged points from figure 1
%% tags are:
%% startpoints- original, scaled, polhemus points from .hsf file
%% headpoints- manually fitted polhemus points
%% mripoints- points from CTF's MRIViewer program (extract headshape)
%% calculates initial transform (from start to headpoints) and allows you to save this file
%% then calls dmalign2.m which finds an optimal transform
%% allows user to save this transform
%% GRB 22/03/2000
%% Currently uses the directory it was launched from as workspace
%% generates then deletes a number of matfiles within this directory
%% GRB 25/06/2000
%% Start Align without pressing buttons
%% keep error 
%% AH 10/10/2001 modified version of RunAlign; uses the headshape as obtained with the 4th coil procedure, instead of the polhemius system


eval('which RunAlign_newbitebar')
disp('Version 1.0 AH 10/10/2001');

figure(1);
%% read in the names stored in the figure
h_pathtext=findobj(gcf,'Tag','pathtext');
pathname=get(h_pathtext,'String');
polfilepath=pathname;
h_mritext=findobj(gcf,'Tag','mritext');
mriname=get(h_mritext,'String');
%% read in mri info from the mrihead text dump 
mriinfo=rdmrihead(mriname);

h_poltext=findobj(gcf,'Tag','poltext');
polfilename=get(h_poltext,'String');
h_transtext=findobj(gcf,'Tag','transtext');
transfilename=get(h_transtext,'String');

%% read final headpoints from figure 1
%% save headpoints in test1000
h_headpoints=findobj(gcf,'Tag','headpoints');
testx=get(h_headpoints,'XData');
testy=get(h_headpoints,'YData');
testz=get(h_headpoints,'ZData');
test=[testx' testy' testz'];
%%
%% load in original startpoints from figure 1
h_startpoints=findobj(gcf,'Tag','startpoints');
stx=get(h_startpoints,'XData');
sty=get(h_startpoints,'YData');
stz=get(h_startpoints,'ZData');
startpoints=[stx' sty' stz'];

%% get a transform
[R12,T1,T2]=gettrans(startpoints,test);
new=do_trans(R12,T1,T2,startpoints);
plot3(new(:,1),new(:,2),new(:,3),'m.');
%%root_polname=polfilename(1:findstr(polfilename,'.hsf')-1);
%% AH 10/10/2001
root_polname=polfilename(1:findstr(polfilename,'.txt')-1);
transfilename=['_man_xfm','.mat'];
[transfilename, pathname] = uiputfile([pathname root_polname 'man_xfm.mat'], 'write the Manual transformation file');
transfilename=[pathname,transfilename];
save(transfilename,'R12','T1','T2','polfilename','mriname');
%% 
%% read mri points from figure 1
%% save mripoints in ref500
h_mripoints=findobj(gcf,'Tag','mripoints');
refx=get(h_mripoints,'XData');
refy=get(h_mripoints,'YData');
refz=get(h_mripoints,'ZData');
ref=[refx' refy' refz'];

%% need to make these numbers positive for dmalign to work
workdir=pwd
[finalpoints,finalerror]=callalign(test,ref,workdir,[1 1 1])
 

%% new transform goes from the original points to the final, optimized points
[R12,T1,T2]=gettrans(startpoints,finalpoints);
%% write the optimized transform  
transfilename=['_man_xfm','.mat'];
[transfilename, pathname] = uiputfile([pathname root_polname '_opt_xfm.mat'], 'write the optimized transformation file');
transfilename=[pathname transfilename];


save(transfilename,'R12','T1','T2','polfilename','mriname');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now convert to CTF coords
%%[ctfelcpoints]=Pol2Ctf([polfilepath polfilename],'','',transfilename,pathname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now transform the original headcoil locations to the optimised locations
%% and transform the original headcoilheadshape locations to the optimised locations (and write to file)
endpoints = finalpoints; % These are the transformed headshape points





fourthcoil_filename = fullfile(polfilepath, polfilename);
%[junk, badindices, NA, LE, RE] = RdFindCoilsOutput(fourthcoil_filename); % output in cm
%startelcpoints = [mean(NA,1);mean(LE,1);mean(RE,1)]*10; %in mm
% check if the 4th coil positions are given in a mat file or as a txt file
ButtonAnswer=questdlg('Give the type of inputfile (i.e. txt-file containing the output of FindCoils or a mat file containing the headshape points)', ...
                       'File Input Question', 'output of FindCoils','mat file','output of FindCoils ');
switch ButtonAnswer
  case 'output of FindCoils', 
    [fourthcoilpos, badindices, NA, LE, RE] = RdFindCoilsOutput(fourthcoil_filename); % output in cm
    %% do not use all NA, LE, RE, because they are noisy when the 4th coil was close to the dewar! 
    %% ask the user the indices of the points that should be used
    prompt={'Enter the index of the 1st NA point (pre-headshape):','Enter the index of the last NA point (pre-headshape):', ...
            'Enter the index of the 1st NA point (post-headshape):','Enter the index of the last NA point (post-headshape):'};
    def = {'1', '20', '321', '340'}; dlgTitle = 'Input of indices for reference points';
    lineNo = 1;
    answer = inputdlg(prompt,dlgTitle,lineNo,def);
    answer = cell2struct(answer,{'ans1', 'ans2', 'ans3', 'ans4'},1);
    ind1 = str2num((answer.ans1)); ind2 = str2num((answer.ans2)); ind3 = str2num((answer.ans3)); ind4 = str2num((answer.ans4));
    good_indices = [ind1:ind2, ind3:ind4];  
    startelcpoints = [mean(NA(good_indices,:),1);mean(LE(good_indices,:),1);mean(RE(good_indices,:),1)]*10; %in mm

  case 'mat file', 
    file_output = load(fourthcoil_filename);
%    if ~exist(file_output.meanNA)
%	   error('The inputfile should contain a variable named meanNA')
%    else
	   meanNA = file_output.MEAN_NA40; meanLE = file_output.MEAN_LE40; meanRE = file_output.MEAN_RE40; 
%    end
    startelcpoints = [meanNA;meanLE;meanRE]*10; %in mm
end; % switch 








%% transform the nasion, LE and RE locations
endelcpoints=do_trans(R12,T1,T2,startelcpoints);
figure;
hold on;
plot3(startelcpoints(:,1),startelcpoints(:,2),startelcpoints(:,3),'r*');
plot3(startpoints(:,1),startpoints(:,2),startpoints(:,3),'c.');


%% add the transformed coil locations to the headshape data
Fx=[endpoints(:,1);endelcpoints(:,1)];
Fy=[endpoints(:,2);endelcpoints(:,2)];
Fz=[endpoints(:,3);endelcpoints(:,3)];

%% Don't need to this, because the fourtcoil positions are already in the CTF co-ordinate system
%% AH - do it for now, as reading in of the 4th coil positions in MEG coordinates is not working yet, i..e. there is a 2.2 mm offset
[MEG_Fx, MEG_Fy, MEG_Fz,MEG_nasion_pos,MEG_left_preauricular_pos,MEG_right_preauricular_pos]=Bitebar2MEG(Fx, Fy, Fz,endelcpoints(1,:), endelcpoints(2,:), endelcpoints(3,:) );


% Save the headshape points in CTF fileformat
% The headshape points are aleardy in the CTF coordinate system, because they were recorded with the 4th coil method!!! 
[j1,j2,j3]=fileparts(fourthcoil_filename);
root_polname=fullfile(j1,j2);
[filename, pathname] = uiputfile([root_polname '.CTF_hsf'], 'write the MEG headshape points in CTF format');
outfilename=[pathname,filesep,filename];
outfilename2=[pathname,filesep,['fourthcoil_',filename]];
%WriteCtfHsf(outfilename,Fx/1000,Fy/1000,Fz/1000);
WriteCtfHsf(outfilename,MEG_Fx/1000,MEG_Fy/1000,MEG_Fz/1000);

ctfelcpoints=endelcpoints;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


message={'These are the correct CTF MRI (not kmr) co-ordinates (in cm) for the markers:','', ... 
['Nasion : ', num2str(ctfelcpoints(1,:)/10)], ...
['Left preauricular: ', num2str(ctfelcpoints(2,:)/10)], ...
['Right preauricular: ', num2str(ctfelcpoints(3,:)/10)]};
mh=msgbox(message,' ','warn');

%% convert fiduciary points one by one
if max(mriinfo.VoxSize)~=min(mriinfo.VoxSize),
   warning('MRI is NOT ISOTROPIC, TRANSFORMATION MAY NOT WORK')
   end;

for f=1:3,
  Fid(f,:)=ctfhead2mri(ctfelcpoints(f,:),mriinfo.T,mriinfo.VoxSize(1));
  end; % for f 

% write the new fid points 
[fidfilename, pathname] = uiputfile([root_polname,'.fid'], 'Write the new fiduciary points file');
wtCtfFid([pathname fidfilename],Fid);










