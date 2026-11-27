exec(open('/workspace/check_STEP_new/base_stats.py').read().split('for k in')[0])
from OCP.BRepAdaptor import BRepAdaptor_Surface
for k in [33,34,35]:
 print('PLATE',k)
 stats={}
 for f in s[k-1].Faces():
  if f.geomType()=='CYLINDER':
   a=BRepAdaptor_Surface(f.wrapped);cy=a.Cylinder()
   if abs(cy.Axis().Direction().Z())>.99:
    r=round(cy.Radius()*2,5);p=cy.Location();stats.setdefault(r,[]).append([round(a.LastUParameter()-a.FirstUParameter(),5),round(f.BoundingBox().zmin,3),round(f.BoundingBox().zmax,3)])
 print(stats)
for k in [51,52,53]:
 print('RAIL',k)
 for f in s[k-1].Faces():
  b=f.BoundingBox()
  if abs(b.zmin-27)<1e-5 and abs(b.zmax-27)<1e-5:
   for e in f.Edges():
    if e.geomType()=='LINE' and e.Length()>300:
     print(e.startPoint().toTuple(),e.endPoint().toTuple(),e.Length())
