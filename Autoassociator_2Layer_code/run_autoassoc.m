function [patterns_seen, patterns_not_seen] = run_autoassoc()

set_assoc_params;

global CRITERION;
global MAX_EPOCHS;
global INPUTS;
global OUTPUTS;

Input_pattern_mat = load('seen_patterns.txt');
Test_pattern_mat = load('test_patterns.txt');
% comparing COLUMN VECTORS in seen_patterns and test_patterns

INPUTS = size(Input_pattern_mat, 1);
OUTPUTS = INPUTS;
no_of_Input_patterns = size(Input_pattern_mat, 2);

init_wts;
% convert to bipolar input
Input_pattern_mat = 2*Input_pattern_mat -1;

Max_error = 2*size(Input_pattern_mat, 1);
epoch_ctr = 1;
while (Max_error > CRITERION) && (epoch_ctr < MAX_EPOCHS)
  for pat_no = 1:no_of_Input_patterns
    Input_pattern = Input_pattern_mat(:, pat_no);
    Out_activations = feedforward(Input_pattern);
    Target_pattern = Input_pattern;
    Error = backprop(Target_pattern, Out_activations);
    if pat_no == 1
      Max_error = Error;
    else
      if Error > Max_error
        Max_error = Error;
      end;
    end;
  end;
  epoch_ctr = epoch_ctr + 1;
end;

Test_pattern_mat = 2*Test_pattern_mat - 1;
no_of_Test_patterns = size(Test_pattern_mat, 2);

patterns_seen = [];
patterns_not_seen = [];
for test_pat_no = 1:no_of_Test_patterns
  Test_pattern = Test_pattern_mat(:,test_pat_no);
  Out_activations = feedforward(Test_pattern);
  E = max(abs(Test_pattern - Out_activations));
  if E < CRITERION
   patterns_seen = [patterns_seen, test_pat_no];
  else
   patterns_not_seen = [patterns_not_seen, test_pat_no];
  end;
end;
patterns_seen
patterns_not_seen
return;


