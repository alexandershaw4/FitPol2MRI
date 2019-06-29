% Bitebar2MEGScript
%
% Transforms the hsf-points from bitebar to CTF-MEG co-ordinates
clear all

txtstring='First, read the headshape points. Assume that the co-ordinate system is defined with repect to the bite-bar';
h=msgbox(txtstring,'Message');
waitfor(h)
[filename, pathname] = uigetfile('*.hsf', 'Give the headshapefile');
hsf_filename=[pathname,filesep, filename];
[Hx, Hy, Hz]=rdhsf(hsf_filename);


% Get the average coil location


  prompt={'Number of coregistration coils'};
  def={'3'};
  dlgTitle='';
  lineNo=1;
  answer=inputdlg(prompt,dlgTitle,lineNo,def);
  NrOfCoils=str2num(char(answer));
  [meanleft, meannasion, meanright, junk, junk]=GetAverageCoilLocations(NrOfCoils,pathname);
  message={'These are the coil location in bitebar co-ordinates [m]:','', ... 
  ['Nasion : ', num2str(meannasion/1000)], ...
  ['Left: ', num2str(meanleft/1000)], ...
  ['Right: ', num2str(meanright/1000)]};
  mh=msgbox(message,' ','warn');
  pos=get(mh,'Position');
  set(mh,'Position',[400 80 pos(3:4)])
  waitfor(mh)


% convert this co-ordinate system to the MEG co-ordinate system as defined by CTF
% need the digitised locations of the nasion and pre-auricular coils
  ButtonName='No';

switch ButtonName,
  case 'Yes',
    txtstring='The last three headshapepoints are used to define the MEG co-ordinate system';
    h=msgbox(txtstring);
    waitfor(h)
    nasion_pos=[Hx(length(Hx)-2) Hy(length(Hx)-2) Hz(length(Hx)-2)];
    left_preauricular_pos=[Hx(length(Hx)-1) Hy(length(Hx)-1) Hz(length(Hx)-1)];
    right_preauricular_pos=[Hx(length(Hx)) Hy(length(Hx)) Hz(length(Hx))];
case 'No',
   prompt={'Enter the nasion location [m]:','Enter the left pre-auricular location [m]:','Enter the right pre-auricular location [m]:'};
   if ~exist('meannasion','var')
     def={'[ 0.0335    0.0023    0.1187    ]','[    -0.0361    0.0709    0.0690 ]','[  -0.0353   -0.0780    0.0602 ]'};
   else
     str1=['[ ',num2str(meannasion/1000),' ]'];
     str2=['[ ',num2str(meanleft/1000),' ]'];
     str3=['[ ',num2str(meanright/1000),' ]'];
     def={str1,str2,str3};
   end
   dlgTitle='Input the location of the coils';
   lineNo=1;
   answer=inputdlg(prompt,dlgTitle,lineNo,def);
   nasion_pos=str2num(char(answer(1)));
   left_preauricular_pos=str2num(char(answer(2)));
   right_preauricular_pos=str2num(char(answer(3)));
   message={'These points are now added to the headshape points as the last 3 points'};
   mh=msgbox(message,' ','help');
   pos=get(mh,'Position');
   set(mh,'Position',[400 80 pos(3:4)])
   waitfor(mh)
   Hx=[Hx;nasion_pos(1);left_preauricular_pos(1);right_preauricular_pos(1)];
   Hy=[Hy;nasion_pos(2);left_preauricular_pos(2);right_preauricular_pos(2)];
   Hz=[Hz;nasion_pos(3);left_preauricular_pos(3);right_preauricular_pos(3)];
end % switch

% now define the CTF-MEG co-ordinate system
[Hx, Hy, Hz,MEG_nasion_pos,MEG_left_preauricular_pos,MEG_right_preauricular_pos]=Bitebar2MEG(Hx, Hy, Hz, nasion_pos, left_preauricular_pos, right_preauricular_pos );

% save the MEG_headshapepoints
%filename=[filename(1:findstr(filename,'.hsf')),'mat'];
%uifile= [pathname,filesep, filename];
%[filename, pathname] = uiputfile(uifile, 'write the MEG headshapepoints');
%outfile1=[pathname,filename];
%save(outfile1,'Hx', 'Hy', 'Hz');

% Save the headshape points in CTF fileformat
%filename=[filename(1:findstr(filename,'.mat')),'hsf'];
[filename, pathname] = uiputfile([pathname,filesep,'CTF_',filename], 'write the MEG headshapepoints in CTF format headshapefile');
WriteCtfHsf([pathname,filesep,filename],Hx,Hy,Hz)


