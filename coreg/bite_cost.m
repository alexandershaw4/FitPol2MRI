function [ecdist]=bite_cost(TR,bitebar_model,bitebar_emp);
%%function [dist]=bite_cost(TR,bitebar_model,bitebar_emp);
%% used to fit a model to measured points given a transformation of 
%% 6 elements : 3 rotation then three translation
th=TR(1:3); 
T=TR(4:6);
[outpoints]=trans_3d(th,T,bitebar_model);

dist=[outpoints-bitebar_emp];

dist2=dist.^2;
dist2_sq=sqrt(sum(dist2'));
ecdist=sum(dist2_sq);
