function R = convert_bits_to_real(bitvec, no_of_dec)

sign_bit = bitvec(1);
num_bitvec = bitvec(2:end);

if sign_bit == 0
  dec = -1*binvec2dec(fliplr(num_bitvec));
else
  dec = binvec2dec(fliplr(num_bitvec));
end;

R = dec/(10^no_of_dec);

return;