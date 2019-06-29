function [meanerror]=optalign(scalefactors,limits,test,ref,workdir)
%% function [meanerror]=optalign(scalefactors,test,ref,workdir)
%% a short subroutine intended to be called from fminsearch
%% just calls callalign.m but returns a single scalar mean distance error
 
%scalefactors
%limits
%test
%ref
%workdir

[finalpoints,finalerror]=callalign(test,ref,workdir,scalefactors);
close; %% close current figure
finalerror
meanerror=finalerror(1)


if max(scalefactors)>limits(2),
  meanerror=meanerror*100;
end;

if min(scalefactors)<limits(1),
  meanerror=meanerror*100;
end;
