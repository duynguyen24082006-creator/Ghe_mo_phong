function w = ghe3_workspace(p)
% Sampled pose grid, geometric checks only. Not continuous workspace proof.
hs=linspace(p.h0-p.ampH,p.h0+p.ampH,p.workspaceSamples);
phs=linspace(-p.ampRoll,p.ampRoll,p.workspaceSamples);
ths=linspace(-p.ampPitch,p.ampPitch,p.workspaceSamples);
n=numel(hs)*numel(phs)*numel(ths); rows=zeros(n,9); k=0;
for h=hs
 for ph=phs
  for th=ths
   k=k+1; [L,~,g]=ghe3_geometry([h;ph;th],p);
   strokeOK=all(L>=p.Lmin & L<=p.Lmin+p.stroke);
   jointsOK=all(g.baseJointAngle<=p.maxJointAngle) && all(g.topJointAngle<=p.maxJointAngle);
   conditionOK=g.condition<=p.maxCondition && g.constraintCondition<=p.maxCondition;
   poseOK=h>0 && max(abs([ph th]))<=p.maxPoseAngle;
   rows(k,:)=[h ph th strokeOK jointsOK conditionOK poseOK g.condition g.constraintCondition];
  end
 end
end
ok=all(rows(:,4:7)>0,2);
w=struct('data',rows,'feasible',ok,'tested',n,'accepted',sum(ok), ...
 'fraction',mean(ok),'sampledOnly',true, ...
 'columns','h_m,roll_rad,pitch_rad,stroke_ok,joints_ok,condition_ok,pose_ok,condition_scaled,passive_constraint_condition_scaled');
end
