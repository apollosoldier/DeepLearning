
function [Reconstructed_input_mat] = generate_input(True_In, Random_input_mat, wt_mat)

no_items = size(Random_input_mat, 1);
no_inputs = size(Random_input_mat,2);
no_outputs = no_inputs;
Bias_node_val = 1;   %not used here
Learning_rate = 0.1;
no_epochs = 5;

% True_input_mat = (round(rand(no_items, no_inputs)));
% wt_mat = 2*rand(no_inputs, no_outputs) - 1;

Reconstructed_input_mat = zeros(no_items, no_inputs);

for i = 1:no_items
    Random_input_vec = Random_input_mat(i,:);
    for epoch = 1:no_epochs
        if epoch == 1
            squashed_vec = Random_input_vec*wt_mat;
        else
            squashed_vec = squash(Input_vec*wt_mat);
        end;
        
        Hidden_probs = squashed_vec;
        rand_vec = rand(size(Hidden_probs));
        Hidden_vec = double(rand_vec < Hidden_probs);
        
        Reconstructed_input_probs = squash(Hidden_vec * wt_mat');
        rand_vec = rand(size(Reconstructed_input_probs));
        Reconstructed_input_vec = double(rand_vec < Reconstructed_input_probs);
        
        Input_vec = Reconstructed_input_vec;        
    end;
    Reconstructed_input_mat(i, :) = Reconstructed_input_vec;
end;
% True_input_mat
Reconstructed_input_mat
fraction_present = check_results(True_In, Reconstructed_input_mat);
fprintf('Fraction of original patterns present: %f \n', fraction_present);
return


%auxiliary functions
function out = squash (x)
out = (1./(1+exp(-x)));
return;
