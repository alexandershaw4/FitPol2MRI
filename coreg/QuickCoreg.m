disp('This script performs co-registration WITHOUT optimisation')


[f,p] = uigetfile('/mnt/home/users/megadmin/MRIs/*.mri', 'Give the original MRI');
mrifilename = fullfile(p,f);
[f,p] = uigetfile([p,'/*.mat'], 'Give a transormation matrix');
transfilename = fullfile(p,f);
currentdir = pwd; cd ~ ; homedir = pwd; cd(currentdir);
[f,p] = uigetfile([homedir,'/*.hsf'], 'Give the polhemus file');
polfilename = fullfile(p,f);
pathname = [p];
%mrifilename='/mnt/home/users/megadmin/MRIs/VanessaParson/Vanessa.mri*'
%pathname='/mnt/scratch2/vanessapolhemus/';
%polfilename='vanessa.hsf'
%transfilename='/mnt/home/users/megadmin/MRIs/VanessaParson/Vanessa_opt_xfm.mat'



polfilepath=pathname;

mriinfo=rdmrihead(mrifilename);

root_polname=polfilename(1:findstr(polfilename,'.hsf')-1);
[ctfelcpoints]=Pol2Ctf([polfilename],'','',transfilename,pathname)


% convert fiduciary points one by one
if max(mriinfo.VoxSize)~=min(mriinfo.VoxSize),
   warning('MRI is NOT ISOTROPIC, TRANSFORMATION MAY NOT WORK')
   end;

for f=1:3,
  Fid(f,:)=ctfhead2mri(ctfelcpoints(f,:),mriinfo.T,mriinfo.VoxSize(1));
  end; % for f 

%% write the new fid points  
fidfilename=['_man_xfm','.mat'];
[p,f]=fileparts(polfilename);
[fidfilename, pathname] = uiputfile([p '.fid'], 'Write the new fiduciary points file');

wtCtfFid([pathname fidfilename],Fid);






