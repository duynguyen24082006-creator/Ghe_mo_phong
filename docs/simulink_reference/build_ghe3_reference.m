function build_ghe3_reference()
% Tao hai SLX tren MATLAB + Simulink. API huong toi R2017b, chua compile tai day.
ghe3_reference_init();root=fileparts(mfilename('fullpath'));load_system('simulink');
n='ghe3_driver_reference';fresh(n,root,'ode4','40');
add(n,'simulink/Sources/From Workspace','Driver',{'VariableName','ghe3_driver','Interpolate','off','SampleTime','.01'},[25 45 155 85]);
add(n,'simulink/Signal Routing/Demux','DriverSplit',{'Outputs','4'},[195 20 200 180]);
add(n,'simulink/Signal Routing/Mux','VehicleMux',{'Inputs','4'},[265 30 270 200]);
add(n,'simulink/User-Defined Functions/Interpreted MATLAB Fcn','Vehicle',{'MATLABFcn','ghe3_vehicle_accel(u)','OutputDimensions','2'},[320 65 485 110]);
add(n,'simulink/Signal Routing/Demux','AccelSplit',{'Outputs','2'},[520 45 525 135]);
add(n,'simulink/Continuous/Integrator','Speed',{'InitialCondition','0','LimitOutput','on','LowerSaturationLimit','0','UpperSaturationLimit','60'},[550 210 590 245]);
add(n,'simulink/Continuous/Transfer Fcn','LP_ax',{'Numerator','[0.5]','Denominator','[1 0.5]'},[585 25 680 65]);
add(n,'simulink/Continuous/Transfer Fcn','LP_ay',{'Numerator','[0.5]','Denominator','[1 0.5]'},[585 100 680 140]);
add(n,'simulink/Signal Routing/Mux','CueMux',{'Inputs','3'},[735 25 740 170]);
add(n,'simulink/User-Defined Functions/Interpreted MATLAB Fcn','TiltReference',{'MATLABFcn','ghe3_tilt_reference(u)','OutputDimensions','3'},[790 65 950 110]);
add(n,'simulink/Signal Routing/Demux','PoseSplit',{'Outputs','3'},[985 25 990 170]);
add(n,'simulink/Discontinuities/Rate Limiter','RollRate',{'RisingSlewLimit','2*pi/180','FallingSlewLimit','-2*pi/180'},[1030 70 1110 105]);
add(n,'simulink/Discontinuities/Rate Limiter','PitchRate',{'RisingSlewLimit','2*pi/180','FallingSlewLimit','-2*pi/180'},[1030 140 1110 175]);
add(n,'simulink/Signal Routing/Mux','PoseMux',{'Inputs','3'},[1160 25 1165 180]);
add(n,'simulink/User-Defined Functions/Interpreted MATLAB Fcn','IK_3RPS',{'MATLABFcn','ghe3_reference_ik(u)','OutputDimensions','3'},[1210 70 1360 110]);
add(n,'simulink/Sinks/Scope','LengthScope',{},[1430 50 1500 90]);
add(n,'simulink/Sinks/Scope','PoseScope',{},[1210 210 1290 250]);
add(n,'simulink/Sinks/To Workspace','LengthLog',{'VariableName','ghe3_L_reference','SaveFormat','Structure With Time','MaxDataPoints','inf'},[1400 140 1535 180]);
add(n,'simulink/Sinks/To Workspace','PoseLog',{'VariableName','ghe3_q_reference','SaveFormat','Structure With Time','MaxDataPoints','inf'},[1250 280 1395 320]);
connect(n,'Driver/1','DriverSplit/1');
for i=1:3,connect(n,['DriverSplit/' num2str(i)],['VehicleMux/' num2str(i)]);end
connect(n,'Speed/1','VehicleMux/4');connect(n,'VehicleMux/1','Vehicle/1');connect(n,'Vehicle/1','AccelSplit/1');
connect(n,'AccelSplit/1','Speed/1');connect(n,'AccelSplit/1','LP_ax/1');connect(n,'AccelSplit/2','LP_ay/1');
connect(n,'LP_ax/1','CueMux/1');connect(n,'LP_ay/1','CueMux/2');connect(n,'DriverSplit/4','CueMux/3');
connect(n,'CueMux/1','TiltReference/1');connect(n,'TiltReference/1','PoseSplit/1');
connect(n,'PoseSplit/1','PoseMux/1');connect(n,'PoseSplit/2','RollRate/1');connect(n,'RollRate/1','PoseMux/2');
connect(n,'PoseSplit/3','PitchRate/1');connect(n,'PitchRate/1','PoseMux/3');
connect(n,'PoseMux/1','IK_3RPS/1');connect(n,'PoseMux/1','PoseScope/1');connect(n,'PoseMux/1','PoseLog/1');
connect(n,'IK_3RPS/1','LengthScope/1');connect(n,'IK_3RPS/1','LengthLog/1');save_system(n,fullfile(root,[n '.slx']));
v='ghe3_valve_logic_reference';fresh(v,root,'FixedStepDiscrete','12');
add(v,'simulink/Sources/From Workspace','Scripted_reference_and_sensor',{'VariableName','ghe3_valve_test','Interpolate','off','SampleTime','.01'},[35 80 225 125]);
add(v,'simulink/User-Defined Functions/Level-2 MATLAB S-Function','Valve_logic',{'FunctionName','ghe3_valve_logic_sfun'},[295 80 495 125]);
add(v,'simulink/Sinks/Scope','ValveStates',{},[580 65 660 105]);
add(v,'simulink/Sinks/To Workspace','ValveLog',{'VariableName','ghe3_valve_states','SaveFormat','Structure With Time','MaxDataPoints','inf'},[560 150 725 190]);
connect(v,'Scripted_reference_and_sensor/1','Valve_logic/1');connect(v,'Valve_logic/1','ValveStates/1');connect(v,'Valve_logic/1','ValveLog/1');
save_system(v,fullfile(root,[v '.slx']));open_system(n);open_system(v);
fprintf('Created two reference SLX models. Use Normal mode and update diagram first.\n');
end
function fresh(n,root,solver,stop)
if bdIsLoaded(n)||exist(fullfile(root,[n '.slx']),'file')
 error('ghe3ref:exists','Model %s already exists; rename it before rebuilding.',n);end
new_system(n);set_param(n,'SolverType','Fixed-step','Solver',solver,'FixedStep','.01','StopTime',stop,'SimulationMode','normal');
end
function add(n,source,name,params,pos)
add_block(source,[n '/' name],'Position',pos,params{:});
end
function connect(n,a,b)
add_line(n,a,b,'autorouting','on');
end
