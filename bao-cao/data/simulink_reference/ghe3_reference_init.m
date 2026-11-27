function p = ghe3_reference_init()
% Chay truoc khi mo model. Cac don vi noi bo deu SI.
root=fileparts(mfilename('fullpath')); addpath(root);addpath(fullfile(root,'core'));
p=ghe3_defaults(); % Bo 420/360 mm, 3 bar, 120 kg da luu tren GitHub.
assignin('base','ghe3_reference_parameters',p);
t=(0:0.01:40)';U=zeros(numel(t),4);
U(t>=5 & t<13,1)=.35;  % ga
U(t>=13 & t<17,2)=.12; % phanh
U(t>=17 & t<21,3)=.5;  % vo lang trai (rad)
U(t>=21 & t<25,3)=-.5; % vo lang phai
U(t>=3 & t<25,4)=1;    % cho phep motion cueing; ngoai khoang nay ve trung tinh
assignin('base','ghe3_driver',[t U]);
% Testbench van: tin hieu do gia lap, KHONG phai nghiem chuyen dong ghe.
v=(0:.01:12)';d=zeros(numel(v),3);
d(v>=2 & v<8,1)=.005;d(v>=4 & v<8,2)=-.005;d(v>=6 & v<8,3)=.005;
dm=zeros(size(d));dm(31:end,:)=d(1:end-30,:); % phep do gia lap tre 0.30s
assignin('base','ghe3_valve_test',[v d dm]);
fprintf('Reference parameters: rb %.3f m, rp %.3f m, h0 %.9f m.\n',p.rb,p.rp,p.h0);
end
