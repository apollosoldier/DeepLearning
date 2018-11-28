 
function [True_In, Reconstructed_In, wt_mat] = RBM(Input_mat)
global Learning_rate

Learning_rate = 0.01;

no_items = size(Input_mat, 1);
no_inputs = size(Input_mat,2);
no_outputs = no_inputs;
Bias_node_val = 1;   %not used here

no_epochs = 10000;

wt_mat = 2*rand(no_inputs, no_outputs) - 1;
Input_mat_orig = Input_mat;

for epoch = 1:no_epochs
    [Reconstructed_In, Reconstructed_hidden_mat, wt_mat] = RBM_wt_change(Input_mat_orig, wt_mat);
end;

True_In = Input_mat_orig
Reconstructed_In
return


%auxiliary functions
function out = squash (x)
out = (1./(1+exp(-x)));
return;

function [Reconstructed_In, Reconstructed_hidden_mat, wt_mat] = RBM_wt_change(Input_mat, wt_mat)
global Learning_rate

no_items = size(Input_mat, 1);
squashed_mat = squash(Input_mat*wt_mat);
Hidden_probs = squashed_mat;
rand_mat = rand(size(Hidden_probs));
Hidden_mat = (rand_mat < Hidden_probs);

Reconstructed_input_probs = squash(Hidden_mat * wt_mat');
rand_mat = rand(size(Reconstructed_input_probs));
Reconstructed_In = (rand_mat < Reconstructed_input_probs);

Reconstructed_hidden_probs = squash(Reconstructed_In * wt_mat);
rand_mat = rand(size(Reconstructed_hidden_probs));
Reconstructed_hidden_mat = (rand_mat < Reconstructed_hidden_probs);

for i=1:no_items
    V = Input_mat(i, :);
    H = double(Hidden_mat(i, :));
    v = double(Reconstructed_In(i,:));
    h = double(Reconstructed_hidden_mat(i,:));
    
    wt_delta = Learning_rate*(V'*H - v'*h);
    wt_mat = wt_mat + wt_delta;
end;

return;
