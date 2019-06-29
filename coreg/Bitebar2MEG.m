function [Hx, Hy, Hz,MEG_nasion_pos,MEG_left_preauricular_pos,MEG_right_preauricular_pos ]=Bitebar2MEG(Hx, Hy, Hz, nasion_pos, left_preauricular_pos, right_preauricular_pos );

% A new co-ordinate system is defined by the  nasion, left_preauricular and right_preauricular,
% in the same way as CTF does it: origin midway between left and right.
% x-axis through origin and nasion. Y-axis through left and right, in direction of left 
% y-axis rotated towards or away from x-axis in otder to get perpendicular axis.
% z-axis normal to xy-plane.
%
% The output points are defined in the new co=ordinate system. 

% transform the points from bitebar co-ordinate system so that the origin of the 
% bitebar system and the MEG co-ordinate system are the same 
origin=[left_preauricular_pos + right_preauricular_pos]/2;
nasion_pos=nasion_pos-origin;
left_preauricular_pos=left_preauricular_pos-origin;
right_preauricular_pos=right_preauricular_pos-origin;
for i=1:length(Hx)
  tmp=[Hx(i) Hy(i) Hz(i)]-origin;
  Hx(i)=tmp(1);Hy(i)=tmp(2);Hz(i)=tmp(3);
end
origin=[left_preauricular_pos + right_preauricular_pos]/2;

x_axis=[nasion_pos - origin]; x_axis=x_axis/sqrt(dot(x_axis,x_axis));
y_axis=[left_preauricular_pos - origin];y_axis=y_axis/sqrt(dot(y_axis,y_axis));

% This y-axis is not necessarely perpendicular to the x-axis -> orthogonalise
z_axis=cross(x_axis,y_axis);
y_axis=cross(z_axis,x_axis);

% define z-axis
z_axis=cross(x_axis,y_axis);

figure
hold on
plot3(Hx, Hy, Hz,'yo')
hold on
plot3(nasion_pos(1),nasion_pos(2),nasion_pos(3) ,'k*');
plot3(left_preauricular_pos(1),left_preauricular_pos(2),left_preauricular_pos(3),'k*');
plot3(right_preauricular_pos(1),right_preauricular_pos(2),right_preauricular_pos(3),'k*');
pointx=(origin+x_axis*0.1);
pointy=(origin+y_axis*0.1);
pointz=(origin+z_axis*0.1);
% plot x-axis
plot3([origin(1) pointx(1)] ,[origin(2) pointx(2)],[origin(3) pointx(3)],'g-');
% plot y-axis
plot3([origin(1) pointy(1)] ,[origin(2) pointy(2)],[origin(3) pointy(3)],'k-');
% plot z-axis
plot3([origin(1) pointz(1)] ,[origin(2) pointz(2)],[origin(3) pointz(3)],'r-');

% now transform all points

for i=1:length(Hx)
  v1=[Hx(i) Hy(i) Hz(i)]-origin;
  newx=dot(v1(1:3),x_axis(1:3));
  newy=dot(v1(1:3),y_axis(1:3));
  newz=dot(v1(1:3),z_axis(1:3));
  Hx(i)=newx;
  Hy(i)=newy;
  Hz(i)=newz;
end

for i=1:3
  switch i,
    case 1
      test= nasion_pos;
    case 2
      test= left_preauricular_pos;
    case 3
      test= right_preauricular_pos;
  end
  v1=test-origin;
  newx=dot(v1(1:3),x_axis(1:3));
  newy=dot(v1(1:3),y_axis(1:3));
  newz=dot(v1(1:3),z_axis(1:3));
  test(1)=newx;
  test(2)=newy;
  test(3)=newz;
  switch i,
    case 1
      MEG_nasion_pos=test;
    case 2
      MEG_left_preauricular_pos=test;
    case 3
      MEG_right_preauricular_pos=test;
  end
end


PLOT_ON=0;

if PLOT_ON,

plot3(Hx, Hy, Hz,'co')
plot3(MEG_nasion_pos(1),MEG_nasion_pos(2),MEG_nasion_pos(3) ,'b*');
plot3(MEG_left_preauricular_pos(1),MEG_left_preauricular_pos(2),MEG_left_preauricular_pos(3),'b*');
plot3(MEG_right_preauricular_pos(1),MEG_right_preauricular_pos(2),MEG_right_preauricular_pos(3),'b*');
figh=gcf;


message={'The plot shows the headshape points in bitebar and MEG co-ordinates', ...
'',['nasion_MEG [mm]: ',num2str(1000*MEG_nasion_pos)],'' ...
['Left_MEG [mm]: ',num2str(1000*MEG_left_preauricular_pos)],'' ...
['Right_MEG [mm]: ',num2str(1000*MEG_right_preauricular_pos)],'' };
mh=msgbox(message,' ','help');
pos=get(mh,'Position');
set(mh,'Position',[400 80 pos(3:4)])
figure(figh)
waitfor(mh)

end; % if PLOT_ON





