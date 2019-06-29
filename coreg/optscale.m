function [finalscale,finalerror,starterror]=optscale(startscale,limitfactor,test,ref,workdir,maxiter);

if nargin<6,
  display('Setting max iterations to ')
  maxiter=200
end;

limits(1)=min(startscale)/limitfactor;
limits(2)=max(startscale)*limitfactor;

basicoptions=optimset('fminsearch');

options=optimset(basicoptions,'MaxIter',maxiter);
%%starterror=optalign(startscale,limits,test,ref,workdir)

[finalscale,finalerror]=fminsearch('optalign',startscale,options,limits,test,ref,workdir);

