function ghe3_valve_logic_sfun(b)
% Level-2 MATLAB S-function: Normal mode, khong sinh ma MCU.
b.NumDialogPrms=0;b.NumInputPorts=1;b.NumOutputPorts=1;
b.SetPreCompInpPortInfoToDynamic;b.SetPreCompOutPortInfoToDynamic;
b.InputPort(1).Dimensions=6;b.InputPort(1).DatatypeID=0;
b.InputPort(1).Complexity='Real';b.InputPort(1).DirectFeedthrough=true;
b.OutputPort(1).Dimensions=3;b.OutputPort(1).DatatypeID=0;b.OutputPort(1).Complexity='Real';
b.SampleTimes=[.01 0];b.SimStateCompliance='DefaultSimState';
b.RegBlockMethod('PostPropagationSetup',@setupDwork);
b.RegBlockMethod('InitializeConditions',@init);
b.RegBlockMethod('Outputs',@out);b.RegBlockMethod('Update',@update);
end
function setupDwork(b)
b.NumDworks=1;b.Dwork(1).Name='state';b.Dwork(1).Dimensions=12;
b.Dwork(1).DatatypeID=0;b.Dwork(1).Complexity='Real';b.Dwork(1).UsedAsDiscState=true;
end
function init(b)
b.Dwork(1).Data=[zeros(9,1);ones(3,1)*1000];
end
function out(b)
[~,z]=ghe3_valve_logic(b.Dwork(1).Data,b.InputPort(1).Data,.01,.025,.08);
b.OutputPort(1).Data=z;
end
function update(b)
[next,~]=ghe3_valve_logic(b.Dwork(1).Data,b.InputPort(1).Data,.01,.025,.08);
b.Dwork(1).Data=next;
end
