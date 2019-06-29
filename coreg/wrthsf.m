function wrthsf(filename, points);

%% function wrthsf(filename, points)
%% writes HeadShape (.hsf) file coordinates, the coordinates should be given in meters
%% writes three dud lines at start of file


fid=fopen(filename,'wt');
Npoints=size(points,1);
fprintf(fid,'%s\n','junk');
fprintf(fid,'%s\n','junk');
fprintf(fid,'%s\n','junk');
if fid==-1,
 	error(sprintf('Failed to open new headshape file %s',filename));
end;
for i=1:Npoints,
	fprintf(fid,'%3.6f\t%3.6f\t%3.6f\n',points(i,1),points(i,2),points(i,3));
end; % for i
	

fclose(fid);

