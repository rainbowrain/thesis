%% Returns the P and the "transfer matrix"(i.e. the f(incidence matrix, angle)) in P = f(incidence matrix, angle) * B
% P is just passing through from Real_Power_SDP_AC.m
function [Real_Power_Vector,transfer_matrix] = DC_Power_Matrix(number_of_nodes, case_name,DC)
    %load value is randomized
    new_case = load_generator(number_of_nodes, case_name);
    
    %Run the power flow analysis with random loads and get parameters
    
    if DC == 0
        %Run DC
        [Real_Power_Vector,Bus_Voltage_pu, Bus_Angle] = Real_Power_SDP_DC(new_case, number_of_nodes);
    else
        %Run the AC
        [Real_Power_Vector,Bus_Voltage_pu, Bus_Angle] = Real_Power_SDP_AC(new_case, number_of_nodes);
        
    end
    Real_Power_Vector;
    Bus_Angle;
    %incidence matrix
    node_to_node = combnk(1:number_of_nodes, 2); %m x 2 vector
    node_to_node = flipud(node_to_node);
    transposed_node_to_node = node_to_node';    %2 x m vector
    initial_graph = graph(transposed_node_to_node(1,:), transposed_node_to_node(2,:));
    sparse_incidence_matrix = -incidence(initial_graph)';
 
    %Angle_Delta Matrix (m x m)
    Angle_Delta_Matrix = diag(sparse_incidence_matrix * Bus_Angle);
    %disp(full(Angle_Delta_Matrix))

    %DC P = Transfer matrix * B
    %Transfer Matrix (size: n x m) = [Angle Matrix * Incidence Matrix]'
    transfer_matrix = (Angle_Delta_Matrix * sparse_incidence_matrix)';
    
end

    

