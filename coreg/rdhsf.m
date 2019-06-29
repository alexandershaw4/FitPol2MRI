function [Hx,Hy,Hz]=rdhsf(filename);

%% function [Hx,Hy,Hz]=rdHsf(filename);
%% reads HeadShape (.hsf) file coordinates into Hx,y,z (converted to metres).
%% assume three dud lines at start of file
%% differs from rdelc.m where there are no lines to ignore


fid=fopen(filename,'rt');
LINE = fgetl(fid);
LINE = fgetl(fid);
LINE = fgetl(fid);

a=fscanf(fid,'%f');
fclose(fid);
Npoints=size(a,1)/3;
x=1:Npoints;
%% convert .hsf values from cm to m
Hx=a(1+(x-1)*3)*1e-2;
Hy=a(2+(x-1)*3)*1e-2;
Hz=a(3+(x-1)*3)*1e-2;

