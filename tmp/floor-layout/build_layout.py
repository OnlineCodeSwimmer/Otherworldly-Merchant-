"""Build an additive Floor 3 scene fragment using the project's existing assets.

The original scene objects are never rewritten. The fragment is imported by the
Unity editor tool, which preserves any unsaved work in the loaded Clinic scene.
"""
from map_tiles import *
from PIL import Image, ImageDraw, ImageFont
import hashlib, uuid

OUT=ROOT/'tmp/floor-layout'
OUT.mkdir(parents=True,exist_ok=True)
ASSET=ROOT/'Assets/Scenes/Clinic Floor 3 Layout.unity'
source_floor=1681993356
offset=237.88
wall={}
def line(x1,y1,x2,y2,index):
    for y in range(y1,y2+1):
        for x in range(x1,x2+1):wall[x,y,0]=index
def gap(x,y,width=2):
    for a in range(x,x+width):wall.pop((a,y,0),None)

# Keep the same main exterior footprint. Floor 1 also has three stray wall
# tiles far outside the building; they are deliberately not part of the copy.
line(-10,-6,44,-6,5);line(-10,16,44,16,8)
line(-10,-5,-10,15,9);line(44,-5,44,15,2)
wall[-10,-6,0]=1;wall[44,-6,0]=0;wall[-10,16,0]=7;wall[44,16,0]=6
gap(-1,-6,3)
line(4,-5,4,2,9);line(4,7,4,15,9)
line(4,7,43,7,5);line(4,2,43,2,8)
for x in (16,28):line(x,8,x,15,2);wall[x,16,0]=11;wall[x,7,0]=4
for x in (22,33):line(x,-5,x,1,2);wall[x,2,0]=11;wall[x,-6,0]=4
wall[4,16,0]=11;wall[4,-6,0]=4;wall[4,7,0]=10;wall[4,2,0]=7
wall[44,7,0]=2;wall[44,2,0]=2
doors=[(9,7),(21,7),(34,7),(10,2),(26,2),(37,2)]
for x,y in doors:gap(x,y)

original_ground=tiles(276111056)
all_ground={(x,y,0) for y in range(-5,16) for x in range(-9,44)}
# Match both the bounding rectangle and the exact number of painted cells.
# Missing ground is placed only under opaque internal walls.
covered=sorted(all_ground & wall.keys(),key=lambda p:(p[1],p[0]))
ground=all_ground-set(covered[:len(all_ground)-len(original_ground)])
assert len(ground)==len(original_ground)==1062

children=collections.defaultdict(list)
for n in nodes.values():children[n['parent']].append(n['id'])
def descend(id):
    out={id}
    for c in children[id]:out |= descend(c)
    return out

# All original furniture is retained except a second treatment door and one
# surplus cabinet that would obstruct the compact women's washroom.
keep=descend(source_floor)-descend(279489828)-descend(657754029)
ids=set()
for nid in keep:
    n=nodes[nid]
    ids.add(nid)
    if 'instance' in n:
        ids.add(n['instance'])
        ids.update(i for i,(k,s) in blocks.items() if ref(s,'m_PrefabInstance')==n['instance'])
    else:
        ids.add(ref(blocks[nid][1],'m_GameObject'))
        ids.update(i for i,k in n['components'])
remap={i:870000000000000000+j for j,i in enumerate(sorted(ids),1)}
new={i:blocks[i][1] for i in ids}

def changefield(id,key,value):
    new[id]=re.sub(r'^  '+re.escape(key)+r': .*$', '  '+key+': '+value,new[id],flags=re.M)
def vector(values):return '{'+', '.join(a+': '+format(v,'.9g') for a,v in zip('xyzw',values))+'}'

def prefab_prop(nid,prop,value):
    n=nodes[nid];i=n['instance'];s=new[i]
    pat=r'(      propertyPath: '+re.escape(prop)+r'\n      value: )[^\n]*'
    if re.search(pat,s):s=re.sub(pat,lambda m:m[1]+str(value),s)
    else:
        target=re.search(r'  m_CorrespondingSourceObject: (\{.*\})',blocks[nid][1])[1]
        entry='    - target: '+target+'\n      propertyPath: '+prop+'\n      value: '+str(value)+'\n      objectReference: {fileID: 0}\n'
        s=s.replace('    m_RemovedComponents:',entry+'    m_RemovedComponents:')
    new[i]=s

