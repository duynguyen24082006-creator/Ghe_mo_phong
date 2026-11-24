function r = ghe3_simulate(p)
% Reproducible numerical experiment; no graphics or hardware I/O.
p=ghe3_validate(p); t=(0:p.dt:p.duration)';
% Include the exact requested end time, also when duration/dt is not integer.
if t(end)<p.duration, t=[t;p.duration]; end
[q,qd,qdd]=ghe3_trajectory(t,p); n=numel(t);
L=zeros(n,3); v=L; a=L; f=L; conds=zeros(n,1); passiveConds=conds; cw=zeros(n,6); cr=L; lateral=L; passive=L; baseMoment=L; eqResidual=zeros(n,6); closure=L;
strokeOK=false(n,1); jointsOK=strokeOK; conditionOK=strokeOK;
fkError=zeros(n,1); fkOK=strokeOK; fki=[q(1,1);0;0];
for k=1:n
 [Lk,J,g]=ghe3_geometry(q(k,:)',p);
 L(k,:)=Lk'; v(k,:)=(J*qd(k,:)')';
 % Central directional derivative of J along the instantaneous qdot.
 epsT=1e-5/max(1,norm(qd(k,:)));
 [~,Jp]=ghe3_geometry(q(k,:)'+epsT*qd(k,:)',p);
 [~,Jm]=ghe3_geometry(q(k,:)'-epsT*qd(k,:)',p);
 Jdot=(Jp-Jm)/(2*epsT);
 a(k,:)=(J*qdd(k,:)'+Jdot*qd(k,:)')';
 [fk,d]=ghe3_forces(q(k,:)',qd(k,:)',qdd(k,:)',p); f(k,:)=fk';
 conds(k)=g.condition; passiveConds(k)=g.constraintCondition; cw(k,:)=d.constraintWrench';
 cr(k,:)=d.constraintGeneralizedResidual'; lateral(k,:)=d.lateralForces';
 passive(k,:)=g.passive'; baseMoment(k,:)=sqrt(sum(d.baseMoments.^2,1));
 eqResidual(k,:)=d.equilibriumResidual'; closure(k,:)=g.closureResidual';
 strokeOK(k)=all(Lk>=p.Lmin & Lk<=p.Lmin+p.stroke);
 jointsOK(k)=all(g.baseJointAngle<=p.maxJointAngle) && all(g.topJointAngle<=p.maxJointAngle);
 conditionOK(k)=g.condition<=p.maxCondition && g.constraintCondition<=p.maxCondition;
 if p.computeFK
  [fki,info]=ghe3_fk(Lk,p,fki); fkOK(k)=info.converged;
  fkError(k)=norm([fki(1)-q(k,1);p.rp*(fki(2:3)-q(k,2:3)')]);
 else
  fkError(k)=NaN;
 end
end
air=ghe3_air_supply(t,v,p);
r=struct('p',p,'t',t,'q',q,'qd',qd,'qdd',qdd,'lengths',L, ...
 'velocities',v,'accelerations',a,'forces',f,'condition',conds,'passiveCondition',passiveConds, ...
 'constraintWrench',cw,'constraintResidual',cr,'lateralForces',lateral, ...
 'passive',passive,'baseMomentMagnitude',baseMoment,'equilibriumResidual',eqResidual, ...
 'closureResidual',closure,'strokeOK',strokeOK,'jointsOK',jointsOK, ...
 'conditionOK',conditionOK,'speedOK',all(abs(v)<=p.maxSpeed,2), ...
 'fkError',fkError,'fkOK',fkOK,'air',air);
% Top-level aliases preserve convenient access and portable CSV exports.
names=fieldnames(air);
for k=1:numel(names)
 if ~strcmp(names{k},'warnings'),r.(names{k})=air.(names{k});end
end
if p.computeWorkspace
 r.workspace=ghe3_workspace(p);
else
 r.workspace=struct('data',zeros(0,9),'feasible',false(0,1),'tested',0, ...
  'accepted',0,'fraction',NaN,'sampledOnly',true, ...
  'columns','h_m,roll_rad,pitch_rad,stroke_ok,joints_ok,condition_ok,pose_ok,condition_scaled,passive_constraint_condition_scaled');
end
% Keep the historical arrays as REQUIRED, unmodified mechanical histories.
r.requestedLengths=r.lengths; r.requestedVelocities=r.velocities;
r.requestedForces=r.forces;
r.flowSupportedLengthProxy=r.lengths+r.flowTrackingErrorProxy;
r.flowProxyStrokeOK=all(r.flowSupportedLengthProxy>=p.Lmin & ...
 r.flowSupportedLengthProxy<=p.Lmin+p.stroke,2);
r.strength=ghe3_strength(p,r);
r.motionScreenOK=r.airSupplyOK && all(r.strength.pneumatic.pass(:)) && ...
 all(r.strokeOK) && all(r.jointsOK) && all(r.conditionOK) && ...
 all(r.speedOK) && all(r.flowProxyStrokeOK);
r.trajectoryStatus='NOT_ASSESSED: no coupled pneumatic/seat motion or closed-loop tracking solution';
end
