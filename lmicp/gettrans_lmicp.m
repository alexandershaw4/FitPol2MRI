function [R12,T1,T2,mean_err,params,Tdata]=getttrans_lmicp(modelpoints,datapoints,model_centre,data_centre,max_rad,robust_thresh,init_params,PLOT_ON);
%% function [R12,T1,T2,mean_err,params,Tdata]=getttrans_lmicp(modelpoints,datapoints,robust_thresh,init_params)
%% a simple wrapper for run_icp3d.m to give transform that can be used directly on input points
%% modelpoints are the more numerous
%% R12,T1,T2 are rotation and translation inputs to do_trans
%% params are in quaterion format and scaled translational format (for run_icp3d.m), but can plug back into this function as init_params 
  %% Tdata are transformed data points 
%% i.e. [Tdata]=do_trans(R12,T1,T2,datapoints);
%% model_centre, data_centre: for coregistration, works best if these correspond to centres of best fit spheres for mri and pol points (rather than mean values)
     %% max_rad - not used at present

if nargin<8,
	  PLOT_ON=0;
end; % if 
     
if nargin<7,
	  init_params=[];
end; % if 

if nargin<6,
          robust_thresh=[];
end; % if

polpoints=datapoints;
mripoints=modelpoints;

%% meanpol=mean(polpoints);
%% meanmri=mean(mripoints);

disp('Adjusting mri and pol points so that sphere centres match');

meanpol=data_centre; %% correct based on centre of spheres these points occupy
meanmri=model_centre;

zpolpoints=polpoints-repmat(meanpol,length(polpoints),1);
zmripoints=mripoints-repmat(meanmri,length(mripoints),1);
% first run, no robustness
[params,scale,t,mean_err] = run_icp3d_modgp(zmripoints, zpolpoints,robust_thresh,init_params,PLOT_ON);
   
 
%% note that scaling in function for parameters is PARAMSCALE = [1 1 1 1 100 100 100];


%% Scale up and shift into icp coords (as set up in run_icp3d)
Data = awf_translate_pts(zpolpoints * scale, t);
Model = awf_translate_pts(zmripoints * scale, t);

%% calculate rotation
p1=params(1);p2=params(2);p3=params(3);p4=params(4);p5=params(5);p6=params(6);p7=params(7);
R = coolquat2mat([p1 p2 p3 p4]) / sum([p1 p2 p3 p4].^2);
%% make translation and rotation to get transformed points in icp coords
Ticp = (R * (Data+ repmat([p5 p6 p7]*100,length(zpolpoints),1))')';
%% now scale back down
Tz=awf_translate_pts(Ticp/scale,-t/scale);

%% now add mean displacement difference back on
%% Tpol is now in original mri coordinates
Tpol=Tz+repmat(meanmri,length(polpoints),1); 


%% lets get simple transform that does all of this

[R12,T1,T2]=gettrans(polpoints,Tpol);
[Tdata]=do_trans(R12,T1,T2,polpoints);

