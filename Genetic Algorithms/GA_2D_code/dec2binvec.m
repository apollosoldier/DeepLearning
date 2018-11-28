function binvec = dec2binvec(dec)

bitstr = dec2bin(dec);
binvec = bitstr - '0';

return;
