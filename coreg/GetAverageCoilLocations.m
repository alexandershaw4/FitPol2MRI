function [meanpos1, meanpos2, meanpos3, meanpos4, meanpos5, NrOfRecordings]=GetAverageCoilLocations(NrOfCoils,elcfilename,pathname);

% Analyse all the polhemius files
%% there were NrOfCoils coil positions recorded
%
% AH 12 March 2002: Modified so that the NrOfCoils is asked for if this variable is set to empty 
% and modified so that more than 3 coils can be read

if nargin<2,
  elcfilename='';
  end;

if nargin<3,
  pathname='*.elc';
  end;

if isempty(NrOfCoils)
   ButtonName=questdlg('How many coils were used?', ...
                       'number of coils', ...
                       '3','5','5');
   switch ButtonName,
     case '3', 
       NrOfCoils = 3;          
     case '5',
       NrOfCoils = 5;             
   end % switch
end
if ((NrOfCoils~=3) & (NrOfCoils~=5))
  error('Only three or five coil positions supported at present')
end
%if (NrOfCoils~=3),
%  error('Only three coil positions supported at present')
%  end;
  


elcfilename
if length(elcfilename)==0,
  [f,p] = uigetfile(pathname, 'Give the file that contains the coil points');
  elcfilename=[f p];
  end;
[Hx,Hy,Hz]=rdelc(elcfilename);
Hx=1000*Hx; Hy=1000*Hy; Hz=1000*Hz;
NrOfRecordings=length(Hx)/NrOfCoils;

if floor(NrOfRecordings)~=NrOfRecordings,
  error('Given Number of Coils is not in agreement with the number of points in the file')
elseif NrOfCoils==5
  left1=[Hx(1:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(1:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(1:NrOfCoils:NrOfCoils*NrOfRecordings)];
  left2=[Hx(2:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(2:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(2:NrOfCoils:NrOfCoils*NrOfRecordings)];
  middle=[Hx(3:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(3:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(3:NrOfCoils:NrOfCoils*NrOfRecordings)];
  right1=[Hx(4:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(4:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(4:NrOfCoils:NrOfCoils*NrOfRecordings)];
  right2=[Hx(5:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(5:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(5:NrOfCoils:NrOfCoils*NrOfRecordings)];

  pos1 = left1;
  pos2 = left2;
  pos3 = middle;
  pos4 = right1;
  pos5 = right2;
  meanpos1 = mean(pos1,1);
  meanpos2 = mean(pos2,1);
  meanpos3 = mean(pos3,1);
  meanpos4 = mean(pos4,1); 
  meanpos5 = mean(pos5,1);
elseif NrOfCoils==3
  leftear=[Hx(1:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(1:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(1:NrOfCoils:NrOfCoils*NrOfRecordings)];
  nasion=[Hx(2:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(2:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(2:NrOfCoils:NrOfCoils*NrOfRecordings)];
  rightear=[Hx(3:NrOfCoils:NrOfCoils*NrOfRecordings) Hy(3:NrOfCoils:NrOfCoils*NrOfRecordings) Hz(3:NrOfCoils:NrOfCoils*NrOfRecordings)];

  pos1 = leftear;
  pos2 = nasion;
  pos3 = rightear;
  pos4 = [];
  pos5 = [];
  meanpos1 = mean(pos1,1);
  meanpos2 = mean(pos2,1);
  meanpos3 = mean(pos3,1); 
  meanpos4 = []; 
  meanpos5 = [];
end

figure
hold on
plot3(pos1(:,1),pos1(:,2), pos1(:,3),'r.')
plot3(pos2(:,1),pos2(:,2), pos2(:,3),'b.')
plot3(pos3(:,1),pos3(:,2), pos3(:,3),'g.')      
if NrOfCoils==5
  plot3(pos4(:,1),pos4(:,2), pos4(:,3),'m.')
  plot3(pos5(:,1),pos5(:,2), pos5(:,3),'k.')      
end

plot3(meanpos1(:,1),meanpos1(:,2), meanpos1(:,3),'c*')
plot3(meanpos2(:,1),meanpos2(:,2), meanpos2(:,3),'c*')
plot3(meanpos3(:,1),meanpos3(:,2), meanpos3(:,3),'c*')      
if NrOfCoils==5
  plot3(meanpos4(:,1),meanpos4(:,2), meanpos4(:,3),'c*')
  plot3(meanpos5(:,1),meanpos5(:,2), meanpos5(:,3),'c*')      
end

