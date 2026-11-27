function ghe3_export(r,outdir)
% Export ASCII CSV plus native MAT file; all trajectory columns use SI.
if ~exist(outdir,'dir'), mkdir(outdir); end
columns={'time_s','h_m','roll_rad','pitch_rad','hdot_mps','rolldot_radps', ...
 'pitchdot_radps','hddot_mps2','rollddot_radps2','pitchddot_radps2', ...
 'L1_m','L2_m','L3_m','v1_mps','v2_mps','v3_mps','a1_mps2','a2_mps2','a3_mps2', ...
 'F1_N','F2_N','F3_N','condition_scaled','passive_condition_scaled','constraintFx_N','constraintFy_N','constraintFz_N', ...
 'constraintMx_Nm','constraintMy_Nm','constraintMz_Nm','air1_Lpm','air2_Lpm','air3_Lpm', ...
 'airTotal_Lpm','passive_x_m','passive_y_m','passive_yaw_rad', ...
 'lateral1_N','lateral2_N','lateral3_N','baseMoment1_Nm','baseMoment2_Nm','baseMoment3_Nm','stroke_ok','joints_ok','condition_ok','speed_ok','fk_ok','fk_error_scaled_m'};
data=[r.t r.q r.qd r.qdd r.lengths r.velocities r.accelerations r.forces ...
 r.condition r.passiveCondition r.constraintWrench r.flowAirLpm r.flowAirTotalLpm r.passive r.lateralForces r.baseMomentMagnitude ...
 r.strokeOK r.jointsOK r.conditionOK r.speedOK r.fkOK r.fkError];
% Append, rather than reorder, the legacy trajectory columns.
[columns,data]=append_series(columns,data,r,'valveCommand', ...
 {'valve_command1','valve_command2','valve_command3'});
[columns,data]=append_series(columns,data,r,'valveState', ...
 {'valve_state1','valve_state2','valve_state3'});
[columns,data]=append_series(columns,data,r,'valvePressureDrop', ...
 {'valve_drop1_Pa','valve_drop2_Pa','valve_drop3_Pa'});
[columns,data]=append_series(columns,data,r,'chamberSupplyPressure', ...
 {'chamber_supply1_Pa','chamber_supply2_Pa','chamber_supply3_Pa'});
[columns,data]=append_series(columns,data,r,'tankPressure',{'tank_pressure_Pa'});
[columns,data]=append_series(columns,data,r,'tankPressureDemand',{'tank_demand_pressure_Pa'});
[columns,data]=append_series(columns,data,r,'workingPressureAvailable', ...
 {'available_pressure1_Pa','available_pressure2_Pa','available_pressure3_Pa'});
[columns,data]=append_series(columns,data,r,'compressorOn',{'compressor_on'});
[columns,data]=append_series(columns,data,r,'compressorFlowLpm',{'compressor_flow_Lpm'});
[columns,data]=append_series(columns,data,r,'valveTrackingOK', ...
 {'valve_tracking1_ok','valve_tracking2_ok','valve_tracking3_ok'});
if isfield(r,'flowAirDemandLpm')
 [columns,data]=append_series(columns,data,r,'flowAirDemandLpm', ...
  {'air_demand1_Lpm','air_demand2_Lpm','air_demand3_Lpm'});
elseif isfield(r,'airflowDemandLpm')
 if size(r.airflowDemandLpm,2)==3
  demandColumns={'air_demand1_Lpm','air_demand2_Lpm','air_demand3_Lpm'};
 else
  demandColumns={'air_demand_total_Lpm'};
 end
 [columns,data]=append_series(columns,data,r,'airflowDemandLpm',demandColumns);
end
[columns,data]=append_series(columns,data,r,'flowAirDemandTotalLpm',{'air_demand_total_Lpm'});
[columns,data]=append_series(columns,data,r,'airTankBalanceResidual',{'tank_balance_residual_Pa'});
[columns,data]=append_series(columns,data,r,'tankInflowVolumeL',{'tank_cumulative_inflow_L'});
[columns,data]=append_series(columns,data,r,'tankOutflowVolumeL',{'tank_cumulative_outflow_L'});
write_csv(fullfile(outdir,'trajectory.csv'),strjoin(columns,','),data);
write_csv(fullfile(outdir,'workspace_sampled.csv'),r.workspace.columns,r.workspace.data);
s=r.strength; p=r.p;
names={'mass_kg','minimum_length_m','maximum_length_m','maximum_abs_speed_mps', ...
 'maximum_abs_length_acceleration_mps2','minimum_force_N','maximum_force_N', ...
 'maximum_design_compression_N','maximum_design_tension_N','extension_capacity_N', ...
 'retraction_capacity_N','maximum_condition_scaled','peak_simultaneous_air_Lpm', ...
 'workspace_sample_count','workspace_accepted_count','maximum_fk_error_scaled_m', ...
 'rod_max_combined_stress_Pa','rod_min_yield_margin','rod_max_slenderness', ...
 'rod_euler_critical_slenderness','cylinder_VM_Pa','cylinder_yield_margin', ...
 'beam_bending_stress_Pa','beam_center_deflection_m','beam_yield_margin', ...
 'max_constraint_virtual_work_residual','max_constraint_force_N','max_constraint_moment_Nm', ...
 'max_passive_xy_m','max_abs_passive_yaw_rad','max_abs_lateral_force_N','max_base_moment_Nm','max_equilibrium_residual', ...
 'maximum_passive_constraint_condition_scaled'};
