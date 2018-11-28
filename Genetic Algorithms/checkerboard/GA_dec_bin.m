function [vec_bin]=GA_dec_to_bin(init_val,bin_length)
vec_bin=char(dec2bin(init_val,bin_length))-'0';



et


function [dec_value]=GA_bin_to_dec(bin_vect)
dec_value=bin2dec(char(bin_vect+'0'));