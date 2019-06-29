function good_positions = Remove_headshape_outliers(positions);
% function good_positions = Remove_headshape_outliers(positions);
%
% Read in the positions (assume these positions represent the ouitline of the head)
% Find outliers and remove the outliers from the positions 

if size(positions,2) >  size(positions,1)
     error('input dimensions are wrong') 
end

% compute the mean location
mean_pos = mean(positions, 1);

% find the distance from the mean for each point
dist = [];
for i=1:size(positions,1)
     dist(i) = sqrt(dot(positions(i,:)-mean_pos, positions(i,:)-mean_pos));
end; % for

fig1 = figure(1001);
p1 = plot3(positions(:,1), positions(:,2), positions(:,3),'g.');
figpos=get(gcf, 'Position');set(gcf,'Position', [figpos(1:2)-100 figpos(3:4)]);
set(gcf,'Name', 'All headpoints')
hold on
badindices = find(dist > 1.5 * mean(dist));
nr_bad = length(badindices);
badindices = find(dist > (2 - 0.8 * nr_bad/size(positions,1)) * mean(dist));
nr_bad = length(badindices);
p2 = plot3(positions(badindices,1), positions(badindices,2), positions(badindices,3),'r*');
set(gcf,'Name', 'All headpoints')
legend([p1,p2],'good','bad',0)


fig2 = figure(1002); set(gcf,'Position', [figpos(1:2)+600 figpos(3:4)]);
hold on
set(gcf,'Visible','off')
set(gcf,'Name', 'Good points, click on points to remove them');
goodindices = setdiff(1:size(positions,1), badindices);
for i=1:size(positions(goodindices,:),1)
     p = plot3(positions(goodindices(i),1), positions(goodindices(i),2), positions(goodindices(i),3),'g*');
     set(p,'UserData', i); 
     set(p,'ButtonDownFcn', sprintf('set(findobj(gcf,''Userdata'', %d), ''Visible'',''off'');', i) );
     %drawnow
end; % for
set(gcf,'Visible','on')

msgh = msgbox('Click OK when all outliers are removed');
waitfor(msgh)

disp('Removing the outliers that you selected')
handles = findobj(gcf,'Visible','off');
newbadind = [];
for i=1:length(handles)
     newbadind(i) = goodindices(get(handles(i),'UserData'));
end
goodindices = setdiff(goodindices, newbadind);
good_positions = positions(goodindices,:);
fig3 = figure(1003);
plot3(good_positions(:,1), good_positions(:,2), good_positions(:,3),'bo');
set(gcf,'Name', 'Points used for Coregistration');
set(gcf,'Position', [figpos(1:2)-600 figpos(3:4)]);


pause(10)
close(fig1);close(fig2);close(fig3);