vals=[p.mass;min(r.lengths(:));max(r.lengths(:));max(abs(r.velocities(:))); ...
 max(abs(r.accelerations(:)));min(r.forces(:));max(r.forces(:)); ...
 max(s.design.compression);max(s.design.tension);s.pneumatic.extensionCapacity; ...
 s.pneumatic.retractionCapacity;max(r.condition);max(r.flowAirTotalLpm); ...
 r.workspace.tested;r.workspace.accepted;max(r.fkError); ...
 max(s.rod.combinedStress);min(s.rod.yieldMargin);max(s.rod.slenderness); ...
 s.rod.eulerCriticalSlenderness;s.cylinder.vonMisesStress;s.cylinder.yieldMargin; ...
 s.beam.bendingStress;s.beam.centerDeflection;s.beam.yieldMargin; ...
 max(abs(r.constraintResidual(:)));max(sqrt(sum(r.constraintWrench(:,1:3).^2,2))); ...
 max(sqrt(sum(r.constraintWrench(:,4:6).^2,2))); ...
 max(sqrt(sum(r.passive(:,1:2).^2,2)));max(abs(r.passive(:,3))); ...
 max(abs(r.lateralForces(:)));max(r.baseMomentMagnitude(:));max(abs(r.equilibriumResidual(:))); ...
 max(r.passiveCondition)];
% Requested supply summary names are also emitted for archived results;
% NaN means the corresponding tank/supply screen was not available.
averageAir=NaN;
if isfield(r,'averageAirLpm')
 averageAir=r.averageAirLpm;
elseif numel(r.t)>1 && r.t(end)>r.t(1)
 averageAir=trapz(r.t,r.flowAirTotalLpm)/(r.t(end)-r.t(1));
end
minimumTank=NaN; airFeasible=NaN;
if isfield(r,'tankPressure'), minimumTank=min(r.tankPressure); end
if isfield(r,'minTankPressure'), minimumTank=min(minimumTank,r.minTankPressure); end
if isfield(r,'airSupplyOK'), airFeasible=double(r.airSupplyOK); end
names=[names {'average_air_Lpm','min_tank_pressure_Pa','air_supply_feasible'}];
vals=[vals;averageAir;minimumTank;airFeasible];
averageDemand=averageAir;
if isfield(r,'averageAirDemandLpm'), averageDemand=r.averageAirDemandLpm; end
names{end+1}='average_air_demand_Lpm'; vals(end+1,1)=averageDemand;
if isfield(r,'minDemandTankPressure')
 names{end+1}='min_demand_tank_pressure_Pa'; vals(end+1,1)=r.minDemandTankPressure;
end
if isfield(r,'valveTrackingFeasible')
 names{end+1}='valve_tracking_feasible';
 vals(end+1,1)=double(r.valveTrackingFeasible);
end
if isfield(r,'valveTrackingError')
 names{end+1}='maximum_valve_tracking_error_m';
 vals(end+1,1)=max(abs(r.valveTrackingError(:)));
end
if isfield(r,'flowCapacityOK')
 names{end+1}='valve_flow_capacity_feasible';
 vals(end+1,1)=double(all(r.flowCapacityOK(:)));
end
if isfield(r,'airTankBalanceResidual')
 names{end+1}='maximum_tank_balance_residual_Pa';
 vals(end+1,1)=max(abs(r.airTankBalanceResidual(:)));
end
if isfield(r,'tankInflowVolumeL')
 names{end+1}='tank_total_inflow_L';
 vals(end+1,1)=r.tankInflowVolumeL(end);
end
if isfield(r,'tankOutflowVolumeL')
 names{end+1}='tank_total_outflow_L';
 vals(end+1,1)=r.tankOutflowVolumeL(end);
end
if isfield(r,'valveTrackingOK')
 names{end+1}='valve_tracking_mismatch_sample_count';
 vals(end+1,1)=sum(any(~r.valveTrackingOK,2));
end
if isfield(r,'valvePressureDrop')
 names{end+1}='maximum_valve_pressure_drop_Pa';
 vals(end+1,1)=max(r.valvePressureDrop(:));
