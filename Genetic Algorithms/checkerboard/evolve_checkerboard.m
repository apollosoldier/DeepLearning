function best_pt = evolve_checkerboard(No_of_evol_cycles, rerun)

Pop_size = 100;
No_of_bits = 64;
Pop_old = round(rand(Pop_size, No_of_bits));
checkerboard_mat = repmat([0,1; 1,0], 4, 4);
checkerboard = checkerboard_mat(:)';

Fraction_to_keep = 0.1;
Mutation_rate = 0.001;
% No_of_evol_cycles = 20
No_of_items = size(Pop_old, 1);
item_size = size(Pop_old,2);
Reprod_pool = [];
All_fitnesses = [];
Best_fitness_vals = [];
Av_fitness_vals = [];

if nargin == 0
  No_of_evol_cycles = 100
end;
if nargin == 2
  seed_fid = fopen('evolve_seed.txt', 'r');
  seed = fscanf(seed_fid, '%f');
else
  seed = fix(1e6*sum(clock));
  seed_fid = fopen('evolve_seed.txt', 'w');
  fprintf(seed_fid, '%.0f', seed);
  fclose(seed_fid);
end;
rand('state', seed);

for evol_cycle = 1:No_of_evol_cycles
  All_fitnesses = [];
  Reprod_pool = [];
  item_no = 1;

  while item_no < No_of_items
    item = Pop_old(item_no, :);
    if sum(item(2:end)) ~= 0
      
      fitness = sum(eq(item, checkerboard))/16;
      All_fitnesses = [All_fitnesses; fitness];
      round_fitness = ceil(fitness);       
      copies_of_item_to_add = repmat(item, [round_fitness, 1]);
      Reprod_pool = [Reprod_pool; copies_of_item_to_add];
    end;
    item_no = item_no + 1;
  end;
  Reprod_pool_size = size(Reprod_pool, 1);

  Indexed_fitnesses_and_indices = [All_fitnesses, [1:length(All_fitnesses)]'];
  Sorted_fitnesses_and_indices = sortrows(Indexed_fitnesses_and_indices);
  Sorted_fitnesses_and_indices = flipud(Sorted_fitnesses_and_indices);

  if evol_cycle == 1
    Best_fitness = Sorted_fitnesses_and_indices(1,1);
  else
    Best_fitness_new = Sorted_fitnesses_and_indices(1,1);
    if Best_fitness_new > Best_fitness
      Best_fitness = Best_fitness_new;
    end;
  end;
  Best_fitness_vals = [Best_fitness_vals, Best_fitness];
  Av_fitness_vals = [Av_fitness_vals, mean(All_fitnesses)];
  No_to_keep = floor(Fraction_to_keep*No_of_items);
  Indices_to_keep = Sorted_fitnesses_and_indices(1:No_to_keep, 2);
  Best_items = Pop_old(Indices_to_keep, :);

  Best_vec = Best_items(1,:);

  Pop_new = Best_items;
  No_of_items_to_create = No_of_items - No_to_keep;

  for no = 1:No_of_items_to_create/2
    no_vec1 = ceil(Reprod_pool_size*rand());
    no_vec2 = ceil(Reprod_pool_size*rand());

    vec1 = Reprod_pool(no_vec1, :);
    vec2 = Reprod_pool(no_vec2, :);
    cut_pt = ceil ((length(vec1)-2)*rand())+1;  %-2 and +1 bcs don't want
    % empty strs
    new_vec1 = [vec1(1:cut_pt), vec2(cut_pt+1:end)];
    new_vec2 = [vec2(1:cut_pt), vec1(cut_pt+1:end)];

    Pop_new = [Pop_new; new_vec1; new_vec2];
  end;

  % mutate a few items a bit
  rand_mat = rand(size(Pop_new, 1), size(Pop_new, 2));
  mutation_indices = find(rand_mat <= Mutation_rate);
  mutation_mat = zeros(size(Pop_new));
  mutation_mat(mutation_indices) = 1;
  Pop_new = mod(Pop_new + mutation_mat, 2);

  %ensures only positive values since first num. in vec is 1.

  Pop_old = Pop_new;

if evol_cycle == 1
  figure(1);
  clf(1);
  figure(2);
  clf(2);
  pause;
end;
figure(1);
hold on
plot(1:evol_cycle, Av_fitness_vals);
axis([0,No_of_evol_cycles,1,5]);
hold off;

figure(2);
chkbd = reshape(Best_vec, [8,8]);
imagesc(chkbd);
  
end;

% figure(1);
% plot(1:No_of_evol_cycles, Av_fitness_vals);
% 
% figure(2);
% chkbd = reshape(Best_vec, [8,8]);
% imagesc(chkbd);


return





