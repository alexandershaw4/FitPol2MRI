function myplot(arg)
%	myplot Interactively 
%		- rotates the view of a 3-D plot.(left button)
%		- translates the viewpoint.(middle button)
%		- zooms in and out.(right button)
%
%   MYPLOT ON turns on mouse-based 3-D rotation.
%   MYPLOT OFF turns if off.
%   MYPLOT by itself toggles the state.
%
%
%   myplot on enables  text feedback during rotation.
%   myplot ON disables text feedback.
%
%   Revised by Cengizhan Ozturk 10-24-1997
%
%   Revised by Rick Paxson 10-25-96
%   Clay M. Thompson 5-3-94
%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 1999/01/19 03:20:44 $

if(nargin == 0)
   setState('toggle');
else
   switch(lower(arg)) % how much performance hit here
   case 'motion'
      rotaMotionFcn
   case 'down'
      rotaButtonDownFcn
   case 'up'
      rotaButtonUpFcn
   case 'on'
      setState(arg);
   case 'off'
      setState(arg);
   otherwise
      error('Unknown action string.');
   end
end

% Set activation state. Options on, ON, off
function setState(state)
rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
if(strcmp(state,'toggle'))
   if(~isempty(rotaObj))
      setState('off');
   else
      setState('on');
   end
elseif(strcmp(lower(state),'on'))
   if(isempty(rotaObj))
      rotaObj = makeRotaObj;
   end
   % Handle toggle of text feedback. ON means no feedback on means feedback.
   rdata = get(rotaObj,'UserData');
   if(strcmp(state,'on'))
      rdata.textState = 1;
   else
      rdata.textState = 0;
   end
   set(rotaObj,'UserData',rdata);
elseif(strcmp(lower(state),'off'))
   if(~isempty(rotaObj))
      destroyRotaObj(rotaObj);
   end
end

% Button down callback
function rotaButtonDownFcn
rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
if(isempty(rotaObj))
   return;
elseif strcmp(get(gcf, 'SelectionType'),'normal'),
	rdata = get(rotaObj,'UserData');
   	rdata.oldFigureUnits = get(gcf,'Units');
   	set(gcf,'Units','pixels');
   	rdata.oldPt = get(gcf,'CurrentPoint');
   	rdata.targetAxis = gca;
   	rdata.oldAzEl = get(rdata.targetAxis,'View');
   	% Map azel from -180 to 180.
   	rdata.oldAzEl = rem(rem(rdata.oldAzEl+360,360)+180,360)-180; 
   	if abs(rdata.oldAzEl(2))>90
      		% Switch az to other side.
      		rdata.oldAzEl(1) = rem(rem(rdata.oldAzEl(1)+180,360)+180,360)-180;
      		% Update el
      		rdata.oldAzEl(2) = sign(rdata.oldAzEl(2))*(180-abs(rdata.oldAzEl(2)));
   	end
   	if(rdata.oldAzEl(2) < 0)
      		rdata.CrossPos = 1;
      		set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
   	else
      		rdata.CrossPos = 0;
      		set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
   	end
   
   	set(rotaObj,'UserData',rdata);
   	setOutlineObjToFitAxes(rotaObj);
   	copyAxisProps(rdata.targetAxis, rotaObj);
   	if(rdata.textState)
      		fig_color = get(gcf,'Color');
      		c = sum([.3 .6 .1].*fig_color);
      		set(rdata.textBoxText,'BackgroundColor',fig_color);
      		if(c > .5)
         		set(rdata.textBoxText,'ForegroundColor',[0 0 0]);
      		else
         		set(rdata.textBoxText,'ForegroundColor',[1 1 1]);
      		end
      		set(rdata.textBoxText,'Visible','on');
   	end
   	set(rdata.outlineObj,'Visible','on');
   	set(gcf,'WindowButtonMotionFcn','myplot(''motion'')');

elseif strcmp(get(gcf, 'SelectionType'),'extend'),
	rdata = get(rotaObj,'UserData');
   	rdata.oldFigureUnits = get(gcf,'Units');
   	set(gcf,'Units','pixels');
   	rdata.oldPt = get(gcf,'CurrentPoint');
   	rdata.targetAxis = gca;
   	rdata.oldaxlim = axis;
   	set(rotaObj,'UserData',rdata);
	setOutlineObjToFitAxes(rotaObj);
   	copyAxisProps(rdata.targetAxis, rotaObj);
   	set(rdata.outlineObj,'Visible','on');
   	set(gcf,'WindowButtonMotionFcn','myplot(''motion'')');

elseif strcmp(get(gcf, 'SelectionType'),'alt'),
   	rdata = get(rotaObj,'UserData');
	rdata.oldFigureUnits = get(gcf,'Units');
   	set(gcf,'Units','pixels');
   	rdata.oldPt = get(gcf,'CurrentPoint');
   	rdata.targetAxis = gca;
   	rdata.oldaxlim = axis;
   	set(rotaObj,'UserData',rdata);
	setOutlineObjToFitAxes(rotaObj);
   	copyAxisProps(rdata.targetAxis, rotaObj);
   	set(rdata.outlineObj,'Visible','on');
   	set(gcf,'WindowButtonMotionFcn','myplot(''motion'')');
