function FitPol2MRI(shapefilename,polfilename)
global model mripoints mri_subset doplot mri mriinfo 

doplot = 1;

% Based on Gareth Barnes' lucky_coreg.m, which employs an ICP routine for
% integrating the polhemus-like headshape data with the shapefile
%
% This version optimises a 3-parameter rigid-body transfrom around x, y & z
% planes, optimised using a quasi-newton convex optimisation under 
% Wolfe-Powell conditions (see PR_minimise.m)
%
% AS2019


% GB's code -
%-------------------------------------------------------------------------

[fpath,fname,fext]=fileparts(shapefilename);
mrifilename=[fpath filesep fname '.mri'];

[mri,mriinfo]=read_ctf_mriV4(mrifilename);

[fpath,fname,fext]=fileparts(polfilename);

[fpath fname fext]=fileparts(polfilename);
fidfilename=[fpath filesep fname '.fid'];

[fpath fname fext]=fileparts(polfilename);
checkpolfilename=[fpath filesep fname '_check' '.shape'];
newmrifilename=[fpath filesep fname '.mri'];
newshapefilename=[fpath filesep fname '_trimmed.shape'];

switch fext
    case '.pos' %polhemus
        [Hxpol,Hypol,Hzpol, Enas, Eleft, Eright] = rdpos(polfilename);
    case '.elc' %xensor
        [Hxpol,Hypol,Hzpol, Enas, Eleft, Eright] = rdxen(polfilename);
    otherwise
        error ('File format of digitiser data not recognised');
end;

[MEG_Fx, MEG_Fy, MEG_Fz, MEG_nasion_pos, MEG_left_preauricular_pos,...
    MEG_right_preauricular_pos]=coords2CTF(Hxpol, Hypol, Hzpol, Enas, Eleft, Eright);

[Hx,Hy,Hz]=ReadCtfHsf(shapefilename);
mripoints=[Hx Hy Hz];
polpoints=[MEG_Fx,MEG_Fy,MEG_Fz];

% This is GB code for finding outliers 
%-------------------------------------------------------------------------

TRIMMING=1;
tmripoints=mripoints;
tpolpoints=polpoints;
if TRIMMING,
    disp('Finding best fit sphere to MRI shape points');
    [tmripoints,mritind,mri_centre,mri_rad]=trim_head_outliers(mripoints);
    
    disp(sprintf('Clipped %3.2f percent of mri shape points ',...
        100-100*length(tmripoints)/length(mripoints)));
    disp('Finding best fit sphere to Polhemus head shape points');
    [tpolpoints,poltind,pol_centre,pol_rad]=trim_head_outliers(polpoints);
    disp(sprintf('Clipped %3.2f percent of pol hsf points',...
        100-100*length(tpolpoints)/length(polpoints)));
    max_rad=max(mri_rad,pol_rad);
    % so now have 2 spheres (should have approx same radius, and 2 sphere centres)
else
    disp('No sphere fitting, taking centres of point clouds to be mean values');
    mri_centre=mean(mripoints);
    pol_centre=mean(polpoints);
    max_rad=0.08;
end; 

basic_disp=pol_centre-mri_centre; %difference between centres

% what is largest z value in mri shape file
[zshape_sorted,zind]=sort(tmripoints(:,3));
zind95=zind(round(0.95*length(zind)));
zind5=zind(round(0.05*length(zind)));
zmri95=mripoints(zind95,3);
zmri5=mripoints(zind5,3);

% 95th and 5th percentile from pol points
[zpol_sorted,zpolind]=sort(tpolpoints(:,3));
zpolind95=zpolind(round(0.95*length(zpolind)));
zpol95=tpolpoints(zpolind95,3);

zpolind5=zpolind(round(0.05*length(zpolind)));
zpol5=tpolpoints(zpolind5,3);

% what is approx range of z values in pol file
polzrange=(zpol95-zpol5);
mrizrange=zmri95-zmri5;

cmripoints=tmripoints;
cpolpoints=tpolpoints;

% This is GB code for finding & clipping the nose and face 
%-------------------------------------------------------------------------

 CLIPPING=1;