def position(nid,x,y):
    if 'instance' in nodes[nid]:
        prefab_prop(nid,'m_LocalPosition.x',x);prefab_prop(nid,'m_LocalPosition.y',y)
    else:changefield(nid,'m_LocalPosition',vector([x,y,0]))

def rotation(nid,degrees):
    import math
    prefab_prop(nid,'m_LocalRotation.x',0)
    prefab_prop(nid,'m_LocalRotation.y',0)
    prefab_prop(nid,'m_LocalRotation.z',math.sin(math.radians(degrees/2)))
    prefab_prop(nid,'m_LocalRotation.w',math.cos(math.radians(degrees/2)))
    prefab_prop(nid,'m_LocalEulerAnglesHint.z',degrees)

root_go=ref(blocks[source_floor][1],'m_GameObject')
changefield(root_go,'m_Name','Floor 3')
position(source_floor,20.05+offset,6.97)
changefield(source_floor,'m_Father','{fileID: 0}')
rename={801445065:'Hall - Reception and Waiting',689882035:'Examination Room 1 - North West',992400009:'Examination Room 2 - North Centre',1419769967:'Treatment Room - North East',280027647:'Pharmacy - South West',1714540076:'Mens Restroom - South Centre',470903747:'Womens Restroom - South East'}
for nid,name in rename.items():changefield(ref(blocks[nid][1],'m_GameObject'),'m_Name',name)

# Room groups use the grid coordinate system so each placement is readable.
for nid in rename:position(nid,-20.05,-6.97)
for old,shift in ((689882035,(10,12)),(992400009,(22,12))):
    for nid in children[old]:
        x,y,z=nodes[nid]['pos'];position(nid,x+shift[0],y+shift[1])
position(2073833044,9.014,7);position(657480091,21.014,7)
position(2023777237,25.0,14.4)

# Treatment room: three beds on the east side, work surface and storage west.
for nid in children[1419769967]:
    if nid in keep:
        x,y,z=nodes[nid]['pos'];position(nid,x+18,y)
position(1476017080,34.014,7)
position(1278143964,34.7,12.3)
oldparent=nodes[1278143964]['parent'];children[oldparent].remove(1278143964);children[1419769967].append(1278143964)
new[nodes[1278143964]['instance']]=new[nodes[1278143964]['instance']].replace('m_TransformParent: {fileID: '+str(oldparent)+'}','m_TransformParent: {fileID: 1419769967}')

# Pharmacy: refrigerated storage to the west, shelves to the south, counters
# flank the two-cell entrance instead of blocking the doorway.
for nid,x,y in [(74208235,6.4,-3.7),(1043789482,7.8,-3.7),(802852996,9.2,-3.7),
    (1571133659,13.5,-3.7),(843737864,18.0,-3.7),(870222195,17.9,-0.6),(1873085707,6.9,-0.6),
    (832933305,10.014,2)]:position(nid,x,y)
rotation(832933305,90);prefab_prop(832933305,'m_LocalScale.y',1.33)

# Washrooms are adjacent, with stalls at the back and clear door approaches.
men_positions={6421446474997773308:(24.2,-3.5),1192077982:(27.2,-3.5),361336779:(30.2,-3.5),
    440561581:(24.0,0.8),1626188343:(25.4,0.8),1960553138:(29.7,0.8),398693410:(31.2,0.8),
    493456277:(23.0,-0.7),1799079757:(23.0,-2.1),605663312:(23.0,-4.6),1759142819:(31.7,-0.8),2078964373:(26.014,2)}
