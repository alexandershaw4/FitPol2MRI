function [ecdist]=bite_cost3(TR,bitebar_model,bitebar_emp);
%%function [dist]=bite_cost3(TR,bitebar_model,bitebar_emp);

th=TR(1:3); 
T=[0 0 0];

[outpoints]=trans_3d(th,T,bitebar_model);

dist=[outpoints-bitebar_emp];

dist2=dist.^2;
dist2_sq=sqrt(sum(dist2'));
ecdist=sum(dist2_sq);


