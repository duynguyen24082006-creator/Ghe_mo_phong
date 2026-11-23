function a = ghe3_air_supply(t,v,p)
%GHE3_AIR_SUPPLY Reduced-order 5/3 CC and isothermal receiver screening.
% Prescribed velocities are NOT a solved pneumatic motion. In particular,
% closed-center chambers, meter-out/back-driving, leakage and pressure filling
% are not solved. Separate nominal demand prevents crediting starvation or
% delayed closed valves as an air-saving feasible trajectory.
p=ghe3_validate(p); t=t(:);
if numel(t)<2||~isnumeric(t)||~isreal(t)||any(~isfinite(t))||any(diff(t)<=0)|| ...
 ~isnumeric(v)||~isreal(v)||~isequal(size(v),[numel(t),3])||any(~isfinite(v(:)))
 error('ghe3:airInput','Require increasing finite t and matching finite N-by-3 velocities.');
end
N=numel(t); A=pi*p.boreDiameter^2/4; Aa=A-pi*p.rodDiameter^2/4;
area=A*(v>=0)+Aa*(v<0);
ideal=area.*abs(v)*(p.pSupply+p.pAtm)/p.pAtm*60000;
command=valve_command(v,p.valveDeadbandSpeed);
vd=interp1(t,v,t-p.valveResponseTime,'linear',0);
state=valve_command(vd,p.valveDeadbandSpeed);
state(t-p.valveResponseTime<t(1),:)=0;
demand=ideal.*(command~=0);
% Insert threshold/delayed threshold events, so 25 ms is not rounded to dt.
events=[];
for k=1:N-1
 for j=1:3
  for threshold=[-p.valveDeadbandSpeed,p.valveDeadbandSpeed]
   dv=v(k+1,j)-v(k,j);
   if dv~=0
    f=(threshold-v(k,j))/dv;
    if f>=0&&f<=1
     tt=t(k)+f*(t(k+1)-t(k));
     events=[events;tt;tt+p.valveResponseTime]; %#ok<AGROW>
    end
   end
  end
 end
end
grid=(t(1):p.airTimeStep:t(end))';
nodes=unique([t;grid;events; t(1)+p.valveResponseTime]);
nodes=nodes(nodes>=t(1)&nodes<=t(end));
mid=(nodes(1:end-1)+nodes(2:end))/2;
vm=interp1(t,v,mid,'linear');
delayed=interp1(t,v,mid-p.valveResponseTime,'linear',0);
sm=valve_command(delayed,p.valveDeadbandSpeed);
sm(mid-p.valveResponseTime<t(1),:)=0;
cm=valve_command(vm,p.valveDeadbandSpeed);
P=p.tankInitialPressure; Pd=P;
on=P<=p.tankPressureCutIn; ond=on;
Pnode=zeros(numel(nodes),1);Pshadow=Pnode;onnode=Pnode;
inL=Pnode;outL=Pnode;missL=Pnode;shadowMiss=Pnode;
legL=zeros(numel(nodes),3);demL=legL;lag=zeros(1,3);maxLag=0;
Pnode(1)=P;Pshadow(1)=Pd;onnode(1)=on;
minimumTank=P;minimumDemandTank=Pd;
for k=1:numel(mid)
 h=nodes(k+1)-nodes(k);
 ar=A*(vm(k,:)>=0)+Aa*(vm(k,:)<0);
 chamber=ar.*abs(vm(k,:));
 qdem=chamber*(p.pSupply+p.pAtm)/p.pAtm*60000.*(cm(k,:)~=0);
 line=min(p.pSupply,max(P-p.regulatorHeadroom,0));
 [press,~,cap]=valve_pressure(line,chamber,p);
 match=sm(k,:)==cm(k,:)&sm(k,:)~=0;
 q=chamber.*(press+p.pAtm)/p.pAtm*60000.*match;
 if line<=0,q(:)=0;end
 q=min(q,cap);
 [P,on,vin,vout,missing,minStep]=tank_step(P,on,h,sum(q),p);
 [Pd,ond,~,~,md,minDemandStep]=tank_step(Pd,ond,h,sum(qdem),p);
 minimumTank=min(minimumTank,minStep);
 minimumDemandTank=min(minimumDemandTank,minDemandStep);
 Pnode(k+1)=P;Pshadow(k+1)=Pd;onnode(k+1)=on;
 inL(k+1)=inL(k)+vin;outL(k+1)=outL(k)+vout;
 missL(k+1)=missL(k)+missing;shadowMiss(k+1)=shadowMiss(k)+md;
 if sum(q)>0, legL(k+1,:)=legL(k,:)+q/sum(q)*vout;
 else, legL(k+1,:)=legL(k,:); end
 demL(k+1,:)=demL(k,:)+qdem*h/60;
 unmatched=(sm(k,:)~=cm(k,:))|(cm(k,:)==0 & abs(vm(k,:))>0);
 lag(~unmatched)=0;
 lag(unmatched)=lag(unmatched)+abs(vm(k,unmatched))*h;
 maxLag=max(maxLag,max(lag));
