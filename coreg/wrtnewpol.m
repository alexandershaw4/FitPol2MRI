function wrtnewpol(filename, points, coilpos);

%% function wrtnewpol(filename, points, coilpos);
%% writes new style polhemus file. the coordinates should be given in cm
%% coilpos contains rows with the nasion, left and right coil positions in cm

fid=fopen(filename,'wt');
Npoints=size(points,1);
fprintf(fid,'%d\n',Npoints);

if fid==-1,
 	error(sprintf('Failed to open new headshape file %s',filename));
end;
for i=1:Npoints,
	fprintf(fid,'%d\t%3.6f\t%3.6f\t%3.6f\n',i,points(i,1),points(i,2),points(i,3));
end; % for i

fprintf(fid,'%s\t%3.6f\t%3.6f\t%3.6f\n','nasion',coilpos(1,1),coilpos(1,2),coilpos(1,3));	
fprintf(fid,'%s\t%3.6f\t%3.6f\t%3.6f\n','left',coilpos(2,1),coilpos(2,2),coilpos(2,3));	
fprintf(fid,'%s\t%3.6f\t%3.6f\t%3.6f\n','right',coilpos(3,1),coilpos(3,2),coilpos(3,3));	


fclose(fid);