for nid,(x,y) in men_positions.items():position(nid,x,y)
rotation(2078964373,-90.13);prefab_prop(2078964373,'m_LocalScale.y',1.33)
for nid,x,y in [(1590624707,35.3,-3.5),(787665601,38.3,-3.5),(679674209,41.3,-3.5),(1903260820,37.014,2)]:position(nid,x,y)
for nid in (1590624707,787665601,679674209):rotation(nid,0)
rotation(1903260820,90);prefab_prop(1903260820,'m_LocalScale.y',1.33)
position(1799079757,34.1,-0.7)
children[1714540076].remove(1799079757);children[470903747].append(1799079757)
new[nodes[1799079757]['instance']]=new[nodes[1799079757]['instance']].replace('m_TransformParent: {fileID: 1714540076}','m_TransformParent: {fileID: 470903747}')

# Reception at the north end of the lobby, waiting seats near the entrance.
position(1446178723,-3.1,11.5);position(1356595608,-2.41,11.46)
position(187631967,-18.05,-10.77)

# Remove references to the intentionally omitted furniture and reparent the trolley.
for nid in keep:
    if 'instance' not in nodes[nid]:
        ch=[x for x in children[nid] if x in keep]
        value='  m_Children:'+ ('\n'+''.join('  - {fileID: '+str(x)+'}\n' for x in ch) if ch else ' []\n')
        new[nid]=re.sub(r'  m_Children:.*?(?=  m_Father:)',value,new[nid],flags=re.S)

def replace_tiles(id,cell_data):
    s=new[id]
    start=s.index('  m_Tiles:');end=s.index('  m_AnimatedTiles:')
    body='  m_Tiles:\n'
    for (x,y,z),record in sorted(cell_data.items(),key=lambda kv:(kv[0][1],kv[0][0])):
        body+=f'  - first: {{x: {x}, y: {y}, z: {z}}}\n    second:\n'+record
    s=s[:start]+body+s[end:]
    # Rebuild serialized reference counts for every palette array.
    keys={'Asset':'m_TileIndex','Sprite':'m_TileSpriteIndex','Matrix':'m_TileMatrixIndex','Color':'m_TileColorIndex'}
    for name,key in keys.items():
        count=collections.Counter(int(re.search(key+r': (\d+)',v)[1]) for v in cell_data.values())
        pat=r'(  m_Tile'+name+r'Array:\n)(.*?)(?=^  \w|\Z)'
        def recalc(m):
            idx=iter(range(10000))
            return m[1]+re.sub(r'm_RefCount: \d+',lambda _: 'm_RefCount: '+str(count[next(idx)]),m[2])
        s=re.sub(pat,recalc,s,flags=re.M|re.S)
    new[id]=s
    xs=[p[0] for p in cell_data];ys=[p[1] for p in cell_data]
    changefield(id,'m_Origin',vector([min(xs),min(ys),0]))
    changefield(id,'m_Size',vector([max(xs)-min(xs)+1,max(ys)-min(ys)+1,1]))

records={}
for value in tiles(171008837).values():records[int(re.search(r'm_TileIndex: (\d+)',value)[1])]=value
replace_tiles(171008837,{p:records[idx] for p,idx in wall.items()})
replace_tiles(276111056,{p:next(iter(original_ground.values())) for p in ground})

# Drop the old serialized collision outline. Unity rebuilds it from the new
# tiles; the editor finalizer explicitly forces a rebuild as well.
new[171008838]=re.sub(r'  m_ColliderPaths:.*?(?=  m_VertexDistance:)',
    '  m_ColliderPaths: []\n  m_CompositePaths:\n    m_Paths: []\n',new[171008838],flags=re.S)

# Preserve a second fragment with its Clinic references for the additive edit.
clinic_new={}
for i,s in new.items():
    clinic_new[i]=re.sub(r'\{fileID: (\d+)\}',lambda m:'{fileID: '+str(remap[int(m[1])])+'}' if int(m[1]) in remap else m[0],s)

# A standalone scene fragment retains scene references by recording a binding
# manifest. The editor importer reconnects them to the loaded Clinic objects.
bindings=[]
for i,s in new.items():
    for m in re.finditer(r'objectReference: \{fileID: (\d+)\}',s):
        refid=int(m[1])
        if refid and refid not in ids:
            bindings.append({'sourceBlock':str(remap[i]),'targetFileId':str(refid)})
    # Unresolved outside-scene references are cleared in the standalone asset.
    s=re.sub(r'\{fileID: (\d+)\}',lambda m:'{fileID: '+str(remap[int(m[1])])+'}' if int(m[1]) in remap else ('{fileID: 0}' if int(m[1]) in blocks else m[0]),s)
    new[i]=s
