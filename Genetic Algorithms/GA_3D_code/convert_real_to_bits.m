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



