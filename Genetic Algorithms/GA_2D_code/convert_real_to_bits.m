function bin_rep = convert_real_to_bits (R, no_of_dec)

global BIN_LEN;

R_big = round(abs(R)*10^no_of_dec);
bin_rep = fliplr(dec2binvec(R_big, BIN_LEN-1));
sign_R = sign(R);
if sign_R >= 1
  bit = 1;
else 
  bit = 0;
end;
bin_rep = [bit, bin_rep];

return;

% bitstring to bitvec
%      s='1011001';
%      n=s-'0'

% bitvec to bitstring;
x = [1 0 0 0 0 0 0 0];
% convert x to a string array
str_x = num2str(x);
% remove the spaces in the string, so it 
% becomes '10000000'
str_x(isspace(str_x)) = '';
% now use BIN2DEC to convert the binary 
% string to a decimal number
y = bin2dec(str_x);
