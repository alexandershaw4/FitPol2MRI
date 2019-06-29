function [total_squared_distance] = sphere_fit_costfun(fit_par, data_points);

% [total_squared_distance] = sphere_fit_costfun(fit_par, data_points);
% r_sphere = fit_par(1);origin_sphere = fit_par(2:4);
%
% costfunction for fiting a sphere through a set of datapoints
% minimises the squared distance to the sphere surface
% all positions in mm
%% Mod GRB Nov 2005 to stop plotting


r_sphere = fit_par(1);
origin_sphere = fit_par(2:4);

% get all points with respect to the sphere origin
new_data_points = data_points - repmat(origin_sphere, size(data_points,1),1);

dist_datapoints = [];
for i=1:size(data_points,1);
  dist_datapoints(i) = sqrt(dot(new_data_points(i,:), new_data_points(i,:)));
end

surf_dist = dist_datapoints-r_sphere; 
surf_dist_squared = surf_dist.^2;
total_squared_distance = sum(surf_dist_squared);


% display the fitting steps

%if PLOT_ON,

%newx = r_sphere * x; newy = r_sphere * y; newz = r_sphere * z; 
%newx = newx + origin_sphere(1) * ones(size(newx));
%newy = newy + origin_sphere(2) * ones(size(newy));
%newz = newz + origin_sphere(3) * ones(size(newz));


%[x,y,z]= sphere(50);
%handle = surf(newx, newy, newz); set(handle,'facecolor',[0.2 0.2 0.2]); axis equal; alpha(0.2); view(-60,10)
%hold on
%phandle = plot3(data_points(:,1), data_points(:,2), data_points(:,3), 'r*');
%hold off
%drawnow

%end; % PLOT
