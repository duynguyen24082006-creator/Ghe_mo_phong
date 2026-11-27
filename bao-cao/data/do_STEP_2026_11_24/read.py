import cadquery as cq,json
from pathlib import Path
p=Path('/workspace/attachments/2b83fb30-1fac-4745-8d3b-731fbed15313/shapr3d_export_2026-11-24_21h55m.step')
a=cq.importers.importStep(str(p));solids=a.solids().vals();print('objects',len(a.vals()),'solids',len(solids))
allshape=cq.Compound.makeCompound(a.vals());b=allshape.BoundingBox();print('TOTAL',[b.xmin,b.xmax,b.ymin,b.ymax,b.zmin,b.zmax])
rows=[]
for i,s in enumerate(solids):
 b=s.BoundingBox();v=s.Volume();row={'id':i+1,'bbox':[b.xmin,b.xmax,b.ymin,b.ymax,b.zmin,b.zmax],'size':[b.xlen,b.ylen,b.zlen],'volume':v,'center':s.Center().toTuple()};rows.append(row)
 print(i+1,'bbox',','.join('%.2f'%x for x in row['bbox']),'vol %.0f'%v)
Path('/workspace/step_dimensions/solids.json').write_text(json.dumps(rows,indent=2))
# Initial projection, quick visual inspection.
cq.exporters.export(allshape,'/workspace/step_dimensions/iso.svg',opt={'width':1400,'height':1000,'projectionDir':(1,-1,0.65),'showAxes':False,'showHidden':False,'strokeWidth':0.6})
