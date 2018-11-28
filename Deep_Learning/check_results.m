function fraction_orig_patterns_present = check_results(true_mat, generated_mat)

BIGNUM = 100;
size_V = size(true_mat, 1);
size_v = size(generated_mat, 1);
pat_found_ctr = 0;
for V_no = 1:size_V
    
    V_pat = true_mat(V_no, :);
    pattern_found = 0;
    v_no = 1;
    while v_no <= size(generated_mat,1)
        Gen_pat = generated_mat(v_no, :);
        pattern_found = all(eq(V_pat, Gen_pat));
        if pattern_found == 1
            pat_found_ctr = pat_found_ctr+1;
            size_generated_mat = size(generated_mat,1);
            if v_no < size_generated_mat
                for j = v_no+1 : size_generated_mat
                    remaining_pat = generated_mat(j,:);
                    if all(eq(V_pat, remaining_pat))
                        generated_mat(j,1) = BIGNUM;
                    end;
                end;
                break;
            end;
        end;
        [ix, iy] = find(generated_mat == BIGNUM);
        generated_mat(ix,:) = [];
        v_no = v_no+1;
    end;
end;
fraction_orig_patterns_present = pat_found_ctr/size_V;
return;



