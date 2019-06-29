function [Hx,Hy,Hz, nasion_pos, left_pos, right_pos] = rdxen(filename);

%% function [Hx,Hy,Hz, Elcx, Elcy, Elcz]=rdxen(filename);
%% reads coordinates from the xensor head digitiser to Hx,y,z.
%% as well as the 3 reference points
%% values are returne in metres
%% Gavin Perry 2015

format long

nasion_pos = [0 0 0];
left_pos = [0 0 0];
right_pos = [0 0 0];
Npoints = 0;
data = 0;

fid=fopen(filename,'rt');
while (~Npoints | ~any(nasion_pos) | ~any(left_pos) | ~any(right_pos) | ~any(data))
% keep going until all data is read
    LINE = fgetl (fid);
    b = sscanf (LINE, '%s',1);
    switch (b)
    case 'NASION'
        if (~any(nasion_pos)) %ignore NASION when it appears later
            nasion_pos = sscanf (LINE, '%*s %*s %f %f %f');
        end;
    case 'LEFTEAR'
        left_pos = sscanf (LINE, '%*s %*s %f %f %f');
    case 'RIGHTEAR:'
        right_pos = sscanf (LINE, '%*s %f %f %f');
    case 'NumberHeadShapePoints='
        Npoints = sscanf (LINE, '%*s %i');
        headpoints = zeros (Npoints, 3);
    case 'HeadShapePoints'
        if Npoints > 0
            data = fscanf(fid,'%f',Npoints * 3);
            headpoints = reshape (data, 3, Npoints)';
        else
            error ('Number of head points not found in file');
        end;
    end;
end;

fclose(fid);

Hx = headpoints (:,1);
Hy = headpoints (:,2);
Hz = headpoints (:,3);
nasion_pos = nasion_pos';
left_pos = left_pos';
right_pos = right_pos';


