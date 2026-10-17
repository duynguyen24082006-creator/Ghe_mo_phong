function r = run_ghe3(interactive,p,outdir)
% RUN_GHE3 true -> input dialogs/console and plots; false -> headless batch.
% Example: r=run_ghe3(false,ghe3_defaults(),fullfile(pwd,'ket_qua'));
if nargin<1, interactive=true; end
if nargin<2 || isempty(p), p=ghe3_defaults(); end
if nargin<3 || isempty(outdir), outdir=fullfile(fileparts(mfilename('fullpath')),'ket_qua'); end
if interactive, p=ghe3_input(p); end
p=ghe3_validate(p);
fprintf('3-RPS model: bottom revolute axes tangential to base, upper spherical joints.\n');
fprintf('Base hinge axis orientation assumed tangential; example dimensions are illustrative.\n');
r=ghe3_simulate(p); ghe3_export(r,outdir);
fprintf('Mass %.3f kg; lengths %.2f..%.2f mm; peak |v| %.4f m/s.\n', ...
 p.mass,1000*min(r.lengths(:)),1000*max(r.lengths(:)),max(abs(r.velocities(:))));
fprintf('Forces %.2f..%.2f N; peak simultaneous atmospheric-equivalent flow %.2f L/min.\n', ...
 min(r.forces(:)),max(r.forces(:)),max(r.flowAirTotalLpm));
fprintf('Sampled geometric workspace %d/%d accepted.\n',r.workspace.accepted,r.workspace.tested);
fprintf('%s\n',r.strength.status);
fprintf('Exports: %s\n',outdir);
if interactive, ghe3_plot(r,outdir); end
end
