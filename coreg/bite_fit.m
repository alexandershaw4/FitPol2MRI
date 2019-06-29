function [trans_bitebar_model,TRend]=bite_fit(bitebar_model,bitebar_emp,TRstart)
%%function [trans_bitebar_model,TRend]=bite_fit(bitebar_model,bitebar_emp,TRstart)
%% find optimal transformation to move from bitebar_model to bitebar_emp
%% if TRstart is a 6 parameter (3 rot, 3 trans ) starting guess

OPTIONS = optimset('fminsearch');
OPTIONS.MaxFunEvals=9000;
OPTIONS.MaxIter=9000;
OPTIONS.TolFun=1e-12;
OPTIONS.TolX=1e-12;

if nargin<3,
 TRstart=[0 0 0 mean(bitebar_emp)];
end; 

dist1=bite_cost(TRstart,bitebar_model,bitebar_emp)
TRend0 = fminsearch('bite_cost',TRstart,OPTIONS,bitebar_model,bitebar_emp);
dist2=bite_cost(TRend0,bitebar_model,bitebar_emp)
TRend = fminsearch('bite_cost',TRend0,OPTIONS,bitebar_model,bitebar_emp);
dist3=bite_cost(TRend,bitebar_model,bitebar_emp)

trans_bitebar_model=trans_3d(TRend(1:3),TRend(4:6),bitebar_model);










