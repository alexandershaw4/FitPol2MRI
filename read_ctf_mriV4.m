function [mri,hdr] = read_ctf_mriV4 (file) ;
%Function to read a ctf Version 4 MRI file
%Originally Aug 2006 Suresh Muthukumaraswamy
%
%Email sdmuthu@cardiff.ac.uk with bugs
%
%Updated Apr 2008 to be fieldtrip compatible


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Read the data into the tags structure
[fid,message] = fopen(file, 'rb', 's');
if fid < 0, error('cannot open file'); end

fseek(fid, 0, -1);
checkstart = char(fread(fid, [1,4], 'char'));
if strcmp(checkstart, 'WS1_') ~= 1
    error('Start of file does not look a like a version 4 CTF MRI file!!');
end
fprintf('Reading Version 4 CTF .mri file...');

tags = [];
done = 0;
while done == 0    
    [tags, done] = readCPersist (fid, tags, done);
end
fclose(fid);
fprintf('..formatting...');
%Now we have finished reading the file

%Organise the fieldtrip Header section

%General Info
hdr.identifierString = tags.CTFMRI_VERSION;
hdr.imageSize = tags.CTFMRI_SIZE;% always = 256
hdr.dataSize = tags.CTFMRI_DATASIZE;

%Couldnt find these in th version 4 header
%hdr.clippingRange = fread(fid,1,'int16'); % max.integer value of data
%hdr.imageOrientation = fread(fid,1,'int16'); % eg., 0 = left on left, 1 = left on right

temp = ctf2num(tags.CTFMRI_MMPERPIXEL);
hdr.mmPerPixel_sagittal = temp(1); % voxel dimensions in mm
hdr.mmPerPixel_coronal = temp(2); % voxel dimensions in mm
hdr.mmPerPixel_axial = temp(3); % voxel dimensions in mm

%HeadModel_Info specific header items
temp = ctf2num(tags.HDM_NASION);
hdr.HeadModel.Nasion_Sag = temp(1); % fid.point coordinate(in voxels) for nasion - sagittal
hdr.HeadModel.Nasion_Cor = temp(2); % nasion - coronal
hdr.HeadModel.Nasion_Axi = temp(3); % nasion - axial
temp = ctf2num(tags.HDM_LEFTEAR);
hdr.HeadModel.LeftEar_Sag = temp(1); % left ear - sagittal
hdr.HeadModel.LeftEar_Cor = temp(2); % left ear - coronal
hdr.HeadModel.LeftEar_Axi = temp(3); % left ear - axial
temp = ctf2num(tags.HDM_RIGHTEAR);
hdr.HeadModel.RightEar_Sag = temp(1); % right ear - sagittal
hdr.HeadModel.RightEar_Cor = temp(2); % right ear - coronal
hdr.HeadModel.RightEar_Axi = temp(3); % right ear - axial
temp = ctf2num(tags.HDM_DEFAULTSPHERE);
hdr.HeadModel.defaultSphereX = temp(1); % sphere origin x coordinate(in mm)
hdr.HeadModel.defaultSphereY = temp(2); % sphere origin y coordinate(in mm)
hdr.HeadModel.defaultSphereZ = temp(3); % sphere origin z coordinate(in mm)
hdr.HeadModel.defaultSphereRadius = temp(4);

% Image_Info specific header items
hdr.Image.modality = tags.SERIES_MODALITY;
hdr.Image.manufacturerName = tags.EQUIP_MANUFACTURER;
hdr.Image.instituteName = tags.EQUIP_INSTITUTION;
hdr.Image.patientID = tags.PATIENT_ID;
hdr.Image.dateAndTime = tags.STUDY_DATETIME;
hdr.Image.scanType = tags.SERIES_DESCRIPTION;
hdr.Image.contrastAgent = [];
hdr.Image.imagedNucleus = tags.MRIMAGE_IMAGEDNUCLEUS;
hdr.Image.Frequency = tags.MRIMAGE_FREQUENCY;
hdr.Image.FieldStrength = tags.MRIMAGE_FIELDSTRENGTH;
hdr.Image.EchoTime = tags.MRIMAGE_ECHOTIME;
hdr.Image.RepetitionTime = tags.MRIMAGE_REPETITIONTIME;
hdr.Image.InversionTime = tags.MRIMAGE_INVERSIONTIME;
hdr.Image.FlipAngle = tags.MRIMAGE_FLIPANGLE;
hdr.Image.NoExcitations = [];
hdr.Image.NoAcquisitions = tags.MRIMAGE_AVERAGES;
hdr.Image.commentString = tags.STUDY_COMMENTS;
hdr.Image.forFutureUse = []; 

% continuation general header
temp = ctf2num(tags.HDM_HEADORIGIN);
hdr.headOrigin_sagittal = temp(1); % voxel location of head origin
hdr.headOrigin_coronal = temp(2); % voxel location of head origin
hdr.headOrigin_axial = temp(3); % voxel location of head origin
% euler angles to align MR to head coordinate system(angles in degrees !)
temp = ctf2num(tags.CTFMRI_ROTATE);
hdr.rotate_coronal = temp(1); % 1. rotate in coronal plane by this angle
hdr.rotate_sagittal = temp(2); % 2. rotate in sagittal plane by this angle
hdr.rotate_axial = temp(3); % 3. rotate in axial plane by this angle

hdr.orthogonalFlag = tags.CTFMRI_ORTHOGONALFLAG; % if set then image is orthogonal
hdr.interpolatedFlag = tags.CTFMRI_INTERPOLATEDFLAG; % if set than image was interpolated

