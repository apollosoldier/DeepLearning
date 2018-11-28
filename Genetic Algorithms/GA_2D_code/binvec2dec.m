
function bitstr = binvec2dec(binvec)

str = num2str(binvec);
str(isspace(str)) = '';
bitstr = bin2dec(str);

return;