%Function looks at the mean-square-error of the susceptance and graphs it
%input: the correct and calculated Susceptance Vector

function [branch_number, error] = graph_MSE (correct, calculated, location_imaginary_line, location_of_failure_to_identify, number_of_node)

% correct1 = correct(any(correct,2),1) %truncation
% calculated1 = calculated(any(calculated,2),1)%truncation
[r,~] = size(correct);
branch_number = linspace(1,r,r); 
error = zeros(r,1);
for counter = 1:r
% error(counter) = immse(correct(counter), calculated(counter));
error(counter) = abs(correct(counter) - calculated(counter))/correct(counter);
if error(counter) == 1
    error(counter) = 0;
end

end

img_line = [location_imaginary_line error(location_imaginary_line)]
missed_line = [location_of_failure_to_identify error(location_of_failure_to_identify)]
[m1, ~] = size(img_line);

figure
b = bar (branch_number, error);
title (['Susceptance Error of ',num2str(number_of_node),'-Bus Case']);
xlabel ('line number');
ylabel ('error');
legend('error');
if size(img_line) ~= [0,0]
    hold on
    img = plot (img_line (:,1), zeros(m1,1), 'Marker','*');
    legend('error','line does not exist');

    if size(missed_line) ~= [0,0]
        hold on
        miss = plot (missed_line(:,1), missed_line(:,2),'Marker','o');
       legend('error','line does not exist','line failed to be identified');
    end

elseif size(missed_line) ~= [0,0]
    hold on
    miss = plot (missed_line(:,1), missed_line(:,2),'Marker','o');
   legend('error','line failed to be identified');
end
hold off 

figure
bar (branch_number,[correct calculated]);
title (['Susceptance of ',num2str(number_of_node),'-Bus Case']);
xlabel ('line number');
ylabel ('Susceptance');
legend('Actual','Model');


%identify the false positive etc




end

