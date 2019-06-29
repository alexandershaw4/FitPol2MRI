function [R12,T1,T2]=gettrans(startpoints,endpoints);
%%function [R12,T1,T2]=gettrans(startpoints,endpoints);
%% given a set of start and end points calculates 
%% transformations to move between them
%%GRB 02/10/00
npoints=size(startpoints,1);

firstpoint=1;
midpoint=floor(npoints/2);
lastpoint=npoints;

%% get three orthogonal vectors, x1,y1,z1
o1=startpoints(midpoint,:);
x1=startpoints(firstpoint,:)-o1;
a1=startpoints(lastpoint,:)-o1;
x1=x1./sqrt(dot(x1,x1));
a1=a1./sqrt(dot(a1,a1));
y1=cross(x1,a1);
%%cross-product of non-orthogonal vectors is not unit length
y1=y1./sqrt(dot(y1,y1));
z1=cross(x1,y1);

o2=endpoints(midpoint,:);
x2=endpoints(firstpoint,:)-o2;
a2=endpoints(lastpoint,:)-o2;
x2=x2./sqrt(dot(x2,x2));
a2=a2./sqrt(dot(a2,a2));
y2=cross(x2,a2);
y2=y2./sqrt(dot(y2,y2));
z2=cross(x2,y2);
%%

R1=[x1;y1;z1]';
R2=[x2;y2;z2]';


R12=R1*R2';
%newx1=(startpoints(firstpoint,:)-o1)*R1
%newx2=(endpoints(firstpoint,:)-o2)*R2


T1=-o1;
T2=o2;