%if isfield(tags, DICOMSOURCE_SLICE_THICKNESS) == 1 % hdr.identifierString == 'CTF_MRI_FORMAT VER 4.1'
%    hdr.originalSliceThickness = tags.DICOMSOURCE_SLICE_THICKNESS; % original spacing between slices before interpolation
%end

temp = ctf2num(tags.CTFMRI_TRANSFORMMATRIX);
transformMatrix = reshape(temp,4,4)';
hdr.CTFtranformMatrix = transformMatrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Format the scan data
if hdr.dataSize==1
   mri = uint8(zeros([hdr.imageSize hdr.imageSize hdr.imageSize]));
elseif hdr.dataSize==2
    mri = uint16(zeros([hdr.imageSize hdr.imageSize hdr.imageSize]));
end

for i = 1 : hdr.imageSize
     if i < 10
         tempfieldname = ['CTFMRI_SLICE_DATA0000' num2str(i)];
     elseif i < 100  
         tempfieldname = ['CTFMRI_SLICE_DATA000' num2str(i)];
     else
         tempfieldname = ['CTFMRI_SLICE_DATA00' num2str(i)];
     end
     if hdr.dataSize==1
         mri(i,:,:) = reshape(getfield(tags, tempfieldname), 256, 256); 
     elseif hdr.dataSize==2 %Move data out of byte stream they were read into
         mri(i,:,:) = reshape(swapbytes(typecast(getfield(tags, tempfieldname), 'uint16')), 256, 256); %Put that in your pipe and smoke it!
     end
end

mri = flipdim(mri, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Post Process the data (Cut and paste Robert Oostenveld's code here)
flip = [-1 0 0 256
         0 1 0 0
         0 0 1 0
         0 0 0 1    ];
%%transformMatrix = flip*transformMatrix;

% re-compute the homogeneous transformation matrices (apply voxel scaling)
scale = eye(4);
scale(1,1) = hdr.mmPerPixel_sagittal;
scale(2,2) = hdr.mmPerPixel_coronal;
scale(3,3) = hdr.mmPerPixel_axial;
hdr.transformHead2MRI = transformMatrix*inv(scale);
hdr.transformMRI2Head = scale*inv(transformMatrix);

% determint location of fiducials in MRI voxel coordinates
% flip the fiducials in voxel coordinates to correspond to the previous flip along left-right
hdr.fiducial.mri.nas = [256 - hdr.HeadModel.Nasion_Sag hdr.HeadModel.Nasion_Cor hdr.HeadModel.Nasion_Axi];
hdr.fiducial.mri.lpa = [256 - hdr.HeadModel.LeftEar_Sag hdr.HeadModel.LeftEar_Cor hdr.HeadModel.LeftEar_Axi];
hdr.fiducial.mri.rpa = [256 - hdr.HeadModel.RightEar_Sag hdr.HeadModel.RightEar_Cor hdr.HeadModel.RightEar_Axi];

% compute location of fiducials in MRI and HEAD coordinates
hdr.fiducial.head.nas = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.nas, 'homogenous');
hdr.fiducial.head.lpa = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.lpa, 'homogenous');
hdr.fiducial.head.rpa = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.rpa, 'homogenous');

fprintf('MRI reading complete\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%Tag Reader for CTFs persist object
%Note: the no support tags shouldn't matter  - at least not for reading
%the .mri file

function [tags, done] = readCPersist (fid, tags, done); 

length1 = fread(fid, 1, 'int32');
label = char(fread(fid, [1,length1] , 'char'));
if strcmp(label, 'EndOfParameters') == 1
   done = 1;
   return
end
type = fread(fid, 1, 'int32');
if type == 10  %CStrings
   length2 = fread(fid, 1, 'int32');
   value = char(fread(fid, [1,length2], 'uint8'));
elseif type == 3       %Binary Data = MRI
   length2 = fread(fid, 1, 'int32');
   value = fread(fid, length2, '*uint8');
elseif type == 1
    fprintf('No support- posible error\n');
elseif type == 2    
    fprintf('No support- posible error\n');
elseif type == 4
    value = fread(fid, 1, 'double');
elseif type == 5
    value = fread(fid, 1, 'int32');
elseif type == 6
    value = fread(fid, 1, 'int16');
elseif type == 7
    value = fread(fid, 1, 'uint16');
elseif type == 8
    value = fread(fid, 1, 'uint8');
elseif type == 9
    value = char(fread(fid, 32, 'uint8'));
elseif type == 11
    fprintf('No support- posible error\n');
elseif type == 12    
     fprintf('No support- posible error\n');
elseif type ==  13     
     fprintf('No support- posible error\n');
elseif type == 14
   value = fread(fid, 1, 'char');
elseif type == 15
   value = fread(fid, 1, 'int64'); %Little confused by the CTF manual here but think this is right 
elseif type == 16
    value = fread(fid, 1, 'uint64');
elseif type == 17    
    value = fread(fid, 1, 'int32');
else
    fprintf('Error - CPersist type %d not identified\n', type);
    error('Error reading file');
end  
  label = strrep(label,'#',''); %remove the # for the MRI slices so it is MATLAB field compatible
  tags = setfield(tags,label(2:end) ,value); %Remove the underscore as fieldnames cant start with this%
return

%%%%%%%%%%%%%%%%%%

function Numbers = ctf2num(String);
%This function parses one of those silly CTF strings into a numeric array
  position = findstr('\', String);
  ind = 1;
  for i = 1 : (length(position) + 1)
      if i <= length(position)
       temp = String(ind : position(i) - 1  );
       ind = position(i) + 1;
      else
       temp = String(position(i - 1) + 1:end);
      end
      Numbers(i) = str2num(temp) ;
   end    
return