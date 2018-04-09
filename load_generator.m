%returns one set of randomly (normal distribution) generated real power for a case
%file
function [new_case] = load_generator(number_of_nodes,case_number)

load_vector = zeros(number_of_nodes,2);
variance = zeros(number_of_nodes,2);

%extract the real and reactive power from the case, let that be the mean
new_case = case_number;
load_vector(:,1) = new_case.bus(:,3); %Real Power
load_vector(:,2) = new_case.bus(:,4); %Reactive Power

%basically some nodes does not consume anything load - so to make
%sure each set of data is different, we set the variance to the mean load

for counter = 1 : number_of_nodes
    if load_vector(counter,1)== 0
        variance(counter,1)=mean(abs(load_vector(:,1)));
    else
        variance(counter,1) = abs(load_vector(counter,1));
    end
    
    if load_vector(counter,2)== 0
        variance(counter,2)=mean(abs(load_vector(:,2)));  
    else
        variance(counter,2) = abs(load_vector(counter,2));
    end
end

%generate one set of load
load_vector_rand = normrnd(load_vector, variance);

%update case file with new load
new_case.bus(:,3) = load_vector_rand (:,1);
new_case.bus(:,4) = load_vector_rand (:,2);

end
