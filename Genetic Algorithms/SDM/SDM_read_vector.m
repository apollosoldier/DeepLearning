function out_vec = SDM_read_vector (bit_vec, no_of_iterations)
global LOCATION_MATRIX
global CONTENT_MATRIX
global RADIUS

no_of_hard_locations = size(LOCATION_MATRIX, 1);

for iter = 1:no_of_iterations
   dist_vec = sum(abs(LOCATION_MATRIX - repmat(bit_vec, [no_of_hard_locations, 1])), 2);

   read_locations = find(dist_vec <= RADIUS);
   no_of_read_locations = length(read_locations);
   present_value_matrix = CONTENT_MATRIX(read_locations, :);

   history_vec = sum(present_value_matrix, 1);
   out_vec = history_vec;
   out_vec(find(history_vec >=0)) = 1;
   out_vec(find(history_vec < 0)) = 0;
   bit_vec = out_vec;
end;

return;