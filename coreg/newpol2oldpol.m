function [hsffilename, elcfilename] = newpol2oldpol(pathname, fname);

% function [hsffilename, elcfilename] = newpol2oldpol(pathname, fname);
%
% converts a new format Polhemus file into an old format hsf and elc file
%
%
% AH: 20Sept 2005: Swap left coil and nasion to ensure compatibility with old polhemus system

if isempty(fname) | isempty(pathname)
  [fname, pathname] = uigetfile([pathname '*.pos'], 'Give the (NEW format) polhemus headshape file');
end
[junk, name, junk] = fileparts(fname);

polfilename = fullfile(pathname, fname);
hsffilename = fullfile(pathname, [name, '.hsf']);
elcfilename = fullfile(pathname, [name, '.elc']);


% Read the new style pol file
[Hx,Hy,Hz, Elcx, Elcy, Elcz] = rdnewpol(polfilename);

% write these points to an old style hsf and elc file
wrthsf(hsffilename, [Hx, Hy, Hz]);


fid=fopen(elcfilename,'wt');
%fprintf(fid,'%3.4f\t%3.4f\t%3.4f\n',Elcx, Elcy, Elcz);
% AH: 20Sept 2005: Swap left coil and nasion to ensure compatibility with old polhemus system
fprintf(fid,'%3.4f\t%3.4f\t%3.4f\n',Elcy, Elcx, Elcz);
fclose(fid);

disp(sprintf('\nRead in %s, and written the polhemus points to: \n %s\n %s\n',polfilename, hsffilename, elcfilename));


