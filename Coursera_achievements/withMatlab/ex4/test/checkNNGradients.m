function checkNNGradients(lambda)
%CHECKNNGRADIENTS Creates a small neural network to check the
%backpropagation gradients
%   CHECKNNGRADIENTS(lambda) Creates a small neural network to check the
%   backpropagation gradients, it will output the analytical gradients
%   produced by your backprop code and the numerical gradients (computed
%   using computeNumericalGradient). These two gradient computations should
%   result in very similar values.

    if ~exist('lambda', 'var') || isempty(lambda)
        lambda = 0;
    end

    input_layer_size = 3;
    hidden_layer_size = 5;
    num_labels = 3;
    m = 5;

    % We generate some 'random' test data
    % Use "sin", to ensure that thata is always of the same values for debugging
    Theta1 = zeros(hidden_layer_size, 1 + input_layer_size);
    Theta1 = reshape(sin(1:numel(Theta1)), size(Theta1)) / 10;
    
    Theta2 = zeros(num_labels, 1 + hidden_layer_size);
    Theta2 = reshape(sin(1:numel(Theta2)), size(Theta2)) / 10;
    
    % Generate X
    X = zeros(m, input_layer_size);
    X = reshape(sin(1:numel(X)), size(X)) / 10;
    y  = 1 + mod(1:m, num_labels)';

    % Unroll parameters
    nn_params = [Theta1(:) ; Theta2(:)];

    % Short hand for cost function
    costFunc = @(p) nnCost(p, hidden_layer_size, num_labels, X, y, lambda);

    [~, grad] = costFunc(nn_params);
    numgrad = computeNumericalGradient(costFunc, nn_params);

    % Visually examine the two gradient computations. The two columns
    % you get should be very similar. 
    disp([numgrad grad]);
    fprintf(['The above two columns you get should be very similar.\n' ...
             '(Left-Your Numerical Gradient, Right-Analytical Gradient)\n\n']);

    % Evaluate the norm of the difference between two solutions.  
    % If you have a correct implementation, and assuming you used EPSILON = 0.0001 
    % in computeNumericalGradient.m, then diff below should be less than 1e-9
    diff = norm(numgrad - grad) / norm(numgrad + grad);

    fprintf(['If your backpropagation implementation is correct, then \n' ...
             'the relative difference will be small (less than 1e-9). \n' ...
             '\nRelative Difference: %g\n'], diff);
end
