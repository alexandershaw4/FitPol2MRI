function  []=Newbitebar2MRI()

% Write out the hsf points and fid points, based on the file obtained with the 4th coil method
% 


[p,f] =uigetfile('*.txt','Fouthcoil file');
fourthcoil_filename=fullfile(p,f);
[fourthcoilpos, badindices, NA, LE, RE] = RdFindCoilsOutput(fourthcoil_filename); % output in cm
startelcpoints = [mean(NA,1);mean(LE,1);mean(RE,1)]*10; %in mm


% Save the headshape points in CTF fileformat
% The headshape points are aleardy in the CTF coordinate system, because they were recorded with the 4th coil method!!! 
[j1,j2,j3]=fileparts(fourthcoil_filename);
root_polname=fullfile(j1,j2);
[filename, pathname] = uiputfile([root_polname '.CTF_hsf'], 'write the MEG headshape points in CTF format');
outfilename=[pathname,filesep,filename];
%WriteCtfHsf(outfilename,MEG_Fx/1000,MEG_Fy/1000,MEG_Fz/1000);
WriteCtfHsf(outfilename,Fx/1000,Fy/1000,Fz/1000);
ctfelcpoints=endelcpoints;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[p,f] =uigetfile('*.mri','Input mri');
mriname=fullfile(p,f);
mriinfo=rdmrihead(mriname);

%% convert fiduciary points one by one
if max(mriinfo.VoxSize)~=min(mriinfo.VoxSize),
   warning('MRI is NOT ISOTROPIC, TRANSFORMATION MAY NOT WORK')
   end;

for f=1:3,
  Fid(f,:)=ctfhead2mri(startelcpoints(f,:),mriinfo.T,mriinfo.VoxSize(1));
  end; % for f 

%% write the new fid points  
[fidfilename, pathname] = uiputfile('*.fid'], 'Write the new fiduciary points file');
wtCtfFid([pathname fidfilename],Fid);










