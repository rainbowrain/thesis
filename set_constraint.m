%returns a vector with actual values of the susceptance of the lines
%that is connected to the specified node
function [constraint] = set_constraint(case_name, number_of_nodes, bus_number)

%output description: column 1 is the index, column 2 is the value
number_of_branches = nchoosek(number_of_nodes,2);
testcase = case_name;

%copying susceptance information from the case file
branch_to_copy = testcase.branch(:,1) == bus_number | testcase.branch(:,2) == bus_number;
branch_of_interest = testcase.branch(branch_to_copy, 1:4);
[m,~] = size(branch_of_interest);   %find the number of rows (i.e. number of actual branches connected to the bus)

%add the information to complete set of branches
to_from = combnk(1:number_of_nodes, 2); 
if to_from(1,1) > to_from(2,1)
    to_from = flipud(to_from);
end
total_branch = zeros(number_of_branches, 4) + 0.005*ones(number_of_branches, 4);
total_branch(:,1:2) = to_from;
from = total_branch(:,1);
to = total_branch(:,2);
total_branch(:,3) = (to - from) + (from - ones(number_of_branches,1)) / 2 .* (number_of_nodes .* 2 - from);

%match the infomration from branch_of_interst to total_branch

%find the row index in total_branch that the branch_of_interest relates to
for counter = 1:m
    from_node = branch_of_interest(counter, 1);
    to_node = branch_of_interest(counter, 2);
    B_index = abs(from_node - to_node) + (min(from_node,to_node) - 1) / 2 * (number_of_nodes * 2 - min(from_node,to_node));
    total_branch (B_index, 4) = 1./branch_of_interest(counter, 4);
end

%remove branches not related to that bus
branch_to_remove = total_branch(:,1) ~= bus_number & total_branch(:,2) ~= bus_number;
total_branch(branch_to_remove, :) = [];

%return the constraint
constraint = total_branch(:,3:4);

end