end

% Button up callback
function rotaButtonUpFcn
rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
if(isempty(rotaObj))
   	return;
elseif strcmp(get(gcf, 'SelectionType'),'normal'),
   		set(gcf,'WindowButtonMotionFcn','');
   		rdata = get(rotaObj,'UserData');
   		set([rdata.outlineObj rdata.textBoxText],'Visible','off');
   		rdata.oldAzEl = get(rotaObj,'View');
   		set(rdata.targetAxis,'View',rdata.oldAzEl);
   		set(gcf,'Units',rdata.oldFigureUnits);

elseif strcmp(get(gcf, 'SelectionType'),'extend'),
		set(gcf,'WindowButtonMotionFcn','');
   		rdata = get(rotaObj,'UserData');
   		set(rdata.outlineObj,'Visible','off');
   		rdata.oldaxis = [get(rotaObj,'Xlim') get(rotaObj,'Ylim') get(rotaObj,'Zlim')] ;
   		set(rdata.targetAxis,'Xlim',rdata.oldaxis(1:2),'Ylim',rdata.oldaxis(3:4),'Zlim',rdata.oldaxis(5:6));
   		set(gcf,'Units',rdata.oldFigureUnits);

elseif strcmp(get(gcf, 'SelectionType'),'alt'),
		set(gcf,'WindowButtonMotionFcn','');
   		rdata = get(rotaObj,'UserData');
   		set(rdata.outlineObj,'Visible','off');
   		rdata.oldaxis = [get(rotaObj,'Xlim') get(rotaObj,'Ylim') get(rotaObj,'Zlim')] ;
   		set(rdata.targetAxis,'Xlim',rdata.oldaxis(1:2),'Ylim',rdata.oldaxis(3:4),'Zlim',rdata.oldaxis(5:6));
   		set(gcf,'Units',rdata.oldFigureUnits);
end;

