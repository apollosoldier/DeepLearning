function max_output_error = backprop(Target_pattern, Output_out_activations)
%this is the backprop algorithm (no attempt at optimization) for the
%2-layer auto-associator

global IO_wts;
global IO_dwts;
global Old_IO_dwts;
global Learning_rate 
global Momentum;

Errors_RAW = Output_out_activations - Target_pattern;
Errors_OUTPUT = Errors_RAW.*tanh_deriv(Output_out_activations);

Input_pattern = Target_pattern;
IO_dwts =  Errors_OUTPUT * [Input_pattern; -1]';

IO_dwts = -1 * Learning_rate*IO_dwts + Momentum*Old_IO_dwts;
IO_wts = IO_wts + IO_dwts;  
Old_IO_dwts = IO_dwts;

max_output_error = max(abs(Errors_RAW));    % a stringent error criterion is used
return;