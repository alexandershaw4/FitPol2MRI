
hsffilename='/mnt/home/users/gareth/pol/00Feb18/rich01.hsf';
CTFfilename='/mnt/home/users/gareth/pol/00Feb18/rich_mri.erode';
elcfilename='/mnt/home/users/gareth/pol/00Feb18/richcl02.elc';

xfmfilename='/mnt/home/users/gareth/pol/00Feb18/rich01_opt_xfm.mat';

%% load in the transformation matrix
load(xfmfilename);

%% load in mri-derived headpoints
[mrx,mry,mrz]=ReadCtfHsf(CTFfilename);
mr=[mrx mry mrz].*1000; %% from cm to mm
%% load in the headshape file points

[Hx,Hy,Hz]=rdhsf(hsffilename);
%% polhemus points in mm
polmm=[Hx*1000 Hy*1000 Hz*1000];

transpol=do_trans(R12,T1,T2,polmm);
hold on;
plot3(mr(:,1),mr(:,2),mr(:,3),'c.');
%plot3(polmm(:,1),polmm(:,2),polmm(:,3),'r.');
plot3(transpol(:,1),transpol(:,2),transpol(:,3),'g.');


[Ex,Ey,Ez]=rdelc(elcfilename);
Emm=[Ex*1000 Ey*1000 Ez*1000];
transE=do_trans(R12,T1,T2,Emm);
plot3(transE(:,1),transE(:,2),transE(:,3),'m*');





