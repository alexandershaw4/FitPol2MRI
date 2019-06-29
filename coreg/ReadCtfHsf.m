function [Hx,Hy,Hz]=ReadCtfHsf(filename);

%% function [Hx,Hy,Hz]=ReadCtfHsf(filename);
%% reads CTF HeadShape (.hsf) file coordinates into Hx,y,z (converted to metres).
%% assumes a single dud line at start of file
%% differs from rdelc.m where there are no lines to ignore


fid=fopen(filename,'rt');
LINE = fgetl(fid);
%LINE = fgetl(fid);
%LINE = fgetl(fid);

a=fscanf(fid,'%f');
fclose(fid);
Npoints=size(a,1)/3;
x=1:Npoints;
%% convert .hsf values from cm to m
Hx=a(1+(x-1)*3)*1e-2;
Hy=a(2+(x-1)*3)*1e-2;
Hz=a(3+(x-1)*3)*1e-2;

