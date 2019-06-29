function [finalpoints,finalerror]=callalign(test,ref,workdir,scalefactors)

if nargin<3,
       workdir=pwd;
     end;
if nargin<4,
          scalefactors=[0 0 0]
end;

%% scale up the reference points if scale factors are given
if max(scalefactors>0),
 ref(:,1)=ref(:,1).*scalefactors(1);
 ref(:,2)=ref(:,2).*scalefactors(2);
 ref(:,3)=ref(:,3).*scalefactors(3);
 disp('Running callalign with scale factors :')
 scalefactors
end; 

%% need to make these numbers positive for dmalign to work
minref=min(ref);
mintest=min(test);
%%
posref=[ref(:,1)-minref(1) ref(:,2)-minref(2) ref(:,3)-minref(3)];
postest=[test(:,1)-minref(1) test(:,2)-minref(2) test(:,3)-minref(3)];
%%
test=postest;
ref=posref;
%% save files for align to use
%% 

%% AH June19 2002, changed so that workdir is actually used
%workdir=pwd
currentdir = pwd;
cd(workdir)
disp(sprintf('Coregister is using %s as the working directory!!!', workdir))
save('ref501','ref');
save('test1001','test')
%% remove the distance map


%%
%% align removes a lot of variables
    align_fig_handle=figure(4);clf;
    save workspace01;
    clear
    align_fig_handle=figure(4);clf;
   %% dmalign2
    dmalign2('initialize');
    dmalign2('start')
    dmalign2('align')
    dmalign2('initialize');
    close; clear;clear global;
    load workspace01;
 %% remove .mat files
    load error1001.mat err %% load back in error- want to keep this
    unix(sprintf('rm -f %s/ref501.mat',workdir));
    unix(sprintf('rm -f %s/test1001.mat',workdir));
    unix(sprintf('rm -f %s/error1001.mat',workdir));
    unix(sprintf('rm -f %s/param1001.mat',workdir));
    unix(sprintf('rm -f %s/distancemap501',workdir));
    unix(sprintf('rm -f %s/workspace01.mat',workdir));
    % get the fitresult
    align_fig_handle
    figure(align_fig_handle+1);
    handle=findobj(gcf,'Tag','FitResult');
    result_testx=get(handle,'XData');
    result_testy=get(handle,'YData');
    result_testz=get(handle,'ZData');
    finalpoints=[result_testx' result_testy' result_testz'];
    %% now put numbers back to include negative values
    disp('Errors are ');
    finalerror=err(size(err,1)-1,:)
    size(finalerror);
    size(minref);
    finalpoints=[finalpoints(:,1)+minref(1) finalpoints(:,2)+minref(2) finalpoints(:,3)+minref(3)];
    


cd(currentdir)

