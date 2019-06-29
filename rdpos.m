function [Hx,Hy,Hz, nasion_pos, left_pos, right_pos] = rdpos(filename);

%% function [Hx,Hy,Hz, Elcx, Elcy, Elcz]=rdxen(filename);
%% reads coordinates from the Polhemus head digitiser to Hx,y,z.
%% as well as the 3 reference points
%% values are returne in metres
%% Gavin Perry 2018

fid=fopen(filename,'rt');
if (fid == -1)
    error ('Unable to open %s', filename);
end;
Npoints = fscanf (fid,'%i');
lines_read = 0;
count = 0;

while (~feof (fid))
% keep going until all data is read
    LINE = fgetl (fid);
    lines_read = lines_read + 1;
    b = sscanf (LINE, '%s',1);
    switch (b)
    case 'HPI-N'
        nasion_pos = sscanf (LINE, '%*s %f %f %f');
    case 'HPI-L'
        left_pos = sscanf (LINE, '%*s %f %f %f');
    case 'HPI-R'
        right_pos = sscanf (LINE, '%*s %f %f %f');
    case 'EXTRA'
        count = count + 1;
        headpoints (count, :) = sscanf (LINE, '%*s %f %f %f');
    end;
end;

fclose(fid);

if (~exist ('nasion_pos','var'))
    error ('Nasion coil position not found!');
end

if (~exist ('left_pos','var'))
    error ('Left coil position not found!');
end

if ((~exist ('right_pos','var')))
    error ('Right coil position not found!');
end;

if (lines_read < Npoints)
    warning ('Less data in the .pos file than expected. Will try to continue, but results may not be accurate.');
end;

if (lines_read > Npoints)
    warning ('More data in the .pos file than expected. Will try to continue, but results may not be accurate.');
end;

Hx = headpoints (:,1) / 100;
Hy = headpoints (:,2) / 100;
Hz = headpoints (:,3) / 100;
nasion_pos = nasion_pos' / 100;
left_pos = left_pos' / 100;
right_pos = right_pos' / 100;


