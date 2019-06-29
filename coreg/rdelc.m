function [Hx,Hy,Hz]=rdelc(filename);

%% function [Hx,Hy,Hz]=rdelc(filename);
%% reads electrode (.elc) file coordinates into Hx,y,z (converted to metres).
%% differs from rdhsf.m where there are three lines to ignore


fid=fopen(filename,'rt');

a=fscanf(fid,'%f');
fclose(fid);
Npoints=size(a,1)/3;
x=1:Npoints;
%% convert .hsf values from cm to m
Hx=a(1+(x-1)*3)*1e-2;
Hy=a(2+(x-1)*3)*1e-2;
Hz=a(3+(x-1)*3)*1e-2;