end
[~,idx]=ismember(t,nodes);
tank=Pnode(idx);shadow=Pshadow(idx);running=logical(onnode(idx));
line=min(p.pSupply,max(tank-p.regulatorHeadroom,0));
lineDemand=min(p.pSupply,max(shadow-p.regulatorHeadroom,0));
chamber=area.*abs(v);
[potential,drop,capacity]=valve_pressure(lineDemand,chamber,p);
[delivered,~,actualCapacity]=valve_pressure(line,chamber,p);
active=state==command & state~=0;
flow=chamber.*(delivered+p.pAtm)/p.pAtm*60000.*active;
flow(repmat(line<=0,1,3))=0; flow=min(flow,actualCapacity);
delivered(~active)=0;
period=1/p.frequency;
if t(end)-t(1)>=period-1e-12
 lo=t(end)-period; basis='last complete period; integrated reduced-order flow';
else
 lo=t(1); basis='record duration shorter than one period; time average only';
end
average=60*(sum(legL(end,:))-sum(interp1(nodes,legL,lo,'linear')))/(t(end)-lo);
averageDemand=60*(sum(demL(end,:))-sum(interp1(nodes,demL,lo,'linear')))/(t(end)-lo);
flowOK=all(drop(command~=0)<=p.valveMaxPressureDrop+1e-7) && ...
 all(demand(:)<=capacity(:)+1e-7);
trackingOK=maxLag<=p.valveMaxTrackingError+1e-12;
pressureOK=minimumTank>=p.pSupply+p.regulatorHeadroom-1e-6 && ...
 minimumDemandTank>=p.pSupply+p.regulatorHeadroom-1e-6;
averageOK=averageDemand<=p.compressorFlowLpm*p.compressorMaxDuty+1e-9;
balance=tank-p.tankInitialPressure-p.pAtm/(p.tankVolume*1000)*(inL(idx)-outL(idx));
a=struct('valveCommand',command,'valveState',state,'valveTrackingOK',state==command, ...
 'valveTrackingError',maxLag,'valveTrackingFeasible',trackingOK, ...
 'idealFlowAirLpm',ideal,'flowAirDemandLpm',demand,'flowAirDemandTotalLpm',sum(demand,2), ...
 'flowAirLpm',flow,'flowAirTotalLpm',sum(flow,2), ...
 'flowChamberM3s',flow*p.pAtm./(delivered+p.pAtm)/60000, ...
 'requestedFlowChamberM3s',chamber,'averageAirLpm',average, ...
 'averageAirDemandLpm',averageDemand,'averageAirBasis',basis, ...
 'valvePressureDrop',drop,'chamberSupplyPressure',delivered, ...
 'workingPressureAvailable',potential,'pneumaticBranchActive',active, ...
 'tankPressure',tank,'tankPressureDemand',shadow,'compressorOn',running, ...
 'compressorFlowLpm',double(running)*p.compressorFlowLpm, ...
 'tankInflowVolumeL',inL(idx),'tankOutflowVolumeL',outL(idx), ...
 'tankUnservedVolumeL',missL(idx),'tankDemandUnservedVolumeL',shadowMiss(idx), ...
 'airTankBalanceResidual',balance,'flowCapacityOK',flowOK, ...
 'airAverageOK',averageOK,'airTankPressureOK',pressureOK, ...
 'airSupplyOK',averageOK&&pressureOK&&flowOK&&trackingOK, ...
 'minTankPressure',minimumTank,'minDemandTankPressure',minimumDemandTank);
