function f = err_surf(X)

%f = (1./(X.^0.75)).*cos(X/pi)+0.1*log(2*X.^2/pi);
X(X<0) = 0;
X(X>100) = 100;
% f = (1./(X.^0.75)).*cos(1.5*X/pi)-(0.01*(X-50)).^2 + 0.5;
f = (1./(X.^0.75)).*cos(1.5*X/pi) + 0.5;


plot(X, f);

return