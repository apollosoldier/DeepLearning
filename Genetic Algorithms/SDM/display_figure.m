function a = display_figure(figure)
global INPUTS
global GRID_WIDTH GRID_HEIGHT

matrix_pat = reshape(figure(1:INPUTS), GRID_HEIGHT, GRID_WIDTH);
imagesc(matrix_pat);


return;