a.warnings={['Prescribed trajectory screening: no solved chamber-pressure ODE, ', ...
 'trapped-pressure hold, meter-out back-driving or actual closed-loop motion.'], ...
 ['Valve rated flow, critical pressure ratio and 40 L/min FAD are assumed; ', ...
 'replace by measured manufacturer data at the actual compressor discharge pressure.'], ...
 ['Closed center consumes zero swept inlet flow. Pressure charging of dead ', ...
 'volumes, hose filling, valve exhaust losses and leakage are not included.'], ...
 ['Air feasibility uses nominal demand and a conservative shadow receiver; ', ...
 'low delivered flow from delay/starvation is not credited as a feasible motion.']};
if ~averageOK,a.warnings{end+1}='Nominal mean demand exceeds compressor flow times allowed duty.';end
if ~pressureOK,a.warnings{end+1}='Receiver pressure falls below regulator target plus required headroom.';end
if ~flowOK,a.warnings{end+1}='Valve flow/drop budget is insufficient for the requested velocity.';end
if ~trackingOK,a.warnings{end+1}='Delayed/deadband swept-travel error proxy exceeds its allowed limit.';end
end

function s=valve_command(v,deadband)
s=double(v>deadband)-double(v<-deadband);
end

function [pd,drop,capacity]=valve_pressure(pg,q,p)
% Calibrated compressible conductance, equal reference/line temperatures.
pu=pg+p.pAtm; pur=p.valveRatedInletPressure+p.pAtm;
rr=(pur-p.valveRatedPressureDrop)/pur; b=p.valveCriticalRatio;
phi=1;
if rr>b,phi=sqrt(max(0,1-((rr-b)/(1-b))^2));end
C=p.valveRatedFlowLpm/(60*pur*phi); % L/(s Pa), at common atmospheric reference.
choked=60*C*pu; capacity=repmat(choked,1,size(q,2));
pu=repmat(pu,1,size(q,2));
j=60000*q.*pu/p.pAtm./capacity;
r=ones(size(j)); sub=j>0 & j<1/b;
r(sub)=(b+(1-b)*sqrt(max(0,1+j(sub).^2*(1-2*b))))./ ...
 (1+j(sub).^2*(1-b)^2);
choke=j>=1/b; r(choke)=1./j(choke);
pd=max(0,pu.*r-p.pAtm);
drop=max(0,pu-p.pAtm-pd);
capacity(repmat(pg<=0,1,size(q,2)))=0;
end

function [P,on,vin,vout,missing,minimum]=tank_step(P,on,h,Q,p)
% Exact integration of piecewise-constant atmospheric reference flows.
% Relay and empty/full events split the interval; no unaccounted clipping.
vin=0;vout=0;missing=0;minimum=P; scale=p.pAtm/(p.tankVolume*60000);
tol=1e-8; remaining=h;
while remaining>1e-12
 if on && P>=p.tankPressureMax-tol,on=false;end
 if ~on && P<=p.tankPressureCutIn+tol,on=true;end
 Qin=double(on)*p.compressorFlowLpm;
 rate=scale*(Qin-Q);
 if P<=tol && rate<0
  vin=vin+Qin*remaining/60;vout=vout+Qin*remaining/60;
  missing=missing+(Q-Qin)*remaining/60;P=max(0,P);
  minimum=min(minimum,P);break;
 end
 step=remaining;
 if rate>0 && on
  step=min(step,max(0,(p.tankPressureMax-P)/rate));
 elseif rate<0
  if ~on, step=min(step,max(0,(P-p.tankPressureCutIn)/(-rate)));
  else, step=min(step,max(0,P/(-rate)));end
 end
 if step<1e-12
  if rate>0,on=false;elseif ~on,on=true;else,P=0;end
  minimum=min(minimum,P);
  continue;
 end
 P=P+rate*step;minimum=min(minimum,P);
 vin=vin+Qin*step/60;vout=vout+Q*step/60;
 remaining=remaining-step;
end
if on&&P>=p.tankPressureMax-tol,on=false;end
if ~on&&P<=p.tankPressureCutIn+tol,on=true;end
end