% get two sets of points into approx same z range
if CLIPPING,
if mrizrange>polzrange,
  mrizthresh=zmri95-polzrange; 
  clipped_mri_ind=find(tmripoints(:,3)>mrizthresh);
  cmripoints=tmripoints(clipped_mri_ind,:); %% clipped mri points
  disp(sprintf('Clipped %3.2f percent of mri shape points, below z=%3.2f',...
      100-100*length(cmripoints)/length(tmripoints),mrizthresh));

else,
   polzthresh=zpol95-mrizrange; 
  clipped_pol_ind=find(tpolpoints(:,3)>polzthresh);
  cpolpoints=tpolpoints(clipped_pol_ind,:);
  disp(sprintf('Clipped %3.2f percent of pol hsf points, below z=%3.2f',...
      100-100*length(cpolpoints)/length(tpolpoints),polzthresh));
end; 

end; 


% update to use clipped points!
polpoints = cpolpoints;
mripoints = cmripoints;



% Alex code - 
%-------------------------------------------------------------------------


% use alex function for centres
%----------------------------------------------
pol_centre = spherefit(polpoints);
mri_centre = spherefit(mripoints);


% place fiducial points back into polpoints list
%-------------------------------------------------------------------------
% model = [ MEG_nasion_pos; MEG_left_preauricular_pos; 
%             MEG_right_preauricular_pos; polpoints ];
model = polpoints;
        


% dimensionality reduction
%-------------------------------------------------------------------------
% design a reduced-mri (subset) matching num polpoints
D = cdist(mripoints,model);

for i = 1:size(D,2)
    % find appropriate mri point for each shape point
    [~,ind] = min(D(:,i));
    mri_match(i) = ind(1);
end
mri_subset = mripoints(mri_match,:);


% SET THE METHOD: 'AFFINE' = 0 ; 'ROTATOR' = 1;
METHOD = 2;

if METHOD == 0
    
    % FIT AN AFFINE MATRIX
    %======================================================================

    
    % build rotation model (parameter set)
    %-------------------------------------------------------------------------
    Rx = eye(3);
    Rx(4,:) = 1;
    Rx(:,4) = 1;


    % initial fit error
    e0 = sum( sum(mri_subset - model) ).^2;
    fprintf('Initial (squared) fit error = %d\n',e0);

    if doplot == 1
        figure('position',[675 596 1198 365]);
    end

    % original fids
    fids0 = [MEG_nasion_pos; ...
             MEG_left_preauricular_pos;...
             MEG_right_preauricular_pos ];


    % OPTIMISATION
    %-------------------------------------------------------------------------
    % options = optimset('GradObj','on');
    % [X,F] = fminunc(@fitter,Rx(:),options);
    %[X, F, i] = PR_minimize(Rx(:), @fitter, 128);
    [X,F] = AO(@fitter,Rx,(Rx*0)+.2,0,[],[],[],1e-12);

    fprintf('Posterior (squared) fit error = %d\n',F(end));

    % compute posterior FID positions
    %---------------------------------------------------------
    Rx = reshape(X,[4 4]);  % rotation (affine-like)
    fids1  = fids0*Rx(1:3,1:3);
%     scale0 = Rx(1:3,4);     % scaling
%     scale1 = Rx(4,1:3);
%     bounds = [min(fids0);max(fids0)];
% 
%     for i = 1:3
%         LB = bounds(1,i)*scale0(i);
%         UB = bounds(2,i)*scale1(i);
%         fids1(:,i) = LB + (UB - LB) .* ( fids1(:,i) - min(fids1(:,i)) ) / (max(fids1(:,i))-min(fids1(:,i)));  
%     end

    % compute posterior shape-points
    %----------------------------------------------------------
    pnts0 = model;
    Rx = reshape(X,[4 4]);  % rotation (affine-like)
    pnts  = pnts0*Rx(1:3,1:3);
