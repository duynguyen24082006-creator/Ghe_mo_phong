import cadquery as cq,numpy as np,json
from OCP.BRepAdaptor import BRepAdaptor_Surface
s=cq.importers.importStep('/workspace/attachments/2b83fb30-1fac-4745-8d3b-731fbed15313/shapr3d_export_2026-11-24_21h55m.step').solids().vals()
base=[s[i-1] for i in list(range(33,48))+[51,52,53]];b=cq.Compound.makeCompound(base).BoundingBox();print('BASEBBOX',b.xmin,b.xmax,b.ymin,b.ymax,b.zmin,b.zmax,b.xlen,b.ylen,b.zlen)
for k in [33,34,35,36,39,51,52,53]:
 o=s[k-1]; print('\nSOLID',k)
 print('LINES', sorted(set(round(e.Length(),6) for e in o.Edges() if e.geomType()=='LINE')))
 if k in [33,34,35]:
  rows=[]
  for f in o.Faces():
   if f.geomType()=='CYLINDER':
    cy=BRepAdaptor_Surface(f.wrapped).Cylinder();a=cy.Axis().Direction();p=cy.Location()
    if abs(a.Z())>.999:
     r=[round(2*cy.Radius(),6),round(p.X(),6),round(p.Y(),6)]
     if r not in rows:rows.append(r)
  print('HOLES',rows)
 if k==52:
  print('TOPVERT', sorted(set(tuple(round(a,6) for a in v.toTuple()) for v in o.Vertices() if abs(v.Z-27)<1e-5)))
