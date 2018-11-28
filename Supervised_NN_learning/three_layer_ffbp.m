function [epoch, TR_Target_Out_error_mat, TR_prop_correct,  TEST_Target_Out_error_mat, TEST_prop_correct] = three_layer_ffbp(av_category_separation)
%optional parameters : av_category_separation.  Set between 0 and 1

global MAX_ERROR
global INPUTS
global BIAS_VALUE
global CRITERION
global MAX_EPOCHS

NO_OF_TR_PATTERNS = 50;    % even no. half "high" patterns; half "low patterns"
NO_OF_TEST_PATTERNS = 20;  % ditto

if nargin == 1
  AV_SEPARATION = av_category_separation;
else
  AV_SEPARATION = 0.5;
end;

set_params;
init_wt_matrices;

low_tr_patterns = [rand(NO_OF_TR_PATTERNS/2, 2)-0.5, zeros(NO_OF_TR_PATTERNS/2,1)];
high_tr_patterns = rand(NO_OF_TR_PATTERNS/2,2)-0.5;
high_tr_patterns = [high_tr_patterns(:,1)+ AV_SEPARATION*sign(high_tr_patterns(:,1)), ...
                    high_tr_patterns(:,2)+ AV_SEPARATION*sign(high_tr_patterns(:,2))];
high_tr_patterns = [high_tr_patterns, ones(NO_OF_TR_PATTERNS/2,1)];

figure(1);
plot(low_tr_patterns(:,1), low_tr_patterns(:,2), 'rsquare', ...
  high_tr_patterns(:,1), high_tr_patterns(:,2), 'bo');
drawnow;

orig_tr_patterns = [low_tr_patterns; high_tr_patterns];
orig_tr_in_pats = orig_tr_patterns(:,1:INPUTS);
orig_tr_target_pats = orig_tr_patterns(:,INPUTS+1:end);

%here we randomize the order of the patterns to be learned.
tr_patterns(randperm(NO_OF_TR_PATTERNS), :) = orig_tr_patterns;
tr_in_pats = tr_patterns(:,1:INPUTS);
tr_target_pats = tr_patterns(:,INPUTS+1:end);

bias_vec = -1 * ones(size(tr_patterns,1),1);
Epoch_errors = MAX_ERROR*ones(1,NO_OF_TR_PATTERNS);
epoch = 1;
All_errors = [];

while max(Epoch_errors) > CRITERION && epoch < MAX_EPOCHS
  for pat = 1:NO_OF_TR_PATTERNS
    Input_pat = [tr_in_pats(pat, :), BIAS_VALUE];
    [Hid, Out] = tanh_feedforward(Input_pat);
    Target = tr_target_pats(pat,:); % take off the Bias Node
    bp_tanh_backprop(Input_pat, Hid, Out, Target);

    [Hid, Out] = tanh_feedforward(Input_pat);    
    error =  max(abs(Target - Out));
    Epoch_errors(pat) = error;
  end;
  All_errors = [All_errors, mean(Epoch_errors)];
  epoch = epoch + 1;
end;

TR_Target_Out_error_mat = [];

for tr_pat = 1:NO_OF_TR_PATTERNS
    Input_pat = [orig_tr_in_pats(tr_pat, :), BIAS_VALUE];
    [Hid, Out] = tanh_feedforward(Input_pat);
    Target = orig_tr_target_pats(tr_pat,:); % take off the Bias Node
    error =  max(abs(Target - Out));
    TR_Target_Out_error_mat = [TR_Target_Out_error_mat; [Target, Out, round(Out), error]];
end;

TR_Targets = TR_Target_Out_error_mat(:,1);
TR_Out = TR_Target_Out_error_mat(:,2);

TR_correct_test_ans = TR_Targets - round(TR_Out);
TR_prop_correct = length(find(TR_correct_test_ans == 0))/length(TR_Targets);


%testing the network
low_test_patterns = [rand(NO_OF_TEST_PATTERNS/2, 2)-0.5, zeros(NO_OF_TEST_PATTERNS/2,1)];
high_test_patterns = rand(NO_OF_TEST_PATTERNS/2,2)-0.5;
high_test_patterns = [high_test_patterns(:,1)+ AV_SEPARATION*sign(high_test_patterns(:,1)), ...
                    high_test_patterns(:,2)+ AV_SEPARATION*sign(high_test_patterns(:,2))];
high_test_patterns = [high_test_patterns, ones(NO_OF_TEST_PATTERNS/2,1)];

hold on
ADD_SPACE = 0.03;
plot(low_test_patterns(:,1), low_test_patterns(:,2), 'rsquare', 'MarkerFaceColor', 'r')
for pt = 1:NO_OF_TEST_PATTERNS/2
  text(low_test_patterns(pt,1)+ADD_SPACE, low_test_patterns(pt,2), num2str(pt), 'FontSize', 8);
end;
plot(high_test_patterns(:,1), high_test_patterns(:,2), 'bo', 'MarkerFaceColor', 'b');
for pt = 1:NO_OF_TEST_PATTERNS/2
  text(high_test_patterns(pt,1)+ADD_SPACE, high_test_patterns(pt,2), num2str(pt), 'FontSize', 8);