end
fid=fopen(fullfile(outdir,'summary.csv'),'w');
if fid<0, error('ghe3:io','Cannot write summary.csv'); end
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'quantity,value\n');
for k=1:numel(names), fprintf(fid,'%s,%.12g\n',names{k},vals(k)); end
clear cleanup;
fid=fopen(fullfile(outdir,'screening_notes.txt'),'w');
if fid<0, error('ghe3:io','Cannot write screening_notes.txt'); end
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'3-RPS: bottom R axes tangent to base circle; upper spherical joints.\n');
fprintf(fid,'Tangential R-axis orientation is assumed and requires drawing confirmation.\n');
fprintf(fid,'%s\n',s.status);
for k=1:numel(s.rod.bucklingStatus), fprintf(fid,'Rod %d: %s\n',k,s.rod.bucklingStatus{k}); end
fprintf(fid,'\nNOT ASSESSED:\n');
for k=1:numel(s.unassessed), fprintf(fid,'- %s\n',s.unassessed{k}); end
fprintf(fid,'\nNOTES:\n');
for k=1:numel(s.warnings), fprintf(fid,'- %s\n',s.warnings{k}); end
fprintf(fid,'Flow is atmospheric-equivalent L/min at equal temperatures, not automatically normal litres at a different reference temperature.\n');
if isfield(r,'tankPressure')
 fprintf(fid,'\n5/3 CLOSED-CENTER VALVE AND AIR SUPPLY:\n');
 fprintf(fid,'Average air consumption: %.12g L/min; minimum tank gauge pressure: %.12g Pa.\n',averageAir,minimumTank);
 fprintf(fid,'Average requested air demand: %.12g L/min; low delivered flow alone is not evidence of feasibility.\n',averageDemand);
 fprintf(fid,'Air supply feasible within this numeric screen: %.0f.\n',airFeasible);
 if isfield(r,'averageAirBasis')
  fprintf(fid,'Averaging basis: %s\n',r.averageAirBasis);
 end
 if ~isnan(airFeasible) && ~airFeasible
  fprintf(fid,'WARNING: requested demand or tank/valve-pressure requirements are not met within this numeric screen; inspect the feasibility flags.\n');
 end
 if isfield(r,'valveTrackingOK') && any(~r.valveTrackingOK(:))
  fprintf(fid,'WARNING: valve delay/deadband prevents exact requested motion at some samples; do not interpret prescribed trajectory as achieved motion.\n');
 end
 if isfield(r,'air') && isstruct(r.air)
  if isfield(r.air,'scope'), fprintf(fid,'Model scope: %s\n',r.air.scope); end
  if isfield(r.air,'warnings')
   notes=r.air.warnings;
   if ischar(notes), notes={notes}; end
   for k=1:numel(notes), fprintf(fid,'- %s\n',notes{k}); end
  end
 end
 fprintf(fid,'Closed center shuts the modeled valve ports; it does not establish a rigid mechanical position lock or verified trapped-pressure load holding.\n');
 fprintf(fid,'Reservoir mass balance and available-pressure checks do not integrate the full coupled valve/chamber/seat motion dynamics.\n');
 fprintf(fid,'Validate valve flow curves, regulator loss, compressor FAD/duty, chamber charging, leakage and exhaust behavior before final equipment selection.\n');
else
 fprintf(fid,'Legacy flow screen: no initial/dead-volume filling, leakage or exhaust-valve sizing.\n');
 fprintf(fid,'No reservoir or 5/3-valve history was present in this archived result.\n');
end
fprintf(fid,'Workspace is a sampled geometric grid, not a certified continuous envelope.\n');
fprintf(fid,'Trajectory is an offline periodic benchmark with no start/stop ramp.\n');
clear cleanup;
if exist('OCTAVE_VERSION','builtin')
 save('-mat7-binary',fullfile(outdir,'results.mat'),'r');
else
 save(fullfile(outdir,'results.mat'),'r','-v7');
end
end

function [columns,data]=append_series(columns,data,r,field,extraColumns)
% Add an optional N-by-K numeric history without changing legacy columns.
if ~isfield(r,field), return; end
values=r.(field);
if ~(isnumeric(values)||islogical(values)) || ...
 size(values,1)~=size(data,1) || size(values,2)~=numel(extraColumns)
 error('ghe3:export','results.%s must be an N-by-%d numeric/logical history.', ...
  field,numel(extraColumns));
end
columns=[columns extraColumns];
data=[data double(values)];
end

function write_csv(filename,header,data)
fid=fopen(filename,'w');
if fid<0, error('ghe3:io','Cannot open %s.',filename); end
c=onCleanup(@() fclose(fid)); fprintf(fid,'%s\n',header); clear c;
dlmwrite(filename,data,'-append','delimiter',',','precision','%.12g');
end
