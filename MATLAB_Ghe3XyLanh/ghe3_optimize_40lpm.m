function opt = ghe3_optimize_40lpm(p,grid,outdir)
%GHE3_OPTIMIZE_40LPM Search a finite grid for the 40 L/min source model.
%   OPT = GHE3_OPTIMIZE_40LPM() writes CSV/MAT results to ket_qua_40lpm.
%   OPT = GHE3_OPTIMIZE_40LPM(P,GRID,OUTDIR) accepts SI grid vectors:
%       grid.pSupply   [Pa gauge], default 3.5:0.5:6.0 bar
%       grid.ampH      [m]
%       grid.ampRoll, grid.ampPitch [rad]
%       grid.frequency [Hz]
%       grid.maxSpeed  [m/s], a rejection limit; never clips the motion
%   Optional grid.averageAirLimitLpm (default 36), grid.verbose (true),
%   grid.export (true), grid.samplesPerCycle (default 81), and
%   grid.maxConfigurations (default 5000).
%
%   The recommendation is ONE sampled configuration maximizing the stated
%   normalized amplitude-frequency score. It is not a claim of a global
%   optimum or independent simultaneous maxima of every parameter.
%
%   Mechanical geometry/forces are computed once for each amplitude/frequency
%   tuple. Only the air/strength calculations are repeated for pressure and
%   speed limits. FK/workspace sweeps are skipped in this screening search.
%
%   Continuous periodic tank operation is checked using a conservative
%   cumulative-deficit bound in addition to a two-period startup simulation.
%   Thus a full tank lasting a short simulation cannot alone pass a row.
%   The bound assumes the helper's isothermal tank, constant compressor FAD,
%   periodic required motion and on/off pressure relay. It does not validate
%   thermal compressor duty, trapped chamber pressure or physical tracking.
%   MATLAB R2017b compatible; no Optimization Toolbox or table required.

if nargin<1 || isempty(p), p=ghe3_defaults(); end
if nargin<2 || isempty(grid), grid=struct(); end
if nargin<3 || isempty(outdir), outdir=fullfile(pwd,'ket_qua_40lpm'); end
p=ghe3_validate(p);
grid=complete_grid(grid,p);
if exist('ghe3_air_supply','file')~=2
    error('ghe3:optimizer','ghe3_air_supply.m is required.');
end

columns={'pSupply_Pa','ampH_m','ampRoll_rad','ampPitch_rad', ...
    'frequency_Hz','maxSpeed_mps','peak_required_speed_mps', ...
    'average_air_demand_Lpm','average_air_credited_Lpm', ...
    'peak_air_demand_Lpm','min_simulated_tank_pressure_Pa', ...
    'periodic_tank_lower_bound_Pa','estimated_compressor_running_fraction', ...
    'pneumatic_force_ok','flow_limit_ok','periodic_tank_ok', ...
    'geometry_ok','speed_ok','valve_tracking_ok','flow_capacity_ok', ...
    'startup_air_supply_ok','feasible','motion_score', ...
    'max_valve_mismatch_travel_m','periodic_deficit_volume_m3'};
nrows=numel(grid.pSupply)*numel(grid.ampH)*numel(grid.ampRoll)* ...
    numel(grid.ampPitch)*numel(grid.frequency)*numel(grid.maxSpeed);
data=NaN(nrows,numel(columns));
errors=cell(nrows,1); row=0; bestIndex=[]; bestKey=[]; bestResult=[];
mechanicalCount=0;
reference=[max([grid.ampH(:);eps]), ...
           max([grid.ampRoll(:);eps]),max([grid.ampPitch(:);eps])];

