function [endpoints,R]=trans_3d(th,T,startpoints);
%%function [endpoints,T]=trans_3d(th,T,startpoints);
%% apply a rigid body transform (translation then rotation) to startpoints based on
%% a rotation of three angles th(1:3) in degrees and a translation T(1:3)

     th=th*pi/180; %% convert from deg to rad
cosa=cos(th(1));
sina=sin(th(1));
cosb=cos(th(2));
sinb=sin(th(2));
cosc=cos(th(3));
sinc=sin(th(3));



R(1,:)=[cosa*cosb+sina*sinc*sinb, sina*cosb-cosa*sinc*sinb, cosc*sinb,0];
R(2,:)=[-sina*cosc, cosa*cosc, sinc, 0];
R(3,:)=[sina*sinc*cosb-cosa*sinb,-cosa*sinc*cosb-sina*sinb,cosc*cosb,0];
R(4,:)=[0 0 0 1];

R1(1,:)=[1 0 0 T(1)];
R1(2,:)=[0 1 0 T(2)];
R1(3,:)=[0 0 1 T(3)];
R1(4,:)=[0 0 0 1];

%% put add an extra 1 to startpoints to make it fit
startpoints4=cat(2,startpoints,ones(size(startpoints,1),1));

transpoints=R*startpoints4';
endpoints4=R1*transpoints;


endpoints=endpoints4(1:3,:)';

