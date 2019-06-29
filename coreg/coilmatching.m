function coilmatching()

% function coilmatching()
% Reads in the coil positions from the dataset (*.hc) and compares the
% locations to the Polhemus digitised coil locations

error_tolerance = 2.5; % mm

% read in the *.hc file
[hc,res,mes] = readhc_file([]); % in cm
 
% read in the polhemus file
[polname, polpathname] = uigetfile({'*.pos'}, 'Give the new polhemus file name');
polfilename = fullfile(polpathname, polname);
[Hxpol,Hypol,Hzpol, Enas, Eleft, Eright] = rdnewpol(polfilename); % in cm
%% actually these points already in correct CTF coordinate system
%[MEG_Fx, MEG_Fy, MEG_Fz, MEG_nasion_pos, MEG_left_preauricular_pos,MEG_right_preauricular_pos]=Bitebar2MEG(Hxpol/100, Hypol/100, Hzpol/100,Enas/100,Eleft/100,Eright/100 ); % inputs in m

hc_head_nas = [hc.head.nas.x hc.head.nas.y hc.head.nas.z];
nas_err = sqrt(dot(Enas-hc_head_nas, Enas-hc_head_nas))*10; % in mm
hc_head_pal = [hc.head.pal.x hc.head.pal.y hc.head.pal.z];
pal_err = sqrt(dot(Eleft-hc_head_pal, Eleft-hc_head_pal))*10; % in mm
hc_head_par = [hc.head.par.x hc.head.par.y hc.head.par.z];
par_err = sqrt(dot(Eright-hc_head_par, Eright-hc_head_par))*10; % in mm

if nas_err > error_tolerance | pal_err > error_tolerance | par_err > error_tolerance
    disp(sprintf('\n\n *********************   WARNING!!! ****************\n'))
else
    disp(sprintf('\n\n'))
end
disp(sprintf('Nasion mismatch: %2.1f [mm]', nas_err))
disp(sprintf('Left pre-auricular mismatch: %2.1f [mm]', pal_err))
disp(sprintf('Right pre-auricular mismatch: %2.1f [mm]\n\n', par_err))

