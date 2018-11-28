function SDM_run(test_str, Noise_factor)

global INPUTS
global GRID_WIDTH
global GRID_HEIGHT

global LOCATION_MATRIX
global CONTENT_MATRIX
global RADIUS

if nargin ==1
  NOISE_FACTOR = 0.075;
elseif nargin == 2
  NOISE_FACTOR = Noise_factor;
end;

GRID_WIDTH = 10;
GRID_HEIGHT = 10;
INPUTS = GRID_WIDTH * GRID_HEIGHT;

No_of_bits = INPUTS;
No_of_hard_locations = 10000;
Fraction_in_ball = 0.001;
No_of_iterations = 5;

LOCATION_MATRIX = round(rand(No_of_hard_locations, No_of_bits));
CONTENT_MATRIX = zeros(No_of_hard_locations, No_of_bits);
RADIUS = SDM_nCk(No_of_bits, Fraction_in_ball);


[Input_alphabet, Matrix_alphabet] = SDM_create_input_patterns(' abcdefghijklmnopqrstuvwxyz');
No_of_all_letters = size(Input_alphabet, 2);

[Input_pattern_set, Matrix_pattern_set] = SDM_create_input_patterns(test_str);
No_of_patterns = size(Input_pattern_set, 2);

for i = 1:No_of_all_letters
  Input_pattern = 0.5*Input_alphabet(:,i) + 0.5;  %converts bipolar input to binary
  SDM_store_vector(Input_pattern');
end;

cols = ceil(sqrt(No_of_patterns));
rows = cols;

figure(1);
clf(1);
for i = 1:No_of_patterns
  subplot(rows, cols, i);
  imagesc(Matrix_pattern_set(:,:,i));
end;

for i = 1:No_of_patterns
  Input_pattern = 0.5*Input_pattern_set(:,i) + 0.5;  %converts bipolar input to binary
  SDM_store_vector(Input_pattern');
end;

figure(2); clf(2);
figure(3); clf(3);

for i = 1:No_of_patterns
  % add noise to pattern
  noise = rand(INPUTS, 1);
  flip_index = find(noise > (1-NOISE_FACTOR));
  noise_vec = zeros(INPUTS, 1);
  noise_vec(flip_index) = 1;
  Binary_Input_pattern = 0.5*Input_pattern_set(:,i) + 0.5;

  figure(2);
  %print noisy pattern
  subplot(rows, cols, i)
  fuzzy_letter = mod(Binary_Input_pattern + noise_vec, 2);
  display_figure(fuzzy_letter);

  figure(3);
  %print cleaned-up pattern
  subplot(rows, cols, i);
  fantasy = SDM_read_vector(fuzzy_letter', No_of_iterations);
  display_figure(fantasy);
end;

return;


%>>>>>>>>>>>>>>>>>
function a = display_figure(figure)
global INPUTS
global GRID_WIDTH GRID_HEIGHT

matrix_pat = reshape(figure(1:INPUTS), GRID_HEIGHT, GRID_WIDTH);
imagesc(matrix_pat);
return;

function bit_radius = SDM_nCk (N, fraction)
% you have a space of N bits, thus size 2^N
% for a given bit str S, you want to know what hamming radius about it you
% need to get "fraction" of the other bitstrings within it.  So, if you
% have bitstrs of length 100, and you want 1% of all bitstrs to be in
% the nhbrhood, you need a radius of 40 bits.  In other words, in a
% universe of bitstrs 100 bits long, balls of radius 40 bits contain 1% of
% all bitstrings.
Yvec = [];
Old_Y = 0;
for k= 1:N
  Y = nchoosek(N, k)/(2^N);
  if (Old_Y < fraction) && (Y >= fraction)
    bit_radius = k;
  end;
  Yvec = [Yvec, Y];   %used to plot the function;
  Old_Y = Y;
end;
return;