function L = ghe3_reference_ik(q)
% Chieu dai YEU CAU tu ghe3_geometry; khong phai chuyen dong thuc.
p=evalin('base','ghe3_reference_parameters');
[L,~,g]=ghe3_geometry(q(:),p);
if any(L<p.Lmin)||any(L>p.Lmin+p.stroke)||g.condition>p.maxCondition
 error('ghe3ref:workspace','Reference leaves sampled operating limits.');
end
end
