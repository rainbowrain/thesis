% Function Purpose: To provide a measure of the accuracy of the topology
% estimation through the incidence matrix generated 
% Function input: The correct incidence matrix and the computed incidence
% matrix

function [percent_wrong, number_of_failure_to_identify, number_of_missed_line, percent_wrong_false_positive, percent_wrong_missed_line, location_m, location_a] = Topology_Error(Topology_Generated,Correct_Topology)

if size(Correct_Topology) ~= size(Topology_Generated)
    print("size does not match!")
    
else
    number_correct = 0;
    number_of_failure_to_identify = 0;
    number_of_missed_line = 0;
    
    %the number of rows is the number of possible lines
    [row,column] = size(Correct_Topology);
    
    %check if any row is zero - returns column vector that has '1' for
    %non-zero rows
    correct = any(Correct_Topology,2);
    model = any(Topology_Generated, 2);
    number_of_lines = sum(correct);
    
    %records the locations of the error
    location_m = [];
    location_a = [];
    for row_counter = 1:row
        if correct(row_counter) == model(row_counter)
            number_correct = number_correct + 1;
        elseif correct(row_counter) < model(row_counter)
            number_of_missed_line = number_of_missed_line +1;
            location_m = [location_m; row_counter];
        else
            number_of_failure_to_identify =number_of_failure_to_identify+1;
            location_a = [location_a; row_counter];
        end
    end
    number_wrong = number_of_failure_to_identify + number_of_missed_line;
    percent_wrong_false_positive = number_of_failure_to_identify/number_of_lines;
    percent_wrong_missed_line = number_of_missed_line/number_of_lines;
    percent_wrong = number_wrong/number_of_lines;
end

end