headers={int(m[2]):m[3] for m in re.finditer(r'^--- !u!(\d+) &(\d+)([^\n]*)',scene,re.M)}
fragment='%YAML 1.1\n%TAG !u! tag:unity3d.com,2011:\n'+''.join(f'--- !u!{blocks[i][0]} &{remap[i]}{headers[i]}\n{new[i]}' for i in sorted(ids))
ASSET.write_text(fragment,encoding='utf-8')
clinic_fragment=''.join(f'--- !u!{blocks[i][0]} &{remap[i]}{headers[i]}\n{clinic_new[i]}' for i in sorted(ids))
(OUT/'clinic-fragment.txt').write_text(clinic_fragment,encoding='utf-8')
if not Path(str(ASSET)+'.meta').exists():Path(str(ASSET)+'.meta').write_text('fileFormatVersion: 2\nguid: '+uuid.uuid4().hex+'\nDefaultImporter:\n  externalObjects: {}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n')

# Flood-fill the complete walkable map; all rooms must connect to the lobby.
walkable=all_ground-wall.keys();seen={(-1,-5,0)};q=collections.deque(seen)
while q:
    x,y,z=q.popleft()
    for p in ((x-1,y,0),(x+1,y,0),(x,y-1,0),(x,y+1,0)):
        if p in walkable and p not in seen:seen.add(p);q.append(p)
assert seen==walkable,(len(seen),len(walkable))
for x,y in doors:
    assert all((xx,yy,0) in ground and (xx,yy,0) not in wall for xx in (x,x+1) for yy in (y-1,y,y+1))
report={'sourceSceneSha256':hashlib.sha256(scene.encode()).hexdigest(),'asset':str(ASSET),'floorCells':len(ground),'sourceFloorCells':len(original_ground),'floorBounds':[53,21],'outerBounds':[55,23],'wallCells':len(wall),'walkableCells':len(walkable),'connectedWalkableCells':len(seen),'doorways':doors,'objects':len(keep),'bindings':bindings,'ids':{str(k):str(v) for k,v in remap.items()}}
(OUT/'layout-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')

# Floor plan preview is a schematic generated from the exact placed tile cells.
scale=24;margin=40
img=Image.new('RGB',(55*scale+2*margin,23*scale+100),(27,32,38));d=ImageDraw.Draw(img)
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',19)
small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',15)
def rect(x1,y1,x2,y2,fill):
    d.rectangle((margin+(x1+10)*scale,60+(16-y2)*scale,margin+(x2+11)*scale-1,60+(17-y1)*scale-1),fill=fill)
rect(-9,-5,43,15,(199,199,179))
for box,col in [((5,8,15,15),(178,193,182)),((17,8,27,15),(178,193,182)),((29,8,43,15),(173,193,198)),((5,-5,21,1),(192,183,155)),((23,-5,32,1),(187,187,199)),((34,-5,43,1),(194,182,194))]:rect(*box,col)
for x,y,z in wall:rect(x,y,x,y,(225,222,208))
for x,y in doors:rect(x,y,x+1,y,(123,89,62))
for text,x,y in [('候诊与接待',-7,10),('诊室 1',8,12),('诊室 2',20,12),('治疗室',34,12),('药房',11,-2),('男卫',26,-2),('女卫',37,-2),('4 格宽主走廊',19,4)]:
    d.text((margin+(x+10)*scale,60+(16-y)*scale),text,font=font,fill=(34,42,43))
d.text((margin,14),'FLOOR 3 · 同等面积 / 不同房间布局',font=font,fill=(240,242,240))
d.text((margin,img.height-30),'地板范围 53 × 21 格 · 外墙范围 55 × 23 格 · 6 个独立房间 · 示意图（不含家具渲染）',font=small,fill=(192,200,202))
img.save(OUT/'floor3-plan.png')
print(json.dumps({k:v for k,v in report.items() if k not in ('ids','bindings')},ensure_ascii=False,indent=2))
