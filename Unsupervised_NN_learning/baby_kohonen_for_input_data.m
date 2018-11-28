function baby_kohonen_for_input_data(tr_file, test_file, repeat)
% baby_kohonen_for_input_data('training_data/tr_control_patient.txt', ...
% 'test_data/test_1.txt');


if nargin == 3
  seed_fid = fopen('seed.txt', 'r');
  seed = fscanf(seed_fid, '%f');
else
  seed = fix(1e6*sum(clock));
  seed_fid = fopen('seed.txt', 'w');
  fprintf(seed_fid, '%.0f', seed);
  fclose(seed_fid);
end;
rand('state', seed);

LEARNING_RATE = 0.1;
NO_OF_CYCLES = 20;
OUTPUTS = 2;

tr_patterns = load(tr_file);
NO_OF_TR_PATTERNS = size(tr_patterns,1);

%we randomize the order of the patterns to be learned.
%tr_patterns(randperm(NO_OF_TR_PATTERNS), :) = tr_patterns;

Input_mat = tr_patterns;

INPUTS = size(Input_mat, 2);
NO_OF_PATS = size(Input_mat,1);

Wts = rand(OUTPUTS, INPUTS);

for cycle = 1:NO_OF_CYCLES
  for p = 1:NO_OF_TR_PATTERNS
    pat = Input_mat(p,:);
    pat_repmat = repmat(pat, [OUTPUTS, 1]);
    diff_vec = sum((Wts - pat_repmat).^2, 2);
    winning_node = find(diff_vec == min(diff_vec));
    
    old_wt = Wts(winning_node,:);
    dist_old = sum((pat - old_wt).^2);
    
    Delta_Wts = pat - Wts(winning_node, :);
    Wts(winning_node, :) = Wts(winning_node, :) + LEARNING_RATE*Delta_Wts;
  end;
end;

test_patterns = load(tr_file);
NO_OF_TEST_PATTERNS = size(test_patterns, 1);

test_winning_node = zeros(1,NO_OF_TEST_PATTERNS);

for p = 1:NO_OF_TEST_PATTERNS
  pat = test_patterns(p,:);
  pat_repmat = repmat(pat, [OUTPUTS, 1]);
  diff_vec = sum((Wts - pat_repmat).^2,2);
  test_winning_node(p) = find(diff_vec == min(diff_vec));
end;

gp1 = find(test_winning_node == 1);
gp2 = find(test_winning_node == 2);

if mean(gp1) < mean(gp2)
  fprintf('\n gp1 are controls \n gp2 are patients\n');
else 
  fprintf(' gp1 are patients \n gp2 are controls\n');
end;

test_patterns = load(test_file);
NO_OF_TEST_PATTERNS = size(test_patterns, 1);

test_winning_node = zeros(1,NO_OF_TEST_PATTERNS);

for p = 1:NO_OF_TEST_PATTERNS
  pat = test_patterns(p,:);
  pat_repmat = repmat(pat, [OUTPUTS, 1]);
  diff_vec = sum((Wts - pat_repmat).^2,2);
  test_winning_node(p) = find(diff_vec == min(diff_vec));
end;

test_gp1 = find(test_winning_node == 1)
test_gp2 = find(test_winning_node == 2)
return;




