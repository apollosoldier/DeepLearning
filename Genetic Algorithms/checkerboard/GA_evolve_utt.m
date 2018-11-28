function GA_evolve_utt(No_of_evol_cycles)
% use a no. of cycles = 1000

str = 'UTT';   % string GA will learn

Pop_size = 100;   % initial number of bitstrings
No_of_fitness_categories = 5;
Fraction_to_keep = 0.1;   % we keep the best 10% of each group of bitstrings
Mutation_rate = 0.001;    % we flip 1/1000 of the bits, randomly chosen

% Display information
NO_OF_ROWS = 8;     % the display will have 8 rows

% default number of evolve cycles
if nargin == 0
    No_of_evol_cycles = 600;
end;

rerun = input('Use random seed from previous run?  Y/N  (Do not forget single quotes!) \n');
% fill in code here:
% if rerun is empty, quit the program
% if 'Y' or 'y' is entered for input, then you use the seed for the
% previous run of the program
% if 'N' or 'n' is entered for input, then the program generates a new seed
% and stores that seed so that it can be recovered if we want to rerun the
% program exactly as it ran on the previous run

if isempty(rerun)
    return;
elseif rerun == 'Y' || rerun == 'y'
    seed_fid = fopen('evolve_seed.txt', 'r');
    seed = fscanf(seed_fid, '%f');
elseif rerun == 'N' || rerun == 'n'
    seed = fix(1e6*sum(clock));
    seed_fid = fopen('evolve_seed.txt', 'w');
    fprintf(seed_fid, '%.0f', seed);
    fclose(seed_fid);
else
    fprintf('Answer not recognized \n');
    return;
end;
% seed = 123456789;
rand('state', seed);


% str_mat is coded in bipolar (1, -1) units
% this produces a BINARY str_vec corresponding to the input str
[str_mat, str_mat_3D] = create_test_pattern_set(str);
str_mat_3D(1,:,:) = [];  % remove top and bottom row
str_mat_3D(end,:,:) = [];
str_vec = str_mat_3D(:)';
str_vec = 0.5*str_vec + 0.5;  %converts bipolar to binary

% No. of bits need to code the str_vec
No_of_bits = length(str_vec);

% Since the maximum possible error is No_of_bits, we generate a number of
% "fitness categories", default 5.  These categories correspond to how many
% bits we are from the str_vec.
Fitness_cat_size = No_of_bits/No_of_fitness_categories;

% we create our initial population of random bitstrings
% Pop_old is what I called the Initial Pool in my course notes
Pop_old = round(rand(Pop_size, No_of_bits));

% Main code starts here
No_of_items = size(Pop_old, 1);
item_size = size(Pop_old,2);
Reprod_pool = [];
All_fitnesses = [];
Best_fitness_vals = [];
Av_fitness_vals = [];

for evol_cycle = 1:No_of_evol_cycles        %no. of evolution cycles
    All_fitnesses = [];
    Reprod_pool = [];
    item_no = 1;
% measure the fitness of each item and make the number of copies of this
% item to put into the reproduction pool
    while item_no < No_of_items
        item = Pop_old(item_no, :);
        fitness = sum(eq(item, str_vec))/Fitness_cat_size;
        All_fitnesses = [All_fitnesses; fitness];
        round_fitness = ceil(fitness);
        copies_of_item_to_add = repmat(item, [round_fitness, 1]);
        Reprod_pool = [Reprod_pool; copies_of_item_to_add];
        item_no = item_no + 1;
    end;
    Reprod_pool_size = size(Reprod_pool, 1);
    
    % You now have the Reproduction Pool, called Reprod_pool
    % Create the Crossover_Pool
    % Add 1/1000 mutation
    % And rename the mutated Crossover Pool, the Pop_old and start the next
    % loop.
    
    % Create the Crossover Pool here
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
    
    Pop_old = Pop_new;
    
    figure(2);
    clf(2);
    utt = reshape(Best_vec, [NO_OF_ROWS,No_of_bits/NO_OF_ROWS]);
    imagesc(utt);
    drawnow;
    
end;

return





