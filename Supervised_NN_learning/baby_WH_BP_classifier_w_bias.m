function [error, epoch, tr_prop_correct, test_prop_correct] = baby_WH_BP_classifier_w_bias(type_of_net, type_of_categories, av_category_separation)
% parameters
% type_of_net:  'WH' or 'BP'
% type_of_categories:  'easy' 'hard'
% optional parameter: av_category_separation.  Set between 0 and 1

CRITERION = 0.1;
NO_OF_TR_PATTERNS = 50;    % even no. half "high" patterns; half "low patterns"
NO_OF_TEST_PATTERNS = 20;  % ditto

if nargin == 3
  AV_SEPARATION = av_category_separation;
else
  AV_SEPARATION = 0.5;
end;

if strcmp(type_of_net, 'WH') == 1
  LEARNING_RATE = 0.01;
elseif strcmp(type_of_net, 'BP') == 1
  LEARNING_RATE = 0.1;
else
  disp('Not a known network');
  return;
end;

MAX_EPOCHS = 5000;
TEMPERATURE = 1;
FAHLMAN_OFFSET = 0.1;

sig = @(x) 1./(1+exp(-1*x));
if strcmp(type_of_categories, 'easy')
  low_tr_patterns = [rand(NO_OF_TR_PATTERNS/2, 2), ones(NO_OF_TR_PATTERNS/2,1)];
  high_tr_patterns = [rand(NO_OF_TR_PATTERNS/2,2)+AV_SEPARATION, zeros(NO_OF_TR_PATTERNS/2,1)];
elseif strcmp(type_of_categories, 'hard')
  low_tr_patterns = [rand(NO_OF_TR_PATTERNS/2, 2)-0.5, zeros(NO_OF_TR_PATTERNS/2,1)];
  high_tr_patterns = rand(NO_OF_TR_PATTERNS/2,2)-0.5;
  high_tr_patterns = [high_tr_patterns(:,1)+ AV_SEPARATION*sign(high_tr_patterns(:,1)), ...
                      high_tr_patterns(:,2)+ AV_SEPARATION*sign(high_tr_patterns(:,2))];
  high_tr_patterns = [high_tr_patterns, ones(NO_OF_TR_PATTERNS/2,1)];
else
  disp('Not a valid category type');
  return;
end;

figure(1);
plot(low_tr_patterns(:,1), low_tr_patterns(:,2), 'rsquare', ...
  high_tr_patterns(:,1), high_tr_patterns(:,2), 'bo');


patterns = [low_tr_patterns; high_tr_patterns];
patterns(randperm(NO_OF_TR_PATTERNS), :) = patterns;

bias_vec = -1 * ones(size(patterns,1),1);

%initializing the wts between -10 and 10
w1 = 20*rand()-10;
w2 = 20*rand()-10;
%and bias weight between -1 and 1
b =  2*rand()-1;

tr_pats = [patterns(:,1:2), bias_vec];
target_pats = patterns(:,3);
no_of_pats = size(patterns, 1);

% FF part
no_of_wts = size(tr_pats, 2);
wts_and_errors = ones(MAX_EPOCHS, no_of_wts);
All_errors = [];
epoch = 1;
error = CRITERION+1;

while error > CRITERION && epoch < MAX_EPOCHS
  cum_acts = tr_pats*[w1; w2; b];
  squashed_acts = sig(cum_acts);
 
  error = sum(0.5*(target_pats - squashed_acts).^2);
  All_errors = [All_errors, error];
  wts_and_errors(epoch,:) = [w1, w2, error];
  if strcmp(type_of_net, 'WH') == 1    %Widrow-Hoff
    delta = -1*LEARNING_RATE*(squashed_acts - target_pats)'*tr_pats;
  else   %Backprop
    deriv_sig = squashed_acts.*(1-squashed_acts) + FAHLMAN_OFFSET;
    delta = -1*LEARNING_RATE*(squashed_acts - target_pats)' .* deriv_sig' * tr_pats;
  end;

  w1 = w1+delta(1);
  w2 = w2+delta(2);
  b  =  b+delta(3);

  epoch = epoch+1;
end;

tr_outputs = round(sig(tr_pats*[w1; w2; b]));
correct_ans = tr_outputs-target_pats;
tr_prop_correct = length(find(correct_ans == 0))/length(tr_outputs);

if strcmp(type_of_categories, 'easy')
  low_test_patterns = [rand(NO_OF_TEST_PATTERNS/2, 2), ones(NO_OF_TEST_PATTERNS/2,1)];
  high_test_patterns = [rand(NO_OF_TEST_PATTERNS/2,2)+AV_SEPARATION, zeros(NO_OF_TEST_PATTERNS/2,1)];
else 
  low_test_patterns = [rand(NO_OF_TEST_PATTERNS/2, 2)-0.5, zeros(NO_OF_TEST_PATTERNS/2,1)];
  high_test_patterns = rand(NO_OF_TEST_PATTERNS/2,2)-0.5;
  high_test_patterns = [high_test_patterns(:,1)+ AV_SEPARATION*sign(high_test_patterns(:,1)), ...
    high_test_patterns(:,2)+ AV_SEPARATION*sign(high_test_patterns(:,2))];
  high_test_patterns = [high_test_patterns, ones(NO_OF_TEST_PATTERNS/2,1)];
end;

hold on
plot(low_test_patterns(:,1), low_test_patterns(:,2), 'rsquare', 'MarkerFaceColor', 'r');
plot(high_test_patterns(:,1), high_test_patterns(:,2), 'bo', 'MarkerFaceColor', 'b');
hold off

test_patterns = [low_test_patterns(:,1:2) ; high_test_patterns(:,1:2)];
test_patterns_w_bias = [test_patterns, -1*ones(NO_OF_TEST_PATTERNS, 1)];
test_outputs = round(sig(test_patterns_w_bias*[w1; w2; b]));
test_correct_responses = [ones(NO_OF_TEST_PATTERNS/2, 1); zeros(NO_OF_TEST_PATTERNS/2, 1)];
test_correct_ans = test_outputs-test_correct_responses;
test_prop_correct = length(find(test_correct_ans == 0))/length(test_outputs);

return;


