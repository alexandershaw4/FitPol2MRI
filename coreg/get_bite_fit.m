function [trans_bitebar_model,bitebar_emp,TRend,dist]=get_bite_fit(bitebar_emp,bitebar_model,TRstart);
%% function [trans_bitebar_model,bitebar_emp,TRend,dist]=get_bite_fit(bitebar_emp,bitebar_model,TRstart);
%% finds the best model bite bar fit to the 5 coils and returns this  model
%%  in trans_bitebar_model
%% also returned are the bitebar coords from the dataset (bitebar_emp)
%% and the mean distance (in cm) per point deviation from model to measured points
%% bitebar_emp and bitebar_model should be sepcified in the form:
%% [mbite_par;mbite_inion; mbite_nas; mbite_Cz;mbite_pal];
%% TRstart is optional start guess 
if nargin<3,
  TRstart=[];
end; % if

%% get model coordinate system
[crap,mdx,mdy,mdz]=get_model_coords_kds_ext([1 0 0],bitebar_model);

%% first estimate the rotation- do this based on the direction cosines of the two bitebars
[norm_bitepoints,edx,edy,edz]=get_model_coords_kds_ext(bitebar_emp,bitebar_emp); %% estimate coord system of rotated bite bar

[rot_pars,estds]=bite_fit3([mdx;mdy;mdz],[edx;edy;edz]);
[rot_model]=trans_3d(rot_pars,[0 0 0],bitebar_model)
 
%%[rot_model,rmdx,rmdy,rmdz]=get_model_coords_kds(bitebar_model,rot_model);

if isempty(TRstart),
 %% now fit the whole model with a good starting guess
 TRstart=[rot_pars mean(bitebar_emp-rot_model)];
 end; % if isempty
startpos=trans_3d(TRstart(1:3),TRstart(4:6),bitebar_model);


[trans_bitebar_model,TRend]=bite_fit(bitebar_model,bitebar_emp,TRstart);
dist=bite_cost([0 0 0 0 0 0],trans_bitebar_model,bitebar_emp);

dist=dist/size(bitebar_model,1); %% give error per point




