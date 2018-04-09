%stand-alone function that gets the optimal norm(B) value from a case file
function [constraint_one_norm_value, testpoint_vector] = one_norm_constraint(big_P_vector, big_transfer_matrix, number_of_branches,additional_constraint)
    
    Susceptance = sdpvar(number_of_branches,1);   
    
    %run once through to find typical value of norm(susceptance)
    residue = big_P_vector - (big_transfer_matrix * Susceptance);
    options = sdpsettings('solver','gurobi','verbose',1);
    Objective = norm(residue,2);
    constraint = [Susceptance>=0, additional_constraint];
    optimize(constraint, Objective, options);
    B_norm = norm(Susceptance,1);
    
    %run again and set B_norm as a constraint - and look at the objectives
    %tested constraint values will be 20 points from B_norm / 2 to B_norm * 2
    number_points = 10;
    testpoint_vector = zeros(number_points,3);
    testpoint_vector(:,1) = linspace(double(B_norm)/2, double(B_norm), number_points);
    Test_Susceptance = sdpvar(number_of_branches,1);
    
    for counter = 1:number_points
        test_residue = big_P_vector - (big_transfer_matrix * Test_Susceptance);
        test_norm = norm(Test_Susceptance,1);
        test_constraint = [Test_Susceptance>=0,test_norm <= testpoint_vector(counter,1), additional_constraint];
        Test_Objective = norm(test_residue,2);
        optimize(test_constraint, Test_Objective, options);
        testpoint_vector (counter, 2) = double(Test_Objective); %to record the result
        testpoint_vector (counter, 3) = sum(double(Test_Susceptance)>0.01); %number of non-zeros
    end
    
    %index and corresponding lowest objective
    [Min_obj,~] = min(testpoint_vector(:,2));
    other_vector = testpoint_vector(:,2)==Min_obj;
    constraint_one_norm_value =  min(testpoint_vector(other_vector,1));
    
    %incidence_matrix_new = new_incident_matrix(double(Susceptance), number_of_nodes,0.01);
end
