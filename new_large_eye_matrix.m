function [eye_matrix] = new_large_eye_matrix(Susceptance, number_of_nodes,threshold)
    
  %set a square identity matrix - zero the rows of the identity matrix
    %with susceptance below "threshold"
    m = nchoosek(number_of_nodes,2);
    I = eye (m(1));
    for counter = 1:m(1)
        if Susceptance(counter) <= threshold
            I(counter, counter) = 0;
        end
    end
    
    %stack the matrix
    eye_matrix_t = sparse(number_of_nodes*m, number_of_nodes*m);
    
    %New eye matrix that can multiply to the existing big transfer matrix
    %to get rid of rows
    for counter2 = 1:number_of_nodes
        eye_matrix_t ((counter2-1)*m + 1 : counter2 * m, (counter2-1)*m + 1 : counter2 * m) = I;
    end
    
    eye_matrix = I';

end
