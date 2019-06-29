function  []=runScaleAlign()
%% GRB 26/06/2000
%% modified version of RunAlign to do scaling of MRI also.
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
limitfactor=3;
startscale=[1.2 1.2 1.0];
[finalscale,finalerror,starterror]=optscale(startscale,limitfactor,test,ref,workdir)
disp('RESULTS- press any key to continue')
finalscale
finalerror
starterror
pause;
 
%minref=min(ref);
%mintest=min(test);
%%
%posref=[ref(:,1)-minref(1) ref(:,2)-minref(2) ref(:,3)-minref(3)];
%postest=[test(:,1)-minref(1) test(:,2)-minref(2) test(:,3)-minref(3)];
%%
%test=postest;
%ref=posref;
%% save files for align to use
%% 
%workdir=pwd
%save('ref501','ref');
%save('test1001','test')
%% remove the distance map


%%
%% align removes a lot of variables
%    save workspace01;
%    clear
%    align_fig_handle=figure(4);clf;
   %% dmalign2
%    dmalign2('initialize');
 %   dmalign2('start')
 %   dmalign2('align')
  %  dmalign2('initialize');
  %  close; clear;clear global;
  %  load workspace01;
 %% remove .mat files
  %  load error1001.mat err %% load back in error- want to keep this
  %  unix(sprintf('rm -f %s/ref501.mat',workdir));
  %  unix(sprintf('rm -f %s/test1001.mat',workdir));
  %  unix(sprintf('rm -f %s/error1001.mat',workdir));
  %  unix(sprintf('rm -f %s/param1001.mat',workdir));
  %  unix(sprintf('rm -f %s/distancemap501',workdir));
  %  unix(sprintf('rm -f %s/workspace01.mat',workdir));
    % get the fitresult
  %  figure;
  %  handle=findobj(gcf,'Tag','FitResult');
  %  result_testx=get(handle,'XData');
  %  result_testy=get(handle,'YData');
  %  result_testz=get(handle,'ZData');
  %  finalpoints=[result_testx' result_testy' result_testz'];
    %% now put numbers back to include negative values
  %  disp('Errors are ');
  %  err(size(err,1)-1,:)
%% these are the optimized headshape points
% finalpoints=[finalpoints(:,1)+minref(1) finalpoints(:,2)+minref(2) finalpoints(:,3)+minref(3)];

%% new transform goes from the original points to the final, optimized points
[R12,T1,T2]=gettrans(startpoints,finalpoints);
%% write the optimized transform  
transfilename=['_man_xfm','.mat'];
[transfilename, pathname] = uiputfile([pathname root_polname '_opt_xfm.mat'], 'write the optimized transformation file');
transfilename=[pathname transfilename];


save(transfilename,'R12','T1','T2','polfilename','mriname');


%% Now convert to CTF coords
[ctfelcpoints]=Pol2Ctf([polfilepath polfilename],'','',transfilename,pathname)

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

%% write the new fid points  
fidfilename=['_man_xfm','.mat'];
[fidfilename, pathname] = uiputfile([pathname root_polname '.fid'], 'Write the new fiduciary points file');

wtCtfFid([pathname fidfilename],Fid);










