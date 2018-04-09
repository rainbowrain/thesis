%% Set up the P and the transfer matrix in equation 10, simialr to DC_Power_Matrix.m 
function [big_P_vector, big_transfer_matrix, number_of_branches] = opt_setup(number_of_nodes, case_name)

    number_of_branches = nchoosek(number_of_nodes,2);
    %(m*n)x 1 Matrix (i.e. 'm' of P vectors, stacked on top one another)
    big_P_vector = zeros(number_of_branches * number_of_nodes, 1);

    % (m*n) x (m*m) Matrix
    big_transfer_matrix = sparse(number_of_branches * number_of_nodes, number_of_branches);
    
    % filling the values in

    for counter = 1 : number_of_branches
        
        % solve the Power and transfer matrix for each set of load
        [Real_Power_Vector,transfer_matrix] = DC_Power_Matrix(number_of_nodes, case_name, 1);
        
        % fill in the matrix P
        big_P_vector((counter-1)*number_of_nodes + 1:counter*number_of_nodes, 1) = Real_Power_Vector;
        
        % fill in the transfer matrix
        big_transfer_matrix((counter-1)*number_of_nodes + 1:counter*number_of_nodes,1:number_of_branches) = transfer_matrix;
        
    end

end
