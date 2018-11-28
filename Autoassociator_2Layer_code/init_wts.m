function a = init_wts

  global INPUTS 
  global OUTPUTS;

  global IO_wts;
  global IO_dwts;
  global Old_IO_dwts;

  % for the autoassociator
  IO_wts = 2*rand(OUTPUTS, INPUTS+1) - 1;
  IO_dwts = zeros(OUTPUTS, INPUTS+1);
  Old_IO_dwts = zeros(OUTPUTS, INPUTS+1);
  
 return;
