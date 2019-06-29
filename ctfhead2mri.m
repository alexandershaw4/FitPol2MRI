function [mrip]=ctfhead2mri(p,ctfTrans,voxsize)

%% given a point in a ctf head coordinate system in mm ,the ctf transformation
%% matrix, plus a voxel size in mm (get the last two from CTF command mrihead). 
%% returns the mri coordinates of this point

% add an extra column to p 
extracol=ones(size(p,1),1).*voxsize;
newp=[p extracol];


%% do transform, get scaled 4 element result

mripscaled=newp*ctfTrans;

%% normalize the returned coordinates
if max(mripscaled(:,4))~=min(mripscaled(:,4)),
			     error('Something wrong');
			     end;
mrip=mripscaled./mripscaled(1,4);
mrip=mrip(:,1:3);
