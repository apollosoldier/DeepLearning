function a = SDM_store_vector(bit_vec)

global LOCATION_MATRIX 
global CONTENT_MATRIX
global RADIUS

no_of_hard_locations = size(LOCATION_MATRIX, 1);
dist_vec = sum(abs(LOCATION_MATRIX - repmat(bit_vec, [no_of_hard_locations, 1])), 2);

store_locations = find(dist_vec <= RADIUS);
no_of_storage_locations = length(store_locations);

present_value_matrix = CONTENT_MATRIX(store_locations, :);
bipolar_vec = bit_vec;
bipolar_vec(find(bit_vec == 0)) = -1;                       % change 0's to -1
CONTENT_MATRIX(store_locations, :) = present_value_matrix + repmat(bipolar_vec, [no_of_storage_locations, 1]);
return;