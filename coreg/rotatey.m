function rotatey()

 yrot=get(gcbo,'value');
set(gcbo,'value',0);
h_headpoints=findobj(gcf,'Tag','headpoints');
headpoints(:,1)=get(h_headpoints,'Xdata')';
headpoints(:,2)=get(h_headpoints,'Ydata')';
headpoints(:,3)=get(h_headpoints,'Zdata')';
delete(h_headpoints);

Trans=[0 0 0];
Rot=[0 yrot 0];
newheadpoints=GBalign(headpoints,Rot,Trans);
h_headpoints=plot3(newheadpoints(:,1),newheadpoints(:,2),newheadpoints(:,3),'go');
set(h_headpoints,'Tag','headpoints');

updateviews;

