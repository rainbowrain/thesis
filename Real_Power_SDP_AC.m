%get the Real Power and angle from any test case - using runpf
%purpose is to get the data

function [Real_Power_Vector,Bus_Voltage_pu, Bus_Angle] = Real_Power_SDP_AC(case_number, number_of_buses)
    
    Real_Power_Vector = zeros(number_of_buses,1);  %set up a column vector of the power injection
    case_used = case_number;
    mpopt = mpoption('verbose', 0, 'out.all', 0); %reduce output visuals 

    result = runpf(case_number, mpopt); %run default AC power flow
    
    Bus_Angle = deg2rad(result.bus(:,9));
    Bus_Voltage_pu = result.bus(:,8);
    
    Sbus = makeSbus(case_used.baseMVA, case_used.bus, case_used.gen, mpopt);
    Real_Power_Vector = real(Sbus);
    
end
  