for ah=grid.ampH
 for ar=grid.ampRoll
  for ap=grid.ampPitch
   for freq=grid.frequency
    mechanicalCount=mechanicalCount+1;
    pm=p; pm.ampH=ah; pm.ampRoll=ar; pm.ampPitch=ap; pm.frequency=freq;
    period=1/freq;
    nper=grid.samplesPerCycle;
    pm.dt=period/nper; pm.duration=period;
    pm.computeWorkspace=false; pm.computeFK=false;
    % These two parameters do not alter prescribed-motion mechanics.
    pm.pSupply=max(grid.pSupply); pm.regulatorPressure=pm.pSupply;
    pm.maxSpeed=max(grid.maxSpeed);
    mechanicalError='';
    try
        mech=ghe3_simulate(pm);
        mech=repeat_one_period(mech,nper);
    catch err
        mechanicalError=err.message;
        mech=[];
    end
    if grid.verbose
        fprintf('40 L/min grid: mechanical case %d, h=%.1f mm, roll/pitch=%.2f/%.2f deg, f=%.3f Hz.\n', ...
            mechanicalCount,1000*ah,ar*180/pi,ap*180/pi,freq);
    end
    for supply=grid.pSupply
     cachedAir=[]; cachedStrength=[];
     for limit=grid.maxSpeed
        row=row+1;
        pc=pm; pc.pSupply=supply; pc.regulatorPressure=supply;
        pc.maxSpeed=limit; pc.duration=2*period;
        score=freq/max(grid.frequency)*sum([ah ar ap]./reference);
        data(row,1:6)=[supply ah ar ap freq limit];
        data(row,14:22)=0;
        data(row,23)=score;
        if ~isempty(mechanicalError)
            errors{row}=mechanicalError;
            continue;
        end
        try
            pc=ghe3_validate(pc);
            % maxSpeed is solely an acceptance limit in this prescribed-motion
            % model. Reuse air/strength histories for the other speed limits.
            if isempty(cachedAir)
                cachedAir=ghe3_air_supply(mech.t,mech.velocities,pc);
            end
            air=cachedAir;
            rr=mech; rr.p=pc; rr.air=air;
            names=fieldnames(air);
            for j=1:numel(names), rr.(names{j})=air.(names{j}); end
            rr.speedOK=all(abs(rr.velocities)<=limit,2);
            if isempty(cachedStrength), cachedStrength=ghe3_strength(pc,rr); end
            rr.strength=cachedStrength;
            requiredAverage=air.averageAirDemandLpm;
            creditedAverage=air.averageAirLpm;
            forceOK=all(rr.strength.pneumatic.pass(:));
            allowableDuty=1;
            if isfield(pc,'compressorMaxDuty'), allowableDuty=pc.compressorMaxDuty; end
            flowLimit=min(grid.averageAirLimitLpm,pc.compressorFlowLpm*allowableDuty);
            flowOK=isfinite(requiredAverage) && requiredAverage<=flowLimit+1e-9;
            geomOK=all(rr.strokeOK(:)) && all(rr.jointsOK(:)) && all(rr.conditionOK(:));
            speedOK=all(rr.speedOK(:));
            trackingOK=all(air.valveTrackingFeasible(:));
            capacityOK=all(air.flowCapacityOK(:));
            startupOK=all(air.airSupplyOK(:));
            cert=periodic_tank_bound(air.flowAirDemandTotalLpm(end-nper:end),pc);
            headroom=0;
            if isfield(pc,'regulatorHeadroom'), headroom=pc.regulatorHeadroom; end
            minSimulated=min(air.tankPressure(:));
            if isfield(air,'minTankPressure'), minSimulated=min(minSimulated,air.minTankPressure); end
            if isfield(air,'minDemandTankPressure'), minSimulated=min(minSimulated,air.minDemandTankPressure); end
            tankOK=cert.valid && cert.lowerBound>=supply+headroom-1e-8 && ...
                minSimulated>=supply+headroom-1e-8;
            nonzeroMotion=score>0 && any(abs(rr.velocities(:))>pc.valveDeadbandSpeed);
            if ~nonzeroMotion
                errors{row}='No requested motion leaves the closed-center deadband; not accepted as a moving configuration.';
            end
            feasible=forceOK && flowOK && tankOK && geomOK && speedOK && ...
                trackingOK && capacityOK && startupOK && nonzeroMotion;
            peakSpeed=max(abs(rr.velocities(:)));
            duty=requiredAverage/pc.compressorFlowLpm;
            data(row,7:25)=[peakSpeed requiredAverage creditedAverage ...
                max(air.flowAirDemandTotalLpm(:)) minSimulated cert.lowerBound duty ...
                forceOK flowOK tankOK geomOK speedOK trackingOK capacityOK ...
                startupOK feasible score max(air.valveTrackingError(:)) cert.deficitVolume];
            if feasible
                key=[-score supply limit requiredAverage];
                if isempty(bestKey) || lexicographic_less(key,bestKey)
                    bestKey=key; bestIndex=row; bestResult=rr;
                end
            end
        catch err
            errors{row}=err.message;
        end
     end
    end
   end
  end
 end
end

feasibleRows=find(data(:,22)>0);
opt=struct(); opt.columns=columns; opt.data=data;
opt.feasibleRows=feasibleRows; opt.feasibleData=data(feasibleRows,:);
opt.feasibleCount=numel(feasibleRows); opt.tested=nrows;
opt.mechanicalCases=mechanicalCount; opt.grid=grid; opt.errors=errors;
opt.recommendedIndex=bestIndex; opt.recommended=[]; opt.recommendedResult=[];
opt.recommendationRule=['Largest normalized amplitude-frequency score within the sampled grid; ', ...
    'ties: lower supply pressure, smaller acceptable speed setting, lower required flow.'];
