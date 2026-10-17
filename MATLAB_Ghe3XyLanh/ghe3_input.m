function p = ghe3_input(p,mode)
% Parameter entry. Values displayed in convenient engineering units.
% Use ghe3_input(p,'console') without MATLAB desktop. Empty means keep value.
if nargin<1, p=ghe3_defaults(); end
if nargin<2, mode='auto'; end
gui=false;
if ~strcmp(mode,'console')
 try, gui=usejava('desktop') && exist('inputdlg','file')~=0; catch, gui=false; end
end
fprintf('\nMO HINH 3-RPS: duoi R (truc tiep tuyen), tren S.\n');
fprintf('Truc R tiep tuyen la gia thiet; can doi chieu ban ve. So mac dinh minh hoa.\n');
fprintf('Tat ca ap suat nhap la ap du tru pAtm; khong dung de dieu khien ghe that.\n');
groups={ ...
 {'Hinh hoc 3-RPS va tai trong', {'rb','rp','baseAngle','platformAngle','h0','Lmin','stroke','massPerson','massSeat','com'}, ...
  {'Ban kinh tam khop de [mm]','Ban kinh tam khop san [mm]','Goc tam giac de [deg]','Goc tam giac san [deg]','Cao do O danh dinh [mm]','Chieu dai tam chot khi thu [mm]','Hanh trinh [mm]','Khoi luong nguoi [kg]','Khoi luong phan chuyen dong chua gom nguoi [kg]','COM chung trong he san [x y z, mm]'}, ...
  [1000 1000 180/pi 180/pi 1000 1000 1000 1 1 1000]}, ...
 {'Quan tinh va ngoai luc', {'inertia','Fexternal','Mexternal'}, ...
  {'Tensor quan tinh 3x3 tai COM [kg.m2], dung dau ; phan hang','Luc ngoai tai COM he the gioi [Fx Fy Fz, N]','Moment ngoai tai COM he the gioi [Mx My Mz, Nm]'}, [1 1 1]}, ...
 {'Xy lanh khi nen', {'boreDiameter','rodDiameter','pSupply','pExhaust','pAtm','ratedPressure','efficiency','friction','maxSpeed','maxJointAngle'}, ...
  {'Duong kinh piston [mm]','Duong kinh can [mm]','Ap cap du [MPa]','Ap xa/back pressure du [MPa]','Ap khi quyen tuyet doi [kPa]','Ap du cho phep theo catalog [MPa], mac dinh gia dinh','Hieu suat luc (0..1]','Ma sat Coulomb bao thu [N]','Van toc cho phep catalog [m/s]','Goc lech phuong +z cua de/san [deg], gioi han chung'}, ...
  [1000 1000 1e-6 1e-6 1e-3 1e-6 1 1 1 180/pi]}, ...
 {'Quy dao kiem tra', {'ampH','ampRoll','ampPitch','frequency','duration','dt','maxPoseAngle','maxCondition','workspaceSamples'}, ...
  {'Bien do nang [mm]','Bien do roll [deg]','Bien do pitch [deg]','Tan so [Hz]','Thoi gian [s]','Buoc thoi gian [s]','Gioi han goc tu the [deg]','Gioi han condition Jacobian da chuan hoa','So diem moi truc luoi workspace (3..41)'}, ...
  [1000 180/pi 180/pi 1 1 1 180/pi 1 1]}, ...
 {'Can piston va he so', {'loadFactor','nStrength','rodE','rodFy','rodEccentricity','rodUnsupportedBase','rodK'}, ...
  {'He so tai du phong (>=1, chi nhan mot lan)','He so an toan vat lieu (>=1)','Mo dun dan hoi can E [GPa]','Gioi han chay vat lieu can [MPa]','Lech tam luc can e [mm]','Can khong do khi thu Le0 [mm]','He so lien ket on dinh K'}, ...
  [1 1 1e-9 1e-6 1000 1000 1]}, ...
 {'Chot, tai khop va ong xy lanh', {'pinDiameter','pinShearPlanes','pinFy','pinPlateThickness','pinBearingPlates','pinPlateFy','cylinderWall','cylinderFy'}, ...
  {'Duong kinh chot [mm]','So mat cat chiu cat cua chot','Gioi han chay chot [MPa]','Chieu day moi tai khop [mm]','So tai khop cung chiu ep mat','Gioi han chay tai khop [MPa]','Chieu day ong xy lanh [mm]','Gioi han chay vat lieu ong [MPa]'}, ...
  [1000 1 1e-6 1000 1 1e-6 1000 1e-6]}, ...
 {'Dam khung don gian hoa', {'beamSpan','beamWidth','beamHeight','beamWall','beamFy','beamE'}, ...
  {'Nhip dam don gian [mm]','Rong ngoai hop [mm]','Cao ngoai hop [mm]','Day thanh hop [mm]','Gioi han chay vat lieu dam [MPa]','Mo dun dan hoi dam [GPa]'}, ...
  [1000 1000 1000 1000 1e-6 1e-9]} };
for ig=1:numel(groups)
 g=groups{ig}; fields=g{2}; labels=g{3}; scales=g{4}; vals=cell(size(fields));
 for k=1:numel(fields), vals{k}=mat2str(p.(fields{k})*scales(k),8); end
 if gui
  answers=inputdlg(labels,g{1},[1 100],vals);
  if isempty(answers), error('ghe3:cancel','Input cancelled; no simulation was run.'); end
 else
  fprintf('\n%s\n',g{1}); answers=vals;
  for k=1:numel(fields)
   a=input(sprintf('%s [%s]: ',labels{k},vals{k}),'s');
   if ~isempty(strtrim(a)), answers{k}=a; end
  end
 end
 for k=1:numel(fields)
  % Accept numeric literals/matrices only; never evaluate arbitrary MATLAB code.
  value=parse_numeric(answers{k});
  if isempty(value), error('ghe3:input','Invalid numeric value for %s.',fields{k}); end
  p.(fields{k})=value/scales(k);
 end
end
p=ghe3_validate(p);
end

function value=parse_numeric(s)
value=[];
s=strtrim(s); s=strrep(s,'[',''); s=strrep(s,']',''); s=strrep(s,',',' ');
if isempty(s) || ~isempty(regexp(s,'[^0-9eE+\-\. ;\t]','once')), return; end
rows=strsplit(s,';'); nr=numel(rows); ncol=0;
for i=1:nr
 tokens=strsplit(strtrim(rows{i})); v=zeros(1,numel(tokens));
 for j=1:numel(tokens), v(j)=str2double(tokens{j}); end
 if any(~isfinite(v)), value=[]; return; end
 if i==1, ncol=numel(v); elseif numel(v)~=ncol, value=[]; return; end
 value(i,:)=v; %#ok<AGROW>
end
end
