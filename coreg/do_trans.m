function [outpoints]=do_trans(R12,T1,T2,inpoints);

for i=1:size(inpoints,1),
	outpoints(i,:)=(inpoints(i,:)+T1)*R12+T2;
end;

