function updateviews()

%% copy from figure 1 to other view windows
figure(1);
h_headpoints=findobj(gcf,'Tag','headpoints');
h_mripoints=findobj(gcf,'Tag','mripoints');
figure(2); clf;
h2=copyobj(h_headpoints,gca);
h2=copyobj(h_mripoints,gca); 
view([1,0,0]);
figure(3); clf;
h3=copyobj(h_headpoints,gca);
h3=copyobj(h_mripoints,gca); 
view([0,1,0]);
