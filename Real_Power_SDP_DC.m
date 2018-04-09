%get the Real Power Injection from any test case - using runpf
%purpose is to get the data

function [Real_Power_Vector,Bus_Voltage_pu, Bus_Angle] = Real_Power_SDP_DC(case_number, number_of_buses)
    
    Real_Power_Vector = zeros(number_of_buses,1);  %set up a column vector of the power injection
    
    mpopt = mpoption('verbose', 0, 'out.all', 0); %reduce output visuals 
    mpopt = mpoption(mpopt, 'model', 'DC'); %DC Power Flow
    result = runpf(case_number, mpopt); %run DC power flow
    
    Bus_Angle = deg2rad(result.bus(:,9));
    Bus_Voltage_pu = result.bus(:,8);
    Real_Power_Vector = result.outputpbus;

end
  
            
