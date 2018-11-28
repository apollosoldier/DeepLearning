function out = draw_error_surface (net_type, Pattern_mat)

sig = @(x) 1./(1+exp(-x));


if nargin == 1
    patterns = [0 0 .3
        0 1 0.3
        1 0 0.1
        1 1 .3];
else
    patterns = Pattern_mat;
end;

no_of_possible_w1_wts = 500;
no_of_possible_w2_wts = 500;
% no_of_possible_w1_wts = 200;
% no_of_possible_w2_wts = 200;
errsurf = ones(no_of_possible_w1_wts, no_of_possible_w2_wts);

range_w1 = linspace(-10,10, no_of_possible_w1_wts);   %-3, 8
range_w2 = linspace(-10,10, no_of_possible_w2_wts);   %-5,3  nice graph

in_pats = patterns(:,1:2);
target_pats = patterns(:,3);

for i = 1:no_of_possible_w1_wts
    for j = 1:no_of_possible_w2_wts
        w1 = range_w1(i);
        w2 = range_w2(j);
        cum_acts = in_pats*[w1; w2];
        if strcmp(net_type, 'BP')
            squashed_acts = sig(cum_acts);
            delta_all_pats = 0.5*(target_pats - squashed_acts).^2;
        else
            delta_all_pats = abs(target_pats-cum_acts);
        end;
        errsurf(i,j) = sum(delta_all_pats);
    end;
end;

surf(range_w1, range_w2, errsurf, 'EdgeColor', 'None');
axis([-10,10,-10,10,0, 1.0]);
colormap jet; %prism   %hsv  %flag  %pink
colorbar;
figure(2)
contour(range_w1, range_w2, errsurf, 100);
colorbar;
% switch from hsv to jet, prism or pink when finding the hole...

return;




