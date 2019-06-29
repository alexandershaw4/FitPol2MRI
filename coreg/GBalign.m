function [new_hatpts]=GBalign(hatpts, Rot,Trans,C);

% Rot in radians
% Trans in mm
% Hx, Hy, Hz in mm

format long

if nargin<6,
  % calculate C if not given
  C=mean(hatpts,1);
  end

% rigid body transformation as in paper Kozinska
T=Trans;
R=getXYZ(Rot(1),Rot(2),Rot(3));
new_hatpts=getnewP(R,T,hatpts',C)';


