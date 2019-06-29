function []=wtCtfFid(Fidfilename,FidPoints)
%%function []=wtCtfFid(fidfilename,FidPoints)
%% round off and write out a three fiduciary points in CTF format

fid=fopen(Fidfilename,'wt');
for f=1:3,
	fprintf(fid,'%d\t%d\t%d\t\n',round(FidPoints(f,:)));
	end;	
	
fclose(fid);