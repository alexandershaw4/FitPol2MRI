function  []=RunAlign()
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
%%
%% AH: 19June 2002; changed so can use arbitrary workingdir
%% GRB: Dec 2003: Allow noalign option in filename
eval('which RunAlign')
disp('Version 1.0 GRB 22/03/2000');

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
root_polname=polfilename(1:findstr(polfilename,'.hsf')-1);
transfilename=['_man_xfm','.mat'];
[transfilename, pathname] = uiputfile([pathname root_polname 'man_xfm.mat'], 'write the Manual transformation file (use noalign i name if you want to skip optimization)');
transfilename=[pathname,transfilename];
save(transfilename,'R12','T1','T2','polfilename','mriname');

if isempty(findstr(transfilename,'noalign')), %% addition DEC 2003 GRB to allow you to skip optimization. Corrected Jan 2004 (AH)
  %% 
  %% read mri points from figure 1
  %% save mripoints in ref500
  h_mripoints=findobj(gcf,'Tag','mripoints');
  refx=get(h_mripoints,'XData');
  refy=get(h_mripoints,'YData');
  refz=get(h_mripoints,'ZData');
  ref=[refx' refy' refz'];

  %% need to make these numbers positive for dmalign to work

  %% AH: 19June 2002; changed so can use arbitrary workingdir
  %workdir=pwd
  currentdir = pwd;
  %% AH: 18 Jan 2005: changed so that the tmp folder on the LOCAL machine is used
  %% cd ~
  cd /tmp
  [junk,user]=unix('whoami'); user = sscanf(deblank(user),'%s');
  tmp_dirname = sprintf('%s%s%6.0f','coregister_workingdir_', user, 10^6*rem(now,1));
%  if ~exist('coregister_workingdir', 'dir')
%    status =  mkdir('coregister_workingdir');
%  end
  if ~exist(tmp_dirname, 'dir')
    status =  mkdir(tmp_dirname);
  end
  if ~status
    error('RunAlign: Cannot create working directory');
  end
%  workdir = fullfile(pwd, 'coregister_workingdir');
  workdir = fullfile(pwd, tmp_dirname);
  d = dir(fullfile(workdir, '*.mat')); 
  if size(d,1) > 0
    error(sprintf('\n %s already contains files that are needed for Coregister; delete these files first!', workdir));
  end
  disp(sprintf('\nUsing %s as working directory for Align', workdir))
  [finalpoints,finalerror] = callalign(test,ref,workdir,[1 1 1]);
  cd(currentdir) 

   %% new transform goes from the original points to the final, optimized points
  [R12,T1,T2]=gettrans(startpoints,finalpoints);
   %% write the optimized transform  
  transfilename=['_man_xfm','.mat'];
  [transfilename, pathname] = uiputfile([pathname root_polname '_opt_xfm.mat'], 'write the optimized transformation file');
  transfilename=[pathname transfilename];
  save(transfilename,'R12','T1','T2','polfilename','mriname');
  else,
  disp('********* NOT USING OPTIMIZATION ****************');
  disp('Type: return')
  keyboard
end; % if NOALIGN

%% Now convert to CTF coords
[ctfelcpoints]=Pol2Ctf([polfilepath polfilename],'','',transfilename,pathname);

message={'These are the correct CTF MRI (not kmr) co-ordinates (in cm) for the markers:','', ... 
['Nasion : ', num2str(ctfelcpoints(1,:)/10)], ...
['Left preauricular: ', num2str(ctfelcpoints(2,:)/10)], ...
['Right preauricular: ', num2str(ctfelcpoints(3,:)/10)]};
mh=msgbox(message,' ','warn');

%% convert fiduciary points one by one
%%if max(mriinfo.VoxSize)~=min(mriinfo.VoxSize),
%%   disp(sprintf('Voxel size: %7.5f  %7.5f  %7.5f', mriinfo.VoxSize))
%%   error('MRI is NOT ISOTROPIC, TRANSFORMATION MAY NOT WORK')
%%   end;

%% convert fiduciary points one by one
if max(mriinfo.VoxSize)~=min(mriinfo.VoxSize),
  if ( max(mriinfo.VoxSize)-min(mriinfo.VoxSize) ) < 0.0024
     disp(sprintf('Voxel size: %7.5f  %7.5f  %7.5f', mriinfo.VoxSize))
     disp('MRI is NOT ISOTROPIC, but the slight differences in dimensions are ignored')
  else
     disp(sprintf('Voxel size: %7.5f  %7.5f  %7.5f', mriinfo.VoxSize))
     error('MRI is NOT ISOTROPIC, TRANSFORMATION MAY NOT WORK')
  end;
end;

for f=1:3,
  Fid(f,:)=ctfhead2mri(ctfelcpoints(f,:),mriinfo.T,mriinfo.VoxSize(1));
  end; % for f 

%% write the new fid points  
fidfilename=['_man_xfm','.mat'];
[fidfilename, pathname] = uiputfile([pathname root_polname '.fid'], 'Write the new fiduciary points file');

wtCtfFid([pathname fidfilename],Fid);










