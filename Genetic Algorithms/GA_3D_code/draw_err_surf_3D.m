function Z = draw_err_surf_3D(X,Y)
% set X, Y, from 1:0.2:50;

[X_mesh, Y_mesh] = meshgrid(X,Y);

% to draw the function
Z = (1./(X_mesh.^0.75 + Y_mesh.^0.75)).*cos(1.5*(X_mesh-10)/pi).*cos(1.5*(Y_mesh-10)/pi)- ...
           (0.01*(X_mesh-25)).^2 - (0.01*(Y_mesh-25)).^2 + 0.5;
Z = 1-Z;

surf(X_mesh, Y_mesh, Z, 'EdgeColor', 'none');

return;

