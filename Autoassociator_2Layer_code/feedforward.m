function a = feedforward(Input_pattern)
% this is a two-layer feedforward auto-associator
  global IO_wts;
  
  Input_pattern = [Input_pattern; -1];   % add the bias node act. here

  Output_net_in_activations = IO_wts*Input_pattern;
  Output_out_activations = tanh_squash(Output_net_in_activations);

  a = Output_out_activations;
return