%     scale0 = Rx(1:3,4);     % scaling
%     scale1 = Rx(4,1:3);
%     bounds = [min(pnts0);max(pnts0)];
% 
%     for i = 1:3
%         LB = bounds(1,i)*scale0(i);
%         UB = bounds(2,i)*scale1(i);
%         pnts(:,i) = LB + (UB - LB) .* ( pnts(:,i) - min(pnts(:,i)) ) / (max(pnts(:,i))-min(pnts(:,i)));  
%     end
    
    
elseif METHOD == 1 
    
    % USE ROTATE & SCALE MODEL
    %======================================================================
    
    %     rx ry rz Sx Sy Sz
    Rx = [0  0  0  0  0  0]';
    
    % initial error
    e0 = fitter_rot(Rx); close;
    fprintf('Initial (squared) fit error = %d\n',e0);

    if doplot == 1
        figure('position',[675 596 1198 365]);
    end

    % original fids
    fids0 = [MEG_nasion_pos; ...
             MEG_left_preauricular_pos;...
             MEG_right_preauricular_pos ];
    
    % OPTIMISATION
    %-------------------------------------------------------------------------
    % options = optimset('GradObj','on');
    % [X,F] = fminunc(@fitter,Rx(:),options);
    %[X, F, i] = PR_minimize(Rx, @fitter_rot, 128);
    [X,F] = AO(@fitter_rot,Rx,(Rx*0)+.2,0,[],[],[],1e-12);

    fprintf('Posterior (squared) fit error = %d\n',F(end));

    % compute posterior FID positions
    %---------------------------------------------------------
    Rx    = X;
    fids1 = fids0;
    
    % apply rotation
    fids1 = rotator(Rx,fids1);
    
    % apply scale
    c0      = Rx(4:6);
    fids1   = fids1 - repmat(c0',[size(fids1,1),1]);

    
    % compute posterior shape-points
    %----------------------------------------------------------
    pnts = model;
    
    % apply rotation
    pnts = rotator(Rx,pnts);
    
    % apply scale
    c0     = Rx(4:6);
    pnts   = pnts - repmat(c0',[size(pnts,1),1]);
    
elseif METHOD == 2
    
    % USE ROTATE & SCALE MODEL
    %======================================================================
    
    %     rx   ry   rz   Sx   Sy   Sz 
    Rx = [0    0    0    .9   .9   .9 ]';
    Rv = [1/16 1/16 1/16 1/5  1/5  1/5]';
    
    % initial error
    e0 = fitter_rot_scale(Rx); close;
    fprintf('Initial (squared) fit error = %d\n',e0);

    if doplot == 1
        figure('position',[675 596 1198 365]);
    end

    % original fids
    fids0 = [MEG_nasion_pos; ...
             MEG_left_preauricular_pos;...
             MEG_right_preauricular_pos ];
    
    % OPTIMISATION
    %-------------------------------------------------------------------------
    % options = optimset('GradObj','on');
    % [X,F] = fminunc(@fitter,Rx(:),options);
    %[X, F, i] = PR_minimize(Rx, @fitter_rot, 128);
    [X,F] = AO(@fitter_rot_scale,Rx,Rv,0,[],[],[],1e-12);

    fprintf('Posterior (squared) fit error = %d\n',F(end));

    % compute posterior FID positions
    %---------------------------------------------------------
    Rx    = X;
    fids1 = fids0;
    
    % apply rotation
    fids1 = rotator(Rx,fids1);
    
    % apply scale
    c0      = Rx(4:6);
    fids1   = fids1 .* repmat(c0',[size(fids1,1),1]);

    
    % compute posterior shape-points
    %----------------------------------------------------------
    pnts = model;
    
    % apply rotation
    pnts = rotator(Rx,pnts);
    
    % apply scale
    c0     = Rx(4:6);
    pnts   = pnts .* repmat(c0',[size(pnts,1),1]);
        
    fprintf('\nCHANGES:\n-------------------------------------------------\n');
    fprintf('x rotation: %d / x scale: %d\ny rotation: %d / y scale: %d\nz rotation: %d / z scale: %d\n\n',...
        Rx(1),Rx(4),Rx(2),Rx(5),Rx(3),Rx(6) );
end
    

% make fids compatible with GB code:
fidpoints      = fids0;
transfidpoints = fids1;

% display original and fitted FID points...
figure;
plot3(cmripoints(:,1),cmripoints(:,2),cmripoints(:,3),'c.');hold on;
scatter3(fidpoints(:,1),fidpoints(:,2),fidpoints(:,3),'k','filled')
h=plot3(transfidpoints(:,1),transfidpoints(:,2),transfidpoints(:,3),'r*');
set(h,'LineWidth',8); 
axis equal;
legend({'brain' 'orig fid' 'new fid'});
view([-90 90]);


% Now back to GB code to make the outputs / files etc.
%-------------------------------------------------------------------------

%mriinfo=rdmrihead_new(mrifilename);
[mri,mriinfo] = read_ctf_mriV4(mrifilename);

for f = 1:3,
  % transform fid points
  mritransfidpoints(f,:)=ctfhead2mri(transfidpoints(f,:).*1000,...
  mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input

  % transfrom shape points
  pnts(f,:) = ctfhead2mri(pnts(f,:).*1000,...
  mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input

end;  

% make shape pnts compatible with GB code
MEG_Fx = pnts(:,1);
MEG_Fy = pnts(:,2);
MEG_Fz = pnts(:,3);


fprintf('Writing fiducials .fid file\n');
wtCtfFid(fidfilename,mritransfidpoints);
fprintf('Writing CTF headshape file\n');
WriteCtfHsf(checkpolfilename,MEG_Fx,MEG_Fy,MEG_Fz);


disp('****************************************************************');
disp('NOW TO COREGISTER , OPEN A NEW TERMINAL AND TYPE');
disp(sprintf('cd %s',fpath));
disp(sprintf('MRIViewer -mri %s',mrifilename));
disp(sprintf('Then OPTIONS/Fiducials/Read File.., and load in fid file %s, then press OK',fidfilename));
disp('Then to check coregistration- ** THIS IS VERY IMPORTANT ***');
disp('First see if positions of fiducials correspond to positions of coils (click Nasion, Left Ear, Right ear)');
disp('then load in transformed xensor points to see if they follow scalp surface');
disp(sprintf('OPTIONS/Brain/Head Shape/File/Import Shape, and load in file %s',checkpolfilename));
disp('Then to make an MRI coregistered to this recording');
disp(sprintf('File/Save MRI File as/ , and use name (suggested) %s',newmrifilename));
disp('****************************************************************');
disp('If you want to do SAM analysis next, thewn you have to create a NEW headshape file, as follows:');
disp('open the co-registered MRI in MRIViewer');
disp('Options/Brain/Head Shape')
disp('Select the Brain shape option, then press extract, then save the shape file')
     




end

function M = rotator(Rx,Verts)
global model mripoints mri_subset doplot 
% Rotate the 3d shape about the x, y & z axes by the angles in Rx(1:3)
%
% Apply the rotation matrices to Verts (nx3) and output.
%

if nargin == 1
    Verts = model;
end

x = Rx(1);
y = Rx(2);
z = Rx(3);

% apply rotation matrices about x, y, z
%----------------------------------------
    Rxx= [ 1       0       0      ;
           0       cos(x) -sin(x) ;
           0       sin(x)  cos(x) ];
       
    Ryy= [ cos(y)  0      sin(y)  ;
           0       1      0       ;
          -sin(y)  0      cos(y)  ];
      
    Rzz= [ cos(z) -sin(z) 0       ;
           sin(z)  cos(z) 0       ;
           0       0      1       ];
 
M = Verts;
M = M*Rxx;
M = M*Ryy;
M = M*Rzz;       

end

function [e,J,M] = fitter_rot(Rx)
global model mripoints mri_subset doplot mri mriinfo 
% the objective function to minimise - i.e.
%
% argmin: e = sum( mri_points - rotation(shapepoints) ).^2
%
%

Rx = Rx(:)';

% compute location given roation and scale
%--------------------------------------------------------------------
M  = rotator(Rx(1:3));
c0 = Rx(4:6);
M  = M - repmat(c0,[size(M,1),1]);

% error to minimise
e = sum( sum(mri_subset - M) ).^2;
 
% e = sum( [min(mri_subset) max(mri_subset)] - ...
%          [min(M)          max(M)         ] ).^2;

% display
if doplot == 1
    %plot3(mripoints(:,1),mripoints(:,2),mripoints(:,3),'r'); hold on;
    %scatter3(M(:,1),M(:,2),M(:,3),20,'b','filled');hold off;
    %scatter3(dmodel(:,1),dmodel(:,2),dmodel(:,3),100,'b','filled'); hold off;

    % transform to ctf mri
    for f=1:size(M,1)
        Mctf(f,:)=ctfhead2mri(M(f,:).*1000,...
            mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input
    end
    
    % plots
    subplot(131);
    im=imagesc( mat2gray( squeeze( mri(:,128,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,3),10,'r','filled');axis square;
    hold off; 
    set(gca,'visible','off')
    
    subplot(132);
    im=imagesc( mat2gray( squeeze( mri(128,:,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,2),Mctf(:,3),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    subplot(133);
    im=imagesc( mat2gray( squeeze( mri(:,:,128) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,2),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    drawnow;
end

if nargout > 1
    %fprintf('computing gradients\n');
    %Rx = Rx(:);
    % compute approx jacobian
    delta = .08;
    for i = 1:length(Rx)
        dRx0    = Rx;
        dRx1    = Rx;
        dRx0(i) = dRx0(i) + delta;
        dRx1(i) = dRx1(i) - delta;

        k0      = fitter_rot(dRx0);
        k1      = fitter_rot(dRx1);
        J(i,:)  = (k0 - k1)/(2*delta);
        
    end
    if doplot
        title(e);
    end
end


end

function [e,J,M] = fitter_rot_scale(Rx)
global model mripoints mri_subset doplot mri mriinfo 
% the objective function to minimise - i.e.
%
% argmin: e = sum( mri_points - rotation(shapepoints) ).^2
%
%

Rx = Rx(:)';

% compute location given roation and scale
%--------------------------------------------------------------------
M  = rotator(Rx(1:3));
S1 = Rx(4:6);
M  = M .* repmat(S1,[size(M,1),1]);

% error to minimise
e = sum( sum(mri_subset - M) ).^2;
 
% e = sum( [min(mri_subset) max(mri_subset)] - ...
%          [min(M)          max(M)         ] ).^2;

% display
if doplot == 1
    %plot3(mripoints(:,1),mripoints(:,2),mripoints(:,3),'r'); hold on;
    %scatter3(M(:,1),M(:,2),M(:,3),20,'b','filled');hold off;
    %scatter3(dmodel(:,1),dmodel(:,2),dmodel(:,3),100,'b','filled'); hold off;

    % transform to ctf mri
    for f=1:size(M,1)
        Mctf(f,:)=ctfhead2mri(M(f,:).*1000,...
            mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input
    end
    
    % plots
    subplot(131);
    im=imagesc( mat2gray( squeeze( mri(:,128,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,3),10,'r','filled');axis square;
    hold off; 
    set(gca,'visible','off')
    
    subplot(132);
    im=imagesc( mat2gray( squeeze( mri(128,:,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,2),Mctf(:,3),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    subplot(133);
    im=imagesc( mat2gray( squeeze( mri(:,:,128) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,2),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    drawnow;
end

if nargout > 1
    %fprintf('computing gradients\n');
    %Rx = Rx(:);
    % compute approx jacobian
    delta = .08;
    for i = 1:length(Rx)
        dRx0    = Rx;
        dRx1    = Rx;
        dRx0(i) = dRx0(i) + delta;
        dRx1(i) = dRx1(i) - delta;

        k0      = fitter_rot(dRx0);
        k1      = fitter_rot(dRx1);
        J(i,:)  = (k0 - k1)/(2*delta);
        
    end
    if doplot
        title(e);
    end
end


end


function [e,J,M] = fitter(Rx)
global model mripoints mri_subset doplot mri mriinfo 
% the objective function to minimise - i.e.
%
% argmin: e = sum( mri_points - rotation(shapepoints) ).^2
%
%

% compute location given roation and scale
%--------------------------------------------------------------------
Rx = reshape(Rx,[4 4]);
M  = model*Rx(1:3,1:3);
% scale0 = Rx(1:3,4);
% scale1 = Rx(4,1:3);
% bounds = [min(model);max(model)];
% 
% for i = 1:3
%     LB = bounds(1,i)*scale0(i);
%     UB = bounds(2,i)*scale1(i);
%     M(:,i) = LB + (UB - LB) .* ( M(:,i) - min(M(:,i)) ) / (max(M(:,i))-min(M(:,i)));  
% end

% error to minimise
e = sum( sum(mri_subset - M) ).^2;
       
% display
if doplot == 1
    %plot3(mripoints(:,1),mripoints(:,2),mripoints(:,3),'r'); hold on;
    %scatter3(M(:,1),M(:,2),M(:,3),20,'b','filled');hold off;
    %scatter3(dmodel(:,1),dmodel(:,2),dmodel(:,3),100,'b','filled'); hold off;

    % transform to ctf mri
    for f=1:size(M,1)
        Mctf(f,:)=ctfhead2mri(M(f,:).*1000,...
            mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input
    end
    
    % plots
    subplot(131);
    im=imagesc( mat2gray( squeeze( mri(:,128,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,3),10,'r','filled');axis square;
    hold off; 
    set(gca,'visible','off')
    
    subplot(132);
    im=imagesc( mat2gray( squeeze( mri(128,:,:) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,2),Mctf(:,3),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    subplot(133);
    im=imagesc( mat2gray( squeeze( mri(:,:,128) ) )' );
    colormap(gray)    ;hold on;
    scatter(Mctf(:,1),Mctf(:,2),10,'r','filled');axis square;
    hold off;    
    set(gca,'visible','off')
    
    drawnow;
end

if nargout > 1
    %fprintf('computing gradients\n');
    Rx = Rx(:);
    % compute approx jacobian
    delta = .08;
    for i = 1:length(Rx)
        dRx0    = Rx;
        dRx1    = Rx;
        dRx0(i) = dRx0(i) + delta;
        dRx1(i) = dRx1(i) - delta;

        k0      = fitter(dRx0);
        k1      = fitter(dRx1);
        J(i,:)  = (k0 - k1)/(2*delta);
        
    end
    if doplot
        title(e);
    end
end


end



% % Now just rerun the best one
% % figure;
% 
%  [final_R12,final_T1,final_T2,final_mean_err,final_params,Tdata_final]=...
%   gettrans_lmicp(cmripoints,cpolpoints,mri_centre,pol_centre,max_rad,[],startparams(minind,:));
% %title(sprintf('Rerun based on start parameters for run %d, minerr=%3.2f',minind,final_mean_err));
% 
% 
% fidpoints=[MEG_nasion_pos; MEG_left_preauricular_pos;MEG_right_preauricular_pos];
% 
% transfidpoints=do_trans(final_R12,final_T1,final_T2,fidpoints);
% 
% figure;
% plot3(cmripoints(:,1),cmripoints(:,2),cmripoints(:,3),'c.');hold on;
% plot3(Tdata_final(:,1),Tdata_final(:,2),Tdata_final(:,3),'ro');
% h=plot3(transfidpoints(:,1),transfidpoints(:,2),transfidpoints(:,3),'m*');
% 
% set(h,'LineWidth',8);
% 
% %mriinfo=rdmrihead_new(mrifilename);
% [mri,mriinfo]=read_ctf_mriV4(mrifilename);
% 
% for f=1:3,
%   mritransfidpoints(f,:)=ctfhead2mri(transfidpoints(f,:).*1000,...
%   mriinfo.transformHead2MRI',mriinfo.mmPerPixel_sagittal); %% works for mm input
% end; % for f 
% 
% 
% wtCtfFid(fidfilename,mritransfidpoints);
% 
% 
% WriteCtfHsf(checkpolfilename,MEG_Fx,MEG_Fy,MEG_Fz);


