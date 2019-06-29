function []=WriteCtfHsf(filename,Hx,Hy,Hz)
%function []=WriteCtfHsf(filename,Hx,Hy,Hz)
% writes a CTF format headshape file given Hx,Hy,Hz in meters

% convert to cm
Hx=Hx.*100;
Hy=Hy.*100;
Hz=Hz.*100;

fid=fopen(filename,'wt');
Npoints=size(Hx,1);
fprintf(fid,'%d\n',Npoints);
if fid==-1,
 	error(sprintf('Failed to open new headshape file %s',filename));
 	end;
for i=1:Npoints,
	fprintf(fid,'%3.4f\t%3.4f\t%3.4f\n',Hx(i),Hy(i),Hz(i));
	end; % for i
	
fclose(fid);