% Mouse motion callback
function rotaMotionFcn
if strcmp(get(gcf, 'SelectionType'),'normal')
	rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
	rdata = get(rotaObj,'UserData');
	new_pt = get(gcf,'CurrentPoint');
	old_pt = rdata.oldPt;
	dx = new_pt(1) - old_pt(1);
	dy = new_pt(2) - old_pt(2);
	new_azel = mappingFunction(rdata, dx, dy);
	set(rotaObj,'View',new_azel);
	if(new_azel(2) < 0 & rdata.crossPos == 0)
   		set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
   		rdata.crossPos = 1;
   		set(rotaObj,'UserData',rdata);
	end
	if(new_azel(2) > 0 & rdata.crossPos == 1) 
   		set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
   		rdata.crossPos = 0;
   		set(rotaObj,'UserData',rdata);
	end
	if(rdata.textState)
  		 set(rdata.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',new_azel));
	end

elseif strcmp(get(gcf, 'SelectionType'),'extend'),
	rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
	rdata = get(rotaObj,'UserData');
	new_pt = get(gcf,'CurrentPoint');
	old_pt = rdata.oldPt;
	dx = new_pt(1) - old_pt(1);
	dy = new_pt(2) - old_pt(2);
	new_axlim = mappingFunctionTrans(rdata, dx, dy);
	set(rotaObj,'Xlim',new_axlim(1:2),'Ylim',new_axlim(3:4),'Zlim',new_axlim(5:6));

elseif strcmp(get(gcf, 'SelectionType'),'alt'),
	rotaObj = findobj(allchild(gcf),'Tag','rotaObj');
	rdata = get(rotaObj,'UserData');
	new_pt = get(gcf,'CurrentPoint');
	old_pt = rdata.oldPt;
	dx = new_pt(1) - old_pt(1);
	dy = new_pt(2) - old_pt(2);
	new_axlim = mappingFunctionZoom(rdata, dx, dy);
	set(rotaObj,'Xlim',new_axlim(1:2),'Ylim',new_axlim(3:4),'Zlim',new_axlim(5:6));
end;
%
% Map a dx dy to an azimuth and elevation
%
function azel = mappingFunction(rdata, dx, dy)
delta_az = round(rdata.GAIN*(-dx));
delta_el = round(rdata.GAIN*(-dy));
azel(1) = rdata.oldAzEl(1) + delta_az;
azel(2) = min(max(rdata.oldAzEl(2) + 2*delta_el,-90),90);
if abs(azel(2))>90
   % Switch az to other side.
   azel(1) = rem(rem(azel(1)+180,360)+180,360)-180; % Map new az from -180 to 180.
   % Update el
   azel(2) = sign(azel(2))*(180-abs(azel(2)));
end

%
% Map a dx dy to a translation in axis limits
%
function axlim = mappingFunctionTrans(rdata, dx, dy)
%
% translate the image plane motions to axis changes
%
cup=get(gca,'CameraUpVector');
cpos=get(gca,'CameraPosition');
ctar=get(gca,'CameraTarget');
aa=[get(gca,'Xlim') get(gca,'Ylim') get(gca,'Zlim')] ;
cdir=ctar-cpos;
dum=cross(cdir,cup);dum=dum/norm(dum);
delta = -0.005*(dum*dx +cup*dy);
axlim = [aa(1:2)+delta(1)*abs(aa(2)-aa(1)) aa(3:4)+delta(2)*abs(aa(4)-aa(3)) aa(5:6)+delta(3)*abs(aa(6)-aa(5))];

%
% Map a dx dy to a zoom function
%
function axlim = mappingFunctionZoom(rdata, dx, dy)
%
% translate y motions to zoom in and out
%
ctar=get(gca,'CameraTarget');
aa=[get(gca,'Xlim') get(gca,'Ylim') get(gca,'Zlim')] ;
axlim=[ctar(1) ctar(1) ctar(2) ctar(2) ctar(3) ctar(3)]+...
	(aa-[ctar(1) ctar(1) ctar(2) ctar(2) ctar(3) ctar(3)])*(100-dy)/100;


% Scale data to fit target axes limits
function setOutlineObjToFitAxes(rotaObj)
rdata = get(rotaObj,'UserData');
ax = rdata.targetAxis;
x_extent = get(ax,'XLim');
y_extent = get(ax,'YLim');
z_extent = get(ax,'ZLim');
X = rdata.outlineData;
X(1,:) = X(1,:)*diff(x_extent) + x_extent(1);
X(2,:) = X(2,:)*diff(y_extent) + y_extent(1);
X(3,:) = X(3,:)*diff(z_extent) + z_extent(1);
X(4,:) = X(4,:)*diff(z_extent) + z_extent(1);
set(rdata.outlineObj,'XData',X(1,:),'YData',X(2,:),'ZData',X(3,:));
rdata.scaledData = X;
set(rotaObj,'UserData',rdata);

% Copy properties from one axes to another.
function copyAxisProps(original, dest)
props = {
   'DataAspectRatio'
   'DataAspectRatioMode'
   'CameraViewAngle'
   'CameraViewAngleMode'
   'XLim'
   'YLim'
   'ZLim'
   'PlotBoxAspectRatio'
   'PlotBoxAspectRatioMode'
   'Units'
   'Position'
   'View'
   'Projection'
};
values = get(original,props);
set(dest,props,values);

% Constructor for the Rotate object.
function rotaObj = makeRotaObj
rdata.targetAxis = []; % Axis that is being rotated (target axis)
rdata.GAIN    = 0.4;    % Motion gain
rdata.oldPt   = [];  % Point where the button down happened
rdata.oldAzEl = [];
rdata.oldaxlim  = [];  % added cengizhan 
rotaObj = axes('Parent',gcf,'Visible','off','HandleVisibility','off','Drawmode','fast');
% Data points for the outline box.
rdata.outlineData = [0 0 1 0;0 1 1 0;1 1 1 0;1 1 0 1;0 0 0 1;0 0 1 0; ...
      1 0 1 0;1 0 0 1;0 0 0 1;0 1 0 1;1 1 0 1;1 0 0 1;0 1 0 1;0 1 1 0; ...
      NaN NaN NaN NaN;1 1 1 0;1 0 1 0]'; 
rdata.outlineObj = line(rdata.outlineData(1,:),rdata.outlineData(2,:),rdata.outlineData(3,:), ...
   'Parent',rotaObj,'Erasemode','xor','Visible','off','HandleVisibility','off', ...
   'Clipping','off');

% Make text box.
rdata.textBoxText = uicontrol('Units','Pixels','Position',[2 2 130 20],'Visible','off', ...
   'Style','text','HandleVisibility','off');

rdata.textState = [];
rdata.oldFigureUnits = '';
rdata.crossPos = 0;  % where do we put the X at zmin or zmax? 0 means zmin 1 means zmax
rdata.scaledData = rdata.outlineData;

% Store figure callbacks.
rdata.wbuf = get(gcf,'WindowButtonUpFcn');
rdata.wbdf = get(gcf,'WindowButtonDownFcn');
rdata.wbmf = get(gcf,'WindowButtonMotionFcn');
rdata.bdf  = get(gcf,'ButtonDownFcn');

set(gcf,'WindowButtonDownFcn','myplot(''down'')');
set(gcf,'WindowButtonUpFcn'  ,'myplot(''up'')');
set(gcf,'WindowButtonMotionFcn','');
set(gcf,'ButtonDownFcn','');

set(rotaObj,'Tag','rotaObj','UserData',rdata);

% Deactivate rotate object
function destroyRotaObj(rotaObj)
rdata = get(rotaObj,'UserData');
set(gcf,'WindowButtonUpFcn',    rdata.wbuf);
set(gcf,'WindowButtonDownFcn',  rdata.wbdf);
set(gcf,'WindowButtonMotionFcn',rdata.wbmf);
set(gcf,'ButtonDownFcn',        rdata.bdf);
delete(rdata.textBoxText);
delete(rotaObj);
