function [w1, w2, error, epoch] = baby_WH_BP_learn(type_of_net, draw_err_surf)

CRITERION = 0; %0.0435;
if strcmp(type_of_net, 'WH') == 1
  LEARNING_RATE = 0.001;
elseif strcmp(type_of_net, 'BP') == 1
  LEARNING_RATE = 0.1;
else
  disp('Not a known network'); 
  return;
end;
  
MAX_EPOCHS = 10000;
TEMPERATURE = 1;
FAHLMAN_OFFSET = 0.1;

sig = @(x) 1./(1+exp(-1*x));

patterns = [0 0 .3
  0 1 0.3
  1 0 0.1
  1 1 .3];
    
%initializing the wts between -10 and 10
w1 = 20*rand()-10;
w2 = 20*rand()-10;

in_pats = patterns(:,1:2);
target_pats = patterns(:,3);
no_of_pats = size(patterns, 1);
 
% FF part 
wts_and_errors = ones(MAX_EPOCHS,3);
All_errors = [];
epoch = 1;
error = CRITERION+1;

while error > CRITERION && epoch < MAX_EPOCHS
  cum_acts = in_pats*[w1; w2];
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

  epoch = epoch+1;
end;

% open('error_contours.fig')
if draw_err_surf == 1
 draw_error_surface(type_of_net)
else
    clf(1);
end; 

fprintf('\n Hit any key to see gradient descent \n');

pause
figure(2)
hold on
for pt = 1:epoch-1
  if (pt == 1) || mod(pt,100) == 0
    plot(wts_and_errors(pt,2), wts_and_errors(pt,1), 'k*');
    drawnow;
  end;
end;
hold off

pause();
fprintf('Hit any key to see error curve \n');
figure(3);
hold on
plot(1:epoch-1, All_errors);
hold off
fprintf('Error: %f \n', error);
return;


