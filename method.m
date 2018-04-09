clear
clc
% Make sure you add path for MATPOWER, Gurobi, and YALMIP! Note that the runpf document is 
% slightly modified (to extract information more easily, not the actual computation part) 

% modify as required
DC = 1; %set DC = 1 to run AC, DC = 0 to run DC
PROG_OBJ = 2; %norm(X,2) - to run 2-norm
case_name = case14;
number_of_nodes = 14;
bus_number = 0; %the bus node that we know of the parameters already, set to '0' if no constraint
% end of modify

number_of_branches = nchoosek(number_of_nodes,2);
number_of_runs = number_of_nodes;
options = sdpsettings('solver','gurobi','verbose',1);
additional_constraint =[];

%the bus node that we known already
constraint_set = set_constraint(case_name, number_of_nodes, bus_number);
set_index = constraint_set (:,1);

%% find 'DC' method susceptance vector
%run 3 times for safety
[P_DC, TM_DC, S_DC, R_DC] = Susceptance_Vector(number_of_nodes,case_name, 0, 1);
DC_error_norm1_1 = double(norm(P_DC - TM_DC*S_DC,1));
S_DC_holder = S_DC;
for DC_counter = 1:min(5,number_of_nodes - 1)
    
    [P_DC1, TM_DC1, S_DC1, R_DC1] = Susceptance_Vector(number_of_nodes,case_name, 0, 1);
    DC_error_norm1_2 =  double(norm(P_DC1 - TM_DC1*S_DC1,1));
    
    if DC_error_norm1_2 < DC_error_norm1_1
        DC_susceptance_value = S_DC1;
        DC_error_norm1_1 = DC_error_norm1_2;
    else
        DC_susceptance_value = S_DC_holder;
    end
    
    S_DC_holder = S_DC1;
end
%% AC Part
%Repetition of generation of random matrices until the lowest error (of at
%least "number_of_runs" = 4) 
[P_1, TM_1, number_of_branches] = opt_setup(number_of_nodes, case_name);
[one_norm_value, test_matrix] = one_norm_constraint(P_1, TM_1, number_of_branches, additional_constraint);
S_1 = sdpvar(number_of_branches,1);   
R_1 = P_1 - (TM_1* S_1);
B_norm = norm(S_1,1);
Objective = norm(R_1,2);
constraint = [S_1>=0, B_norm <= one_norm_value];

%additional constraint - with some known topology information - i.e. fix the bus
if isempty(constraint_set)
    disp("no constraint");
else
    additional_constraint = [constraint_set(:,2)* 0.95 <= S_1(set_index) <= constraint_set(:,2)* 1.05];
    constraint = [constraint, additional_constraint];
end