opt.scope=['Prescribed-motion, valve-capacity and isothermal source screening only. ', ...
    'The 36 L/min rule is an explicit reserve, not proof that unmodeled dead-volume ', ...
    'charging, leakage and control losses are below 4 L/min. Actual position tracking, ', ...
    'trapped chamber pressure and hardware certification are not established.'];
opt.periodicCertificate=['Worst integrated circular-period deficit while compressor is ON; ', ...
    'max endpoint flow per interval plus one relay-sampling interval of drawdown. ', ...
    'A negative full-period balance against compressor FAD is required.'];
if isempty(bestIndex)
    opt.status='NO_FEASIBLE_GRID_CONFIGURATION';
else
    values=data(bestIndex,:); named=cell2struct(num2cell(values),columns,2);
    opt.recommended=struct('parameters',bestResult.p,'metrics',named, ...
        'row',values,'scope',opt.scope);
    opt.recommendedResult=bestResult;
    opt.status='FEASIBLE_WITHIN_THIS_MODEL_AND_GRID';
end
opt.table=[]; opt.feasibleTable=[];
if exist('array2table','file')==2 || exist('array2table','builtin')==5
    opt.table=array2table(data,'VariableNames',columns);
    opt.feasibleTable=opt.table(feasibleRows,:);
end
if grid.export, export_results(opt,outdir); end
if grid.verbose
    fprintf('40 L/min search: %d/%d sampled configurations passed.\n',opt.feasibleCount,nrows);
    if ~isempty(bestIndex)
        m=opt.recommended.metrics;
        fprintf('Recommended sampled row: %.2f bar; h %.1f mm; roll/pitch %.2f/%.2f deg; %.3f Hz; speed limit %.4f m/s.\n', ...
            m.pSupply_Pa/1e5,1000*m.ampH_m,m.ampRoll_rad*180/pi,m.ampPitch_rad*180/pi,m.frequency_Hz,m.maxSpeed_mps);
        fprintf('Required cycle mean %.3f L/min; periodic tank lower bound %.3f bar.\n', ...
            m.average_air_demand_Lpm,m.periodic_tank_lower_bound_Pa/1e5);
    end
end
end

function grid=complete_grid(grid,p)
if ~isstruct(grid) || numel(grid)~=1, error('ghe3:optimizer','grid must be a scalar struct.'); end
defaults=struct('pSupply',(3.5:.5:6)*1e5, ...
    'ampH',unique([p.ampH/2 p.ampH]), ...
    'ampRoll',unique([p.ampRoll/2 p.ampRoll]), ...
    'ampPitch',unique([p.ampPitch/2 p.ampPitch]), ...
    'frequency',[.05 .10 .20],'maxSpeed',[.03 .08], ...
    'averageAirLimitLpm',36,'samplesPerCycle',81, ...
    'maxConfigurations',5000,'verbose',true,'export',true);
names=fieldnames(defaults);
for j=1:numel(names)
    if ~isfield(grid,names{j}), grid.(names{j})=defaults.(names{j}); end
