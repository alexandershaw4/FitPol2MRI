function [Hx,Hy,Hz]=rdlocf(filename);

% Read the files that are the output of the Polhemius program when
% coil positions are defined with respect to the bitebar


fid=fopen(filename,'rt');
a=fscanf(fid,'%f');
Npoints=size(a,1)/3;
a=reshape(a,3,Npoints)';
fclose(fid);
x=1:Npoints;
%% convert .hsf values from cm to m
%Hx=a(1+(x-1)*3)*1e-2;
%Hy=a(2+(x-1)*3)*1e-2;
%Hz=a(3+(x-1)*3)*1e-2;
% convert .hsf values from cm to mm
Hx=a(:,1)*10;
Hy=a(:,2)*10;
Hz=a(:,3)*10;
