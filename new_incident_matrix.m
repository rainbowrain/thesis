function [incidence_matrix] = new_incident_matrix(Susceptance, number_of_nodes,threshold)
    
    %setting up the full matrix 
    node_to_node = combnk(1:number_of_nodes, 2); %m x 2 vector
    node_to_node = flipud(node_to_node);
    transposed_node_to_node = node_to_node';    %2 x m vector
    initial_matrix = graph(transposed_node_to_node(1,:), transposed_node_to_node(2,:));
    sparse_initial_matrix = -incidence(initial_matrix)';
    
    %set a square identity matrix - zero the rows of the identity matrix
    %with no corresponding line (i.e. susceptance below "threshold" as part of the input)
    m = size(node_to_node);
    I = eye (m(1));
    for counter = 1:m(1)
        if Susceptance(counter) < threshold
            I(counter, counter) = 0;
        end
    end
    
    %new matrix with the 
    incidence_matrix = I * sparse_initial_matrix;

end
