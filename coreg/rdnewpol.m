function [Hx,Hy,Hz, Elcx, Elcy, Elcz] = rdnewpol(filename);

%% function [Hx,Hy,Hz, Elcx, Elcy, Elcz]=rdnewpol(filename);
%% reads coordinates from the new format polhemus file into Hx,y,z.
%% as wel as the 3 reference points

format long

fid=fopen(filename,'rt');
Npoints = fscanf(fid,'%f',1);

a=fscanf(fid,'%f', [4, Npoints])';

LINE = fgetl(fid);
LINE1 = fgetl(fid);
LINE2 = fgetl(fid);
LINE3 = fgetl(fid);

fclose(fid);

Hx=a(:,2);
Hy=a(:,3);
Hz=a(:,4);

b=sscanf(LINE1, '%s',1);tmp=LINE1(length(b)+1:end);Elcx=sscanf(tmp, '%f',3)';
b=sscanf(LINE2, '%s',1);tmp=LINE2(length(b)+1:end);Elcy=sscanf(tmp, '%f',3)';
b=sscanf(LINE3, '%s',1);tmp=LINE3(length(b)+1:end);Elcz=sscanf(tmp, '%f',3)';
