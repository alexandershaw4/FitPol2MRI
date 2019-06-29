function [rot_pars,trans_bitebar_model]=bite_fit3(bitebar_model,bitebar_emp,TRstart)
%% function [rot_pars,trans_bitebar_model]=bite_fit3(bitebar_model,bitebar_emp,TRstart)
     %% similar to bite_fit.m but just used to estimate 3 rotation parameters

OPTIONS = optimset('fminsearch');
OPTIONS.MaxFunEvals=9000;
OPTIONS.MaxIter=9000;
OPTIONS.TolFun=1e-12;
OPTIONS.TolX=1e-12;

if nargin<3,
 TRstart=[0 0 0];
end; 

dist1=bite_cost3(TRstart,bitebar_model,bitebar_emp)
TRend0=fminsearch('bite_cost3',TRstart,OPTIONS,bitebar_model,bitebar_emp);
dist2=bite_cost3(TRend0,bitebar_model,bitebar_emp)
TRend=fminsearch('bite_cost3',TRend0,OPTIONS,bitebar_model,bitebar_emp);
dist3=bite_cost3(TRend,bitebar_model,bitebar_emp)

rot_pars=TRend;

trans_bitebar_model=trans_3d(TRend(1:3),[0 0 0],bitebar_model);








