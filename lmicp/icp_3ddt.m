function D = icp_3ddt(M)

% ICP_3DDT      Compute 3D distance transform from Mask array M
%               ...

% Author: Andrew Fitzgibbon <awf@robots.ox.ac.uk>
% Date: 30 Aug 01
%% MOD GRB NOV 05 to give unique input and output file names
%% MOD gfeb 2015 Gavin Perry to remove dependency on gentempfile()
N = size(M,1);

%%infile = '/tmp/icp_3ddt_in.dat';
tempprefix='icp_3ddt_in';
infile=sprintf('/tmp/%s%d%f.tmp',tempprefix,floor(now),rem(now,1));
tempprefix='icp_3ddt';
outfile=sprintf('/tmp/%s%d%f.tmp',tempprefix,floor(now),rem(now,1));


disp('writing')
f = fopen(infile, 'wb');
fwrite(f, M(:), 'float32');
fclose(f); 

disp('calling')
path=''; %% was ./  %% have now put copy of this file (icp_3ddt) in an executable path
unix(sprintf('%sicp_3ddt %d %s %s ', path, N, infile, outfile));

disp('reading')
f = fopen(outfile, 'rb'); 
D = fread(f, N^3, 'float32'); 
fclose(f); 
D = reshape(D,  N,N,N);

%% clean up
unix(sprintf('rm -f %s',infile));
unix(sprintf('rm -f %s',outfile));
 
