%explores another constaint - number of zero lines

%idea: iterate over the ideal number of zero lines (i.e. susceptance set to
%zero)

%unfortunately the objective does not improve over changes in this.

function [constraint_number_of_empty_rows, test] = number_of_lines(big_P_vector, big_transfer_matrix, number_of_branches)
    
    Susceptance = sdpvar(number_of_branches,1);   
    
    %run once through to find typical value of non-zero susceptance
    residue = big_P_vector - (big_transfer_matrix * Susceptance);
    options = sdpsettings('solver','gurobi','verbose',1);
    Objective = norm(residue,2);
    constraint = [Susceptance>=0];
    optimize(constraint, Objective, options);
   % elonenorm = norm(Susceptance,1);
    
    number_nonzero = sum(double(Susceptance)>0.01);
    test = zeros(number_nonzero,2);
    test(:,1) = linspace(number_nonzero, 1, (number_nonzero ));
    Test_Susceptance = sdpvar(number_of_branches,1);
    
    for counter = 1:number_nonzero
        test_residue = big_P_vector - (big_transfer_matrix * Test_Susceptance);
        %find number of nonzero rows
        test_number_nonzero = sum(double(Test_Susceptance)>0.01);
        test_constraint = [Test_Susceptance>=0,test_number_nonzero <= test(counter,1)];
        Test_Objective = norm(test_residue,2);
        optimize(test_constraint, Test_Objective, options);
        test_number_nonzero = sum(double(Test_Susceptance)>0.01);
        test_residue = big_P_vector - (big_transfer_matrix * Test_Susceptance);
        Test_Objective = norm(test_residue,2);
        test (counter, 2) = double(Test_Objective); %to record the result
        counter
    end
    
    %index and corresponding lowest objective
    [Min_obj,Index] = min(test(:,2));
    
    constraint_number_of_empty_rows = test(Index,1);
    
    %incidence_matrix_new = new_incident_matrix(double(Susceptance), number_of_nodes,0.01);
end
