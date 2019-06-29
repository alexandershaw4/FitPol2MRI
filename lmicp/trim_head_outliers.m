function [xt,xtind,fit_centre,fit_rad]=trim_head_outliers(x,approxrad,nosetol)
%%function [xt]=trim_head_outliers(x,approxrad,nosetol)
%% x, 3d set of head points
%% approxrad approximate head radius
%% nosetol extra fraction  of head radius needed to accomodate nose (1.6) 
%% returns new set of points xt that arew within 1.6 * best fit sphere radius
  %% xtind, indices of these points in x

if nargin<2,
         approxrad=[];
   end;

if nargin<3,
  nosetol=160/100; %% base on generous grb organ size
end; % if


if isempty(approxrad),
              approxrad=0.08;  %% assume measurements in m
	      end; % if


	      maxlen=1000;
xd=x;
if length(x)>maxlen,
      xd=x(randperm(length(x)),:);
      xd=xd(1:maxlen,:);
      end; % if             
        
approxcentre=mean(x);

[fitted_par,fval,exitflag] = fminsearch('sphere_fit_costfun', [approxrad, approxcentre], [], xd);

fit_centre=fitted_par(2:4);
fit_rad=fitted_par(1);

disp_centre=x-repmat(fit_centre,length(x),1);



for i=1:length(x),
	disp(i)=sqrt(dot(disp_centre(i,:),disp_centre(i,:)));
end; % if


xtind=find(disp<fit_rad*nosetol);

xt=x(xtind,:);

%plot3(x(:,1),x(:,2),x(:,3),'r.',x(outind,1),x(outind,2),x(outind,3),'bo');

