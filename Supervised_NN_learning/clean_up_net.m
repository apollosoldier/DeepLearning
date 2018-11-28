function [epoch, TEST_Out, TR_errors, TR_prop_correct, ...
  TEST_errors, TEST_prop_correct] = ...
  clean_up_net(orig_tr_patterns, orig_tr_patterns_w_noise, no_of_hiddens, reint_wts)
%optional parameters : av_category_separation.  Set between 0 and 1
% good sets to demo this:
% tr_mat = 2*round(rand(10,10)) - 1;
% test_mat = [2*round(rand(5,10))-1 ; tr_mat(1:5, :)];   % first half not
%                                                        % seen, last five learned before
% no_of_hiddens = 4
NOISE_FACTOR = 0.2;

if nargin == 0
  orig_tr_patterns = 2*round(rand(10,10)) - 1;
  orig_tr_patterns_w_noise = orig_tr_patterns + NOISE_FACTOR*rand(10,10);
  no_of_hiddens = 4;
end;

global MAX_ERROR
global INPUTS
global BIAS_VALUE
global CRITERION
global MAX_EPOCHS

NO_OF_TR_PATTERNS = size(orig_tr_patterns, 1);    % even no. half "high" patterns; half "low patterns"
NO_OF_TEST_PATTERNS = size(orig_tr_patterns_w_noise, 1);  % ditto

no_of_inputs = size(orig_tr_patterns, 2);
set_params(no_of_inputs, no_of_hiddens);

if nargin == 0 || reint_wts == 1
  init_wt_matrices;
  save_wts;
else
  load_wts;
end;

orig_tr_in_pats = orig_tr_patterns;
orig_tr_target_pats = orig_tr_patterns;

%here we randomize the order of the patterns to be learned.
tr_patterns(randperm(NO_OF_TR_PATTERNS), :) = orig_tr_patterns;
tr_in_pats = tr_patterns;
tr_target_pats = tr_patterns;

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
  TR_Target_Out_error_mat = [TR_Target_Out_error_mat; [Target, Out, error]];
end;

TR_Targets = TR_Target_Out_error_mat(:,1:INPUTS);
TR_Out = TR_Target_Out_error_mat(:,INPUTS+1:2*INPUTS);
TR_errors = TR_Target_Out_error_mat(:, end);

TR_correct_test_ans = TR_Targets - TR_Out;
TR_prop_correct = length(find(sum(round(TR_correct_test_ans), 2) == 0))/NO_OF_TR_PATTERNS;

test_in_pats = orig_tr_patterns_w_noise;
test_target_pats = orig_tr_patterns;

TEST_Target_Out_error_mat = [];

for test_pat = 1:NO_OF_TEST_PATTERNS
  Input_pat = [test_in_pats(test_pat, :), BIAS_VALUE];
  [Hid, Out] = tanh_feedforward(Input_pat);
  Target = test_target_pats(test_pat,:); % take off the Bias Node
  error =  max(abs(Target - Out));
  TEST_Target_Out_error_mat = [TEST_Target_Out_error_mat; [Target, Out, error]];
end;

TEST_Targets = TEST_Target_Out_error_mat(:,1:INPUTS);
TEST_Out = TEST_Target_Out_error_mat(:,INPUTS+1:2*INPUTS);
Bipolar_round_TEST_Out = bipolar_round(TEST_Out);
TEST_errors = TEST_Target_Out_error_mat(:,end);

TEST_correct_test_ans = TEST_Targets - bipolar_round(TEST_Out);
TEST_prop_correct = length(find(sum(TEST_correct_test_ans,2) == 0))/NO_OF_TEST_PATTERNS;

% chronicles the learning of the network
figure(1);
plot(1:length(All_errors), All_errors);

return

% parameter-setting function
function set_params(no_of_inputs, no_of_hiddens)

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

INPUTS = no_of_inputs;
HIDDENS = no_of_hiddens;
OUTPUTS = no_of_inputs;

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

function out = bipolar_round(real_no_mat)    %real no. between -1 and 1
out = sign(real_no_mat).*ceil(sign(real_no_mat).*real_no_mat);
return;



function save_wts ()
global IH_wts;
global HO_wts;
global IH_dwts;
global HO_dwts;
global Old_IH_dwts;
global Old_HO_dwts;

save wt_file IH_wts IH_dwts HO_wts HO_dwts Old_IH_dwts Old_HO_dwts

return

function load_wts ()
global IH_wts;
global HO_wts;
global IH_dwts;
global HO_dwts;
global Old_IH_dwts;
global Old_HO_dwts;

load wt_file IH_wts IH_dwts HO_wts HO_dwts Old_IH_dwts Old_HO_dwts

return