end
names={'pSupply','ampH','ampRoll','ampPitch','frequency','maxSpeed'};
count=1;
for j=1:numel(names)
    x=grid.(names{j});
    if ~isnumeric(x) || ~isreal(x) || isempty(x) || ~isvector(x) || any(~isfinite(x(:)))
        error('ghe3:optimizer','grid.%s must be a finite real nonempty vector.',names{j});
    end
    if j>=2 && j<=4
        if any(x(:)<0), error('ghe3:optimizer','Motion amplitudes must be nonnegative.'); end
    elseif any(x(:)<=0)
        error('ghe3:optimizer','Pressure, frequency and speed vectors must be positive.');
    end
    grid.(names{j})=unique(x(:)'); count=count*numel(grid.(names{j}));
end
if max(grid.ampRoll)>p.maxPoseAngle || max(grid.ampPitch)>p.maxPoseAngle || max(grid.ampH)>=p.h0
    error('ghe3:optimizer','Search amplitudes exceed the model pose limits.');
end
if max(grid.ampH)==0 && max(grid.ampRoll)==0 && max(grid.ampPitch)==0
    error('ghe3:optimizer','At least one searched amplitude must be nonzero.');
end
scalar={'averageAirLimitLpm','samplesPerCycle','maxConfigurations'};
for j=1:numel(scalar)
    v=grid.(scalar{j});
    if ~isnumeric(v) || ~isscalar(v) || ~isreal(v) || ~isfinite(v) || v<=0
        error('ghe3:optimizer','grid.%s must be a finite positive scalar.',scalar{j});
    end
end
if grid.samplesPerCycle~=round(grid.samplesPerCycle) || grid.samplesPerCycle<20
    error('ghe3:optimizer','samplesPerCycle must be an integer at least 20.');
end
if grid.maxConfigurations~=round(grid.maxConfigurations) || count>grid.maxConfigurations
    error('ghe3:optimizer','Grid has %d rows; increase maxConfigurations explicitly if intended.',count);
end
if grid.averageAirLimitLpm>p.compressorFlowLpm
    error('ghe3:optimizer','averageAirLimitLpm must not exceed compressor FAD.');
end
for name={'verbose','export'}
    v=grid.(name{1});
    if ~(islogical(v)||isnumeric(v)) || ~isscalar(v) || ~isreal(v) || ~isfinite(v) || ~any(v==[0 1])
        error('ghe3:optimizer','grid.%s must be logical scalar.',name{1});
    end
end
end

function r=repeat_one_period(r,nper)
% Repeat all sampled mechanical histories, retaining the common endpoint once.
n=nper+1; fields=fieldnames(r);
for j=1:numel(fields)
    value=r.(fields{j});
    if (isnumeric(value)||islogical(value)) && ~isempty(value) && size(value,1)==n
        r.(fields{j})=[value(1:end-1,:);value];
    end
end
r.t=(0:2*nper)'*r.p.dt;
r.p.duration=2/r.p.frequency;
end

function cert=periodic_tank_bound(q,p)
% Conservative periodic source bound, valid for the sampled flow envelope.
q=q(:); n=numel(q)-1;
upper=max(q(1:n),q(2:n+1));
dt=p.dt; qc=p.compressorFlowLpm;
increments=(upper-qc)*dt/60000; % atmospheric-equivalent m^3
total=sum(increments);
maximum=max_subarray(increments);
minimum=-max_subarray(-increments);
deficit=max([0 maximum total-minimum]);
relayStep=dt;
if isfield(p,'airTimeStep'), relayStep=min(relayStep,p.airTimeStep); end
relayVolume=max(q)*relayStep/60000;
cert=struct();cert.deficitVolume=deficit;
cert.relaySamplingAllowanceVolume=relayVolume;
cert.valid=total<0 && isfinite(deficit);
cert.lowerBound=p.tankPressureCutIn-p.pAtm/p.tankVolume*(deficit+relayVolume);
end

function best=max_subarray(x)
best=-Inf; running=0;
for j=1:numel(x)
    running=max(x(j),running+x(j));best=max(best,running);
end
end

function yes=lexicographic_less(a,b)
yes=false;
for j=1:numel(a)
    tol=1e-12*max([1 abs(a(j)) abs(b(j))]);
    if a(j)<b(j)-tol, yes=true; return; end
    if a(j)>b(j)+tol, return; end
end
end

function export_results(opt,outdir)
if ~exist(outdir,'dir'), mkdir(outdir); end
write_csv(fullfile(outdir,'optimizer_40lpm_all.csv'),opt.columns,opt.data);
write_csv(fullfile(outdir,'optimizer_40lpm_feasible.csv'),opt.columns,opt.feasibleData);
if ~isempty(opt.recommended)
    write_csv(fullfile(outdir,'optimizer_40lpm_recommended.csv'),opt.columns,opt.recommended.row);
else
    write_csv(fullfile(outdir,'optimizer_40lpm_recommended.csv'),opt.columns,zeros(0,numel(opt.columns)));
end
fid=fopen(fullfile(outdir,'optimizer_notes.txt'),'w');
if fid<0,error('ghe3:io','Cannot write optimizer_notes.txt.');end
c=onCleanup(@() fclose(fid));
fprintf(fid,'%s\n%s\n%s\n%s\n',opt.status,opt.scope,opt.recommendationRule,opt.periodicCertificate);
fprintf(fid,'Tested %d sampled configurations; feasible %d.\n',opt.tested,opt.feasibleCount);
fprintf(fid,'maxSpeed is a required-motion acceptance limit, not an applied trajectory clip.\n');
for j=1:numel(opt.errors)
    if ~isempty(opt.errors{j}),fprintf(fid,'Row %d rejected: %s\n',j,opt.errors{j});end
end
clear c;
if exist('OCTAVE_VERSION','builtin')
    save('-mat7-binary',fullfile(outdir,'optimizer_results.mat'),'opt');
else
    save(fullfile(outdir,'optimizer_results.mat'),'opt','-v7');
end
end

function write_csv(file,columns,data)
fid=fopen(file,'w');
if fid<0,error('ghe3:io','Cannot write %s.',file);end
c=onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',strjoin(columns,','));
if ~isempty(data)
    pattern=[repmat('%.12g,',1,size(data,2)-1) '%.12g\n'];
    fprintf(fid,pattern,data');
end
end
