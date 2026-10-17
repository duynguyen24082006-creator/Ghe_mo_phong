function r = ghe3_simulate(p)
% Reproducible numerical experiment; no graphics or hardware I/O.
p=ghe3_validate(p); t=(0:p.dt:p.duration)';
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
 [fki,info]=ghe3_fk(Lk,p,fki); fkOK(k)=info.converged;
 fkError(k)=norm([fki(1)-q(k,1);p.rp*(fki(2:3)-q(k,2:3)')]);
end
A=pi*p.boreDiameter^2/4; Aa=A-pi*p.rodDiameter^2/4;
flowSupply=A*max(v,0)+Aa*max(-v,0);
% Equal-temperature atmospheric-equivalent volume, not standard Nl unless Tref=T.
flowAirLpm=flowSupply*(p.pSupply+p.pAtm)/p.pAtm*60000;
r=struct('p',p,'t',t,'q',q,'qd',qd,'qdd',qdd,'lengths',L, ...
 'velocities',v,'accelerations',a,'forces',f,'condition',conds,'passiveCondition',passiveConds, ...
 'constraintWrench',cw,'constraintResidual',cr,'lateralForces',lateral, ...
 'passive',passive,'baseMomentMagnitude',baseMoment,'equilibriumResidual',eqResidual, ...
 'closureResidual',closure,'strokeOK',strokeOK,'jointsOK',jointsOK, ...
 'conditionOK',conditionOK,'speedOK',all(abs(v)<=p.maxSpeed,2), ...
 'flowChamberM3s',flowSupply,'flowAirLpm',flowAirLpm, ...
 'flowAirTotalLpm',sum(flowAirLpm,2),'fkError',fkError,'fkOK',fkOK);
r.workspace=ghe3_workspace(p);
r.strength=ghe3_strength(p,r);
end
