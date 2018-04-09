
number_of_nodes
case_name
susceptance_vector = value;
outage_to_bus = [11, 12, 13];
outage_from_bus = 6;

    
[line_loading_reference_DC_1,line_loading_model_DC_1,line_loading_reference_AC_1,line_loading_model_AC_1] = contingency_analysis (number_of_nodes, case_name, susceptance_vector, outage_to_bus(1), outage_from_bus);
[line_loading_reference_DC_2,line_loading_model_DC_2,line_loading_reference_AC_2,line_loading_model_AC_2] = contingency_analysis (number_of_nodes, case_name, susceptance_vector, outage_to_bus(2), outage_from_bus);
[line_loading_reference_DC_3,line_loading_model_DC_3,line_loading_reference_AC_3,line_loading_model_AC_3] = contingency_analysis (number_of_nodes, case_name, susceptance_vector, outage_to_bus(3), outage_from_bus);
[line_loading_reference_DC_4,line_loading_model_DC_4,line_loading_reference_AC_4,line_loading_model_AC_4] = contingency_analysis (number_of_nodes, case_name, susceptance_vector, 6, 5);