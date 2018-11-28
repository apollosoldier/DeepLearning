function [w1, w2, b, error, epoch] = baby_WH_BP_learn_w_bias(type_of_net, draw_err_surf)

CRITERION = 0.0001;

if strcmp(type_of_net, 'WH') == 1
    LEARNING_RATE = 0.001;
elseif strcmp(type_of_net, 'BP') == 1
    LEARNING_RATE = 0.01;
else
    disp('Not a known network');
    return;
end;

MAX_EPOCHS = 25000;
TEMPERATURE = 1;
FAHLMAN_OFFSET = 0.1;   %0.1

sig = @(x) 1./(1+exp(-1*x));

patterns = [0 0 .3
    0 1 0.3
    1 0 0.1
    1 1 .3];
bias_vec = -1 * ones(size(patterns,1),1);

%initializing the wts between -10 and 10
w1 = 20*rand()-10;
w2 = 20*rand()-10;
% and bias wt to rand no. between -1 and 1
b =  2*rand()-1;

in_pats = [patterns(:,1:2), bias_vec];
target_pats = patterns(:,3);
no_of_pats = size(patterns, 1);

% FF part
no_of_wts = size(in_pats, 2);
wts_and_errors = ones(MAX_EPOCHS, no_of_wts);
All_errors = [];
epoch = 1;
error = CRITERION+1;

while error > CRITERION && epoch < MAX_EPOCHS
    cum_acts = in_pats*[w1; w2; b];
    if strcmp('BP', type_of_net) == 1
        squashed_acts = sig(cum_acts);
    else
        squashed_acts = cum_acts;
    end;
    error = sum(0.5*(target_pats - squashed_acts).^2);
    All_errors = [All_errors, error];
    wts_and_errors(epoch,:) = [w1, w2, error];
    if strcmp(type_of_net, 'WH') == 1    %Widrow-Hoff
        delta = -1*LEARNING_RATE*(squashed_acts - target_pats)'*in_pats;
    else   %Backprop
        deriv_sig = squashed_acts.*(1-squashed_acts) + FAHLMAN_OFFSET;
        delta = -1*LEARNING_RATE*(squashed_acts - target_pats)' .* deriv_sig' * in_pats;
    end;
    w1 = w1+delta(1);
    w2 = w2+delta(2);
    b  =  b+delta(3);
    epoch = epoch+1;
end;

figure(4);
plot(1:epoch-1, All_errors);
fprintf('Error: %f \n', error);
return;


