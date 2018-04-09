% contingency analysis
% given the line that is the most significant (from other papers), outage
% that line for both the regular case file and the modeled case file using
% DC and AC power flow to see the line loading of the regular (correct)
% modeled (calculated) case file

function [line_loading_reference_DC,line_loading_model_DC,line_loading_reference_AC,line_loading_model_AC] = contingency_analysis (number_of_nodes, case_name, susceptance_vector, outage_to_bus, outage_from_bus)

%reference file - replace with other load and run powerflow (DC and AC)
new_case = case_name;
load_vector = zeros(number_of_nodes,2);
variance = zeros(number_of_nodes,2);
%extract the real and reactive power from the case, let that be the mean
load_vector(:,1) = new_case.bus(:,3); %Real Power
load_vector(:,2) = new_case.bus(:,4); %Reactive Power

%original

%try something new
%basically some nodes does not generate nor consume anything - so to make
%sure each set of data is different, we set the variance to 1.
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

%reference file - remove line and run powerflow (DC and AC)
branch_to_outage = new_case.branch(:,1) == outage_from_bus & new_case.branch(:,2) == outage_to_bus;
new_case.branch(branch_to_outage, :) = [];

mpopt = mpoption('verbose', 0, 'out.all', 0); %reduce output visuals 
result_AC = runpf(new_case, mpopt); %run default AC power flow
mpopt_DC = mpoption(mpopt, 'model', 'DC'); %DC Power Flow
result_DC = runpf(new_case, mpopt_DC); %run DC power flow

%Check Line Loading
line_loading_reference_AC = [result_AC.branch(:,1) result_AC.branch(:,2) result_AC.branch(:,14)];
line_loading_reference_DC = [result_DC.branch(:,1) result_DC.branch(:,2) result_DC.branch(:,14)];

%***set up the modeled casefile***
number_of_branches = nchoosek(number_of_nodes, 2);

%use the same load as reference file
new_case_model = case_name;
new_case_model.bus(:,3) = load_vector_rand (:,1);
new_case_model.bus(:,4) = load_vector_rand (:,2);

%set up branch parameter
to_from = combnk(1:number_of_nodes, 2); %m x 2 vector
new_case_model.branch = zeros(number_of_branches, 13);
new_case_model.branch(:,1:2) = to_from;
new_case_model.branch(:,4) = susceptance_vector;
%remove zeros susceptance rows
branch_to_remove = new_case_model.branch(:,4) <= 0.01;
new_case_model.branch(branch_to_remove, :) = [];

%fill in the rest of the table
new_case_model.branch(:,3) = (1./new_case_model.branch(:,4))/10; %resistance is typically 10th of susceptance
new_case_model.branch(:,4) = (1./new_case_model.branch(:,4));
new_case_model.branch(:,11) = 1;
new_case_model.branch(:,12) = -360;
new_case_model.branch(:,13) = 360;

%remove the outage line
branch_to_outage_model = new_case_model.branch(:,1) == outage_from_bus & new_case_model.branch(:,2) == outage_to_bus;
new_case_model.branch(branch_to_outage_model, :) = [];

%run powerflow
result_AC_model = runpf(new_case_model, mpopt); %run default AC power flow
result_DC_model = runpf(new_case_model, mpopt_DC); %run DC power flow

%Check Line Loading
line_loading_model_AC = [result_AC_model.branch(:,1) result_AC_model.branch(:,2) result_AC_model.branch(:,14)];
line_loading_model_DC = [result_DC_model.branch(:,1) result_DC_model.branch(:,2) result_DC_model.branch(:,14)];


end

