function runs=run_ghe3_3bar(outdir,makePlots)
%RUN_GHE3_3BAR Compare two explicitly prescribed 3-bar motion scenarios.
% run_ghe3_3bar(fullfile(pwd,'ket_qua_3bar'),true)
% Khong gui lenh ra phan cung. Do thi proxy KHONG phai vi tri thuc cua ghe.
if nargin<1||isempty(outdir),outdir=fullfile(pwd,'ket_qua_3bar');end
if nargin<2,makePlots=true;end
if ~exist(outdir,'dir'),mkdir(outdir);end
base=ghe3_defaults();base.pSupply=0.30e6;base.regulatorPressure=base.pSupply;
% Giu bien do: heave +/-20 mm, roll/pitch +/-4 deg.
names={'benchmark_030Hz','candidate_009Hz'};freq=[0.30 0.09];
runs=struct(); data=zeros(2,9);
for k=1:2
 p=base;p.frequency=freq(k);p.duration=2/p.frequency;
 if k==2,p.maxSpeed=0.04;end
 dest=fullfile(outdir,names{k});
 r=run_ghe3(false,p,dest);
 if makePlots,ghe3_plot(r,dest);close all;end
 runs.(names{k})=r;
 data(k,:)=[p.frequency r.averageAirDemandLpm r.averageAirLpm ...
  max(abs(r.velocities(:))) all(r.strength.pneumatic.pass(:)) ...
  r.airSupplyOK r.motionScreenOK r.flowTrackingMaxError r.trajectoryAchieved];
end
fid=fopen(fullfile(outdir,'comparison.csv'),'w');
if fid<0,error('ghe3:io','Cannot write comparison.csv');end
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'frequency_Hz,required_mean_Lpm,credited_mean_Lpm,required_peak_speed_mps,force_envelope_ok,air_screen_ok,motion_resource_screen_ok,flow_proxy_max_error_m,trajectory_achieved\n');
for k=1:2,fprintf(fid,'%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g\n',data(k,:));end
end