end;

test_in_pats = [low_test_patterns(:, 1:INPUTS); high_test_patterns(:, 1:INPUTS)];
test_target_pats = [low_test_patterns(:, INPUTS+1:end); high_test_patterns(:, INPUTS+1:end)];
hold off

TEST_Target_Out_error_mat = [];

for test_pat = 1:NO_OF_TEST_PATTERNS
    Input_pat = [test_in_pats(test_pat, :), BIAS_VALUE];
    [Hid, Out] = tanh_feedforward(Input_pat);
    Target = test_target_pats(test_pat,:); % take off the Bias Node
    error =  max(abs(Target - Out));
    TEST_Target_Out_error_mat = [TEST_Target_Out_error_mat; [Target, Out, round(Out), error]];
end;

TEST_Targets = TEST_Target_Out_error_mat(:,1);
TEST_Out = TEST_Target_Out_error_mat(:,2);

TEST_correct_test_ans = TEST_Targets - round(TEST_Out);
TEST_prop_correct = length(find(TEST_correct_test_ans == 0))/length(TEST_Targets);

% chronicles the learning of the network
figure(2);
plot(1:length(All_errors), All_errors);

return

% parameter-setting function
function set_params ()

global INPUTS;
global HIDDENS;
global OUTPUTS;
global MAX_EPOCHS

global CRITERION
global LEARNING_RATE
global MOMENTUM

global MAX_ERROR
global Temperature
global Fahlman_offset
global BIAS_VALUE

INPUTS = 2;
HIDDENS = 2;
OUTPUTS = 1;
 
MAX_EPOCHS = 2000;   
CRITERION = 0.1;
LEARNING_RATE = .01;
MOMENTUM = 0.9;    
MAX_ERROR = 2;

Temperature = 1;
Fahlman_offset = 0.1;
BIAS_VALUE = -1;

return

%auxiliary functions 
%>>>>>>>>>>>>>>>>>
function init_wt_matrices ()

global INPUTS;
global HIDDENS;
global OUTPUTS;

global IH_wts;
global HO_wts;
global IH_dwts;
global Old_IH_dwts;
global HO_dwts;
global Old_HO_dwts;

IH_wts = rand(INPUTS+1, HIDDENS) - 0.5;
HO_wts = rand(HIDDENS+1, OUTPUTS) - 0.5;

IH_dwts = zeros(INPUTS+1, HIDDENS);
Old_IH_dwts = zeros(INPUTS+1, HIDDENS);
HO_dwts = zeros(HIDDENS+1, OUTPUTS);
Old_HO_dwts = zeros(HIDDENS+1, OUTPUTS);

return;

%>>>>>>>>>>>>>>>>>
function a = tanh_squash(x)
% squashes the incoming activations between -1 and 1
global Temperature;
a = tanh(Temperature*x);
return;

%>>>>>>>>>>>>>>>>>
function a = tanh_deriv(squashed_output)
%derivative of the -1 to 1 tanh squashing fcn
global Fahlman_offset;
global Temperature;
a = Temperature * (1 - squashed_output.*squashed_output) + Fahlman_offset;
return

%>>>>>>>>>>>>>>>>>
function [Hid, Out] = tanh_feedforward (Input)

global IH_wts
global HO_wts

global BIAS_VALUE

Hid_net_in_acts = Input * IH_wts;
Hid_out_acts = tanh_squash(Hid_net_in_acts);

Hid_out_acts = [Hid_out_acts, BIAS_VALUE];
Output_net_in_acts = Hid_out_acts * HO_wts;
Output_out_acts = tanh_squash(Output_net_in_acts);

Hid = Hid_out_acts;
Out = Output_out_acts;

[Hid, Out];

%>>>>>>>>>>>>>>>>>
function bp_tanh_backprop(Input_pattern, Hidden_out_activations, Output_out_activations, Target)

global LEARNING_RATE;
global MOMENTUM;
global HIDDENS;

global IH_wts;
global HO_wts;
global IH_dwts;
global HO_dwts;
global Old_IH_dwts;
global Old_HO_dwts;

Errors_RAW = Output_out_activations - Target;
Errors_OUTPUT = Errors_RAW.*tanh_deriv(Output_out_activations);

dE_dw = Hidden_out_activations' * Errors_OUTPUT;
HO_dwts = -1 * LEARNING_RATE*dE_dw + MOMENTUM*Old_HO_dwts;
HO_wts = HO_wts + HO_dwts;
Old_HO_dwts = HO_dwts;

Errors_HIDDEN = Errors_OUTPUT * HO_wts';
Errors_HIDDEN = Errors_HIDDEN.*tanh_deriv(Hidden_out_activations);

dE_dw = Input_pattern' * Errors_HIDDEN(1:HIDDENS);  % no IH_dwts associated with the bias
IH_dwts = -1*LEARNING_RATE*dE_dw + MOMENTUM*Old_IH_dwts;
IH_wts = IH_wts + IH_dwts;
Old_IH_dwts = IH_dwts;

return


