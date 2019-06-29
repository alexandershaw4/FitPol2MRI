function [outpoints,dx,dy,dz]=get_model_coords_kds_ext(inpoints,bitebar5);

Npoints=size(inpoints,1)

modelbite_par=bitebar5(1,:);
modelbite_inion=bitebar5(2,:);
modelbite_nas=bitebar5(3,:);
modelbite_Cz=bitebar5(4,:);
modelbite_pal=bitebar5(5,:);

 model_origin=mean([modelbite_nas;modelbite_pal; modelbite_par; modelbite_inion;modelbite_Cz])

 %% define x axis from mean for vectors from origin to bitebar points
    rel_model_nas= modelbite_nas-model_origin;
    rel_model_pal= (modelbite_pal-model_origin);
    rel_model_par= (modelbite_par-model_origin);
    rel_model_inion= modelbite_inion-model_origin;
    rel_model_Cz= modelbite_Cz-model_origin;


[rel_model_par;rel_model_inion;rel_model_nas;rel_model_Cz;rel_model_pal]
 %%
    dx=mean([-rel_model_par;rel_model_inion;rel_model_nas;rel_model_Cz;-rel_model_pal])
    dx=dx/sqrt(dot(dx,dx));
    
%% now do dy
y(1,:)=-cross(rel_model_pal-rel_model_nas,rel_model_nas-rel_model_inion);
y(2,:)=-cross(rel_model_par-rel_model_nas,rel_model_nas-rel_model_Cz);
y(3,:)=cross(rel_model_par,rel_model_inion);
y(4,:)=cross(rel_model_pal,rel_model_Cz);
y(5,:)=-cross(rel_model_nas,rel_model_inion);
y(6,:)=-cross(rel_model_nas,rel_model_Cz);

 
for j=1:size(y,1),
	y(j,:)=y(j,:)/sqrt(dot(y(j,:),y(j,:)));
	end;

estdy=mean(y);
estdy=estdy/sqrt(dot(estdy,estdy));

dz=cross(dx,estdy);

dy=cross(dz,dx);


           

	     for i=1:Npoints,
		     rel_point=inpoints(i,:)-model_origin;
	             outpoints(i,:)=[dot(rel_point,dx) dot(rel_point,dy) dot(rel_point,dz)];
		     end; % for i