optimize(constraint, Objective, options);
R_1 = P_1 - (TM_1* S_1);
round1 = double(norm(R_1, 2));
counter = 0;
P_2 = P_1;
TM_2 = TM_1;
S_2 = S_1;
R_2 = R_1;

    while counter < 10
        S_21 = sdpvar(number_of_branches,1);  
        [P_21, TM_21, number_of_branches] = opt_setup(number_of_nodes, case_name);
        [one_norm_value2, test_matrix2] = one_norm_constraint(P_21, TM_21, number_of_branches, additional_constraint);
        R_21 = P_21 - (TM_21* S_21);
        B_norm2 = norm(S_21,1);
        Objective2 = norm(R_21,2);
        constraint2 = [S_21 >= 0, B_norm2 <= one_norm_value2];
        %additional constraint - with some known topology information - i.e. fix the bus
        
        if isempty(constraint_set)
            disp("no constraint");
        else
            additional_constraint = [constraint_set(:,2)* 0.95 <= S_21(set_index) <= constraint_set(:,2)* 1.05];
            constraint2 = [constraint2, additional_constraint];
        end

        optimize(constraint2, Objective2, options);
        R_21 = P_21 - (TM_21* S_21);
        round2 = double(norm(R_21, 2));
        if round2 < round1
            P_2 = P_21;
            TM_2 = TM_21;
            S_2 = S_21;
            R_2 = R_21;
            round1 = round2;
            counter = counter - 1;
        end
        counter = counter + 2;
    end
    
    %Optimal loads for this type of study:
    Optimal_Loads = P_2;
    
    %find most optimal 1-norm of susceptance matrix
    [constraint_one_norm_value, testpoint_vector] = one_norm_constraint(Optimal_Loads, TM_2, number_of_branches, additional_constraint);
    %Line removal of Susceptance less than "threshold"
    threshold = min(nonzeros((double(S_2))))+0.01;
    Objective_old = round1;
    new_objective= 0;

    
    iteration_counter = 1;
    
    while Objective_old > new_objective
     
        res_old = R_2;
        Objective_old = double(norm(res_old,PROG_OBJ));
        Susceptance_old = S_2;
        incidence_matrix = new_incident_matrix(double(S_2), number_of_nodes, threshold);
        fprintf('Iteration %d.\n',iteration_counter)
      %  disp(incidence_matrix);
        
        %set up spdvar for new 'B' vector
        Susceptance_new = sdpvar(number_of_branches,1);
        
        eye_matrix = new_large_eye_matrix(double(S_2), number_of_nodes, threshold);
        new_TM = sparse(TM_2* eye_matrix);
        test_norm = norm(Susceptance_new, 1);
        residue_new = P_2 - (new_TM * Susceptance_new);
       
        Objective_new = norm(residue_new,PROG_OBJ);
        constraint3 = [Susceptance_new>=0, test_norm <= constraint_one_norm_value];
        
        %additional constraint - with some known topology information - i.e. fix the bus
        if isempty(constraint_set)
            disp("no constraint");
        else
            additional_constraint = [constraint_set(:,2)* 0.95 <= Susceptance_new(set_index) <= constraint_set(:,2)* 1.05];
            constraint3 = [constraint3, additional_constraint];
        end

        optimize(constraint3, Objective_new, options);
        
        S_2 = Susceptance_new;
        R_2 = P_2 - TM_2 * S_2;
        new_objective = double(norm(R_2, PROG_OBJ))
        
        %Set new threshold
        nonzero_b = nonzeros(double(S_2));
        threshold = min(nonzero_b)+0.01;
        
        %Mark the number of iterations
        iteration_counter = iteration_counter + 1;
    end
    
    if Objective_old < new_objective
        value = double(Susceptance_old);
    else
        value = double(S_2);
    end
    
% RESULTS!!!    
value(value<0.01)=0;
    %Line removal of none-zero susceptances
A_matrix_test = new_incident_matrix(value, number_of_nodes,0.01);
actual = exact_susceptance(case_name, number_of_nodes);
A_matrix_act = new_incident_matrix(actual, number_of_nodes,0.01);

%end of methods

%% Results AC
[percent_wrong, number_of_failure_to_identify, number_of_imaginary_line, percent_failure_to_identify, percent_imaginary_line,location_imaginary_line, location_of_failure_to_identify] = Topology_Error(A_matrix_test,A_matrix_act);
[branch_number, error] = graph_MSE (actual, value,location_imaginary_line, location_of_failure_to_identify, number_of_nodes);
    
%% Results DC
actual = exact_susceptance(case_name, number_of_nodes);
A_matrix_act = new_incident_matrix(actual, number_of_nodes,0.01);
[percent_wrong, number_of_failure_to_identify, number_of_imaginary_line, percent_failure_to_identify, percent_imaginary_line,location_imaginary_line, location_of_failure_to_identify] = Topology_Error(new_incident_matrix(double(S_DC), number_of_nodes,0.01), A_matrix_act);
[branch_number, error] = graph_MSE (actual,double(S_DC) ,location_imaginary_line, location_of_failure_to_identify,number_of_nodes);
    