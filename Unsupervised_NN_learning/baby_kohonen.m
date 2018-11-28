function baby_kohonen(repeat)

if nargin == 1
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
NO_OF_TR_PATTERNS = 50;
NO_OF_TEST_PATTERNS = 16;
AV_SEPARATION = 0.5;
OUTPUTS = 2;


low_tr_patterns = rand(NO_OF_TR_PATTERNS/2, 2);
high_tr_patterns = rand(NO_OF_TR_PATTERNS/2,2)+AV_SEPARATION;
tr_patterns = [low_tr_patterns; high_tr_patterns];

figure(1);
clf(1);
plot(low_tr_patterns(:,1), low_tr_patterns(:,2), 'rsquare', ...
  high_tr_patterns(:,1), high_tr_patterns(:,2), 'bo');
drawnow;

%we randomize the order of the patterns to be learned.
tr_patterns(randperm(NO_OF_TR_PATTERNS), :) = tr_patterns;

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

% test the network
low_test_patterns = rand(NO_OF_TEST_PATTERNS/2, 2);
high_test_patterns = rand(NO_OF_TEST_PATTERNS/2,2)+AV_SEPARATION;

test_patterns = [low_test_patterns; high_test_patterns];

figure(2)
clf(2);
hold on
  ADD_SPACE = 0.03;
  plot(low_test_patterns(:,1), low_test_patterns(:,2), 'rsquare', 'MarkerFaceColor', 'r')
  plot(high_test_patterns(:,1), high_test_patterns(:,2), 'bo', 'MarkerFaceColor', 'b');
hold off

test_winning_node = zeros(1,NO_OF_TEST_PATTERNS);

for p = 1:NO_OF_TEST_PATTERNS
  pat = test_patterns(p,:);
 % pat = pat/norm(pat,2);
  pat_repmat = repmat(pat, [OUTPUTS, 1]);
  diff_vec = sum((Wts - pat_repmat).^2,2);
  test_winning_node(p) = find(diff_vec == min(diff_vec));
end;

low_indices = find(test_winning_node == 1)
high_indices = find(test_winning_node == 2)

hold on
  plot(test_patterns(low_indices, 1), test_patterns(low_indices, 2), 'wx');
  drawnow;
hold off

return;




