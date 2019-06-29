

clf;

R12=[1 0 0;0 1 0;0 0 1];

T1=rand(3,1)';
Rot=rand(3,1)'.*pi;

startpoints=rand(3,10)';
figure(1);
h_headpoints=plot3(startpoints(:,1),startpoints(:,2),startpoints(:,3),'r');
headpoints(:,1)=get(h_headpoints,'Xdata')';
headpoints(:,2)=get(h_headpoints,'Ydata')';
headpoints(:,3)=get(h_headpoints,'Zdata')';

%%endpoints=do_trans(R12,T1,T2,startpoints);
endpoints=GBalign(startpoints,Rot,T1)
hold on;
h_mripoints=plot3(endpoints(:,1),endpoints(:,2),endpoints(:,3),'g');
mripoints(:,1)=get(h_mripoints,'Xdata')';
mripoints(:,2)=get(h_mripoints,'Ydata')';
mripoints(:,3)=get(h_mripoints,'Zdata')';

[nR12,nT1,nT2]=gettrans(headpoints,mripoints);


nendpoints=do_trans(nR12,nT1,nT2,startpoints);

plot3(nendpoints(:,1),nendpoints(:,2),nendpoints(:,3),'g*');
