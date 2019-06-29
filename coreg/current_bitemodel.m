function [bite_model,distall]=current_bitemodel();
%% function [bite_model,distall]=current_bitemodel();
%% returns the coordinates of model bitebar points
%% as measured most recently
%% format [par;inion; nas; Cz; pal];
%% distall is mean error per bitebar point from the fitting process

disp('Using bitebar model from March 18th 2002');
load('/mnt/home/users/megadmin/mfiles/coreg/bitebars/bite_model_March18_2002.mat','av_bitebar_model','distall');



bite_model=av_bitebar_model;
