"""Offline sprite projection for placement QA (not a Unity camera capture)."""
from pathlib import Path
import re, functools, numpy as np
from PIL import Image, ImageDraw, ImageFont
from inspect_scene import ROOT, field, ref, vec

def parse(text):
    return {int(m[2]):(int(m[1]),m[3]) for m in re.finditer(r'^--- !u!(\d+) &(-?\d+)[^\n]*\n(.*?)(?=^--- !u!|\Z)',text,re.M|re.S)}

guidpath={}
for p in (ROOT/'Assets').rglob('*.meta'):
    s=p.read_text(encoding='utf-8-sig',errors='replace');m=re.search(r'^guid: (\w+)',s,re.M)
    if m:guidpath[m[1]]=Path(str(p)[:-5])

def matrix(s):
    p=vec(s,'m_LocalPosition') or [0,0,0];q=vec(s,'m_LocalRotation') or [0,0,0,1];sc=vec(s,'m_LocalScale') or [1,1,1]
    x,y,z,w=q
    return np.array([[(1-2*(y*y+z*z))*sc[0],2*(x*y-z*w)*sc[1],p[0]],
                     [2*(x*y+z*w)*sc[0],(1-2*(x*x+z*z))*sc[1],p[1]],[0,0,1.]])

@functools.lru_cache(None)
def sprite(fid,guid):
    path=guidpath[guid];s=Path(str(path)+'.meta').read_text(encoding='utf-8-sig')
    im=Image.open(path).convert('RGBA');ppu=float(re.search(r'spritePixelsToUnits: ([\d.]+)',s)[1])
    mode=int(re.search(r'spriteMode: (\d+)',s)[1]);pivot=[.5,.5]
    if mode==2:
        entries=re.split(r'    - serializedVersion:',s[s.index('    sprites:'):])
        entry=next(e for e in entries if re.search(r'\binternalID: '+str(fid)+r'\b',e))
        r=re.search(r'      rect:\n(.*?)(?=      alignment:)',entry,re.S)[1]
        nums={k:float(v) for k,v in re.findall(r'        (x|y|width|height): ([-\d.]+)',r)}
        im=im.crop((int(nums['x']),im.height-int(nums['y']+nums['height']),int(nums['x']+nums['width']),im.height-int(nums['y'])))
        align=int(re.search(r'      alignment: (\d+)',entry)[1])
        if align==9:pivot=list(map(float,re.search(r'pivot: \{x: ([\d.]+), y: ([\d.]+)',entry).groups()))
    else:
        align=int(re.search(r'  alignment: (\d+)',s)[1])
        if align==9:pivot=list(map(float,re.search(r'spritePivot: \{x: ([\d.eE+-]+), y: ([\d.eE+-]+)',s).groups()))
    return im,ppu,pivot

def modify(s,prop,value):
    if '.' in prop:
        key,axis=prop.rsplit('.',1)
        if axis in ('x','y','z','w'):
            return re.sub(r'(^  '+re.escape(key)+r': \{[^\n]*?\b'+axis+r': )[^,}]+',lambda m:m[1]+value,s,flags=re.M)
    return re.sub(r'(^  '+re.escape(prop)+r': )[^\n]*',lambda m:m[1]+value,s,flags=re.M)

items=[];colliders=[];hinges=[]
def emit_components(bs,tid,m,name):
    go=ref(bs[tid][1],'m_GameObject')
    if not go or go not in bs:return
    if field(bs[go][1],'m_IsActive')=='0':return
    for cid in re.findall(r'component: \{fileID: (-?\d+)',bs[go][1]):
        kind,s=bs[int(cid)]
        if field(s,'m_Enabled','1')=='0':continue
        if kind==212:
            spr=re.search(r'm_Sprite: \{fileID: (-?\d+), guid: (\w+)',s)
            if spr:
                try:
                    im,ppu,pivot=sprite(int(spr[1]),spr[2]);w,h=im.size
                    flipx=-1 if field(s,'m_FlipX')=='1' else 1;flipy=-1 if field(s,'m_FlipY')=='1' else 1
                    local=np.array([[flipx/ppu,0,-flipx*pivot[0]*w/ppu],[0,-flipy/ppu,flipy*(1-pivot[1])*h/ppu],[0,0,1.]])
                    items.append((int(field(s,'m_SortingOrder','0')),m[1,2],im,m@local,name))
                except Exception as e:print('SPRITE',name,str(e))
        elif kind==61 and field(s,'m_IsTrigger')=='0':
            off=vec(s,'m_Offset') or [0,0];size=vec(s,'m_Size')
            if size:
                pts=np.array([[off[0]-size[0]/2,off[1]-size[1]/2,1],[off[0]+size[0]/2,off[1]-size[1]/2,1],[off[0]+size[0]/2,off[1]+size[1]/2,1],[off[0]-size[0]/2,off[1]+size[1]/2,1]])
                colliders.append((name,(m@pts.T).T[:,:2]))

def render_prefab(guid,source_tid,inst,parent,instance_id):
    bs=parse(guidpath[guid].read_text(encoding='utf-8-sig'))
    for mm in re.finditer(r'    - target: \{fileID: (-?\d+), guid: (\w+), type: \d+\}\n      propertyPath: ([^\n]*)\n      value: ([^\n]*)',inst):
        tid=int(mm[1])
        if tid in bs and mm[2]==guid:bs[tid]=(bs[tid][0],modify(bs[tid][1],mm[3],mm[4]))
    if source_tid not in bs:return parent
    cache={}
    def world(tid):
        if tid in cache:return cache[tid]
        s=bs[tid][1];par=ref(s,'m_Father')
        cache[tid]=(world(par) if par in bs and tid!=source_tid else parent)@matrix(s)
        return cache[tid]
    for tid,(kind,s) in bs.items():
        if kind==4 and 'm_GameObject:' in s:
            go=ref(s,'m_GameObject');name=field(bs[go][1],'m_Name')
            emit_components(bs,tid,world(tid),name)
        elif kind==233 and ref(s,'m_ConnectedRigidBody')==0:
            go=ref(s,'m_GameObject')
            owner=next(t for t,(k,ts) in bs.items() if k==4 and ref(ts,'m_GameObject')==go)
            anchor=vec(s,'m_Anchor') or [0,0]
            point=world(owner)@np.array([anchor[0],anchor[1],1])
            hinges.append({'instance':instance_id,'component':tid,'guid':guid,'x':point[0],'y':point[1]})
    return world(source_tid)

bs=parse((ROOT/'Assets/Scenes/Clinic Floor 3 Layout.unity').read_text())
cache={}
def world(tid):
    if tid in cache:return cache[tid]
    kind,s=bs[tid]
    if 'm_GameObject:' in s:
        par=ref(s,'m_Father');m=(world(par) if par in bs else np.eye(3))@matrix(s)
        cache[tid]=m
        emit_components(bs,tid,m,field(bs[ref(s,'m_GameObject')][1],'m_Name'))
    else:
        inst=bs[ref(s,'m_PrefabInstance')][1];par=ref(inst,'m_TransformParent')
        source=re.search(r'm_CorrespondingSourceObject: \{fileID: (-?\d+), guid: (\w+)',s)
        cache[tid]=render_prefab(source[2],int(source[1]),inst,world(par) if par in bs else np.eye(3),ref(s,'m_PrefabInstance'))
    return cache[tid]
for tid,(kind,s) in bs.items():
    if kind==4:world(tid)

S=30;W=55*S+80;H=23*S+100
canvas=Image.new('RGBA',(W,H),(31,34,39,255))
camera=np.array([[S,0,40+10*S-237.88*S],[0,-S,60+17*S],[0,0,1.]])
def paste(im,m):
    screen=camera@m
    points=screen@np.array([[0,im.width,0,im.width],[0,0,im.height,im.height],[1,1,1,1]])
    xmin=max(0,int(np.floor(points[0].min())));xmax=min(W,int(np.ceil(points[0].max())))
    ymin=max(0,int(np.floor(points[1].min())));ymax=min(H,int(np.ceil(points[1].max())))
    if xmax<=xmin or ymax<=ymin:return
    inv=np.linalg.inv(screen)@np.array([[1,0,xmin],[0,1,ymin],[0,0,1.]])
    layer=im.transform((xmax-xmin,ymax-ymin),Image.Transform.AFFINE,tuple(inv[:2].flatten()),Image.Resampling.NEAREST)
    canvas.alpha_composite(layer,(xmin,ymin))

for cid,(kind,s) in sorted(bs.items(),key=lambda item: 0 if item[1][0]==1839735485 and '  m_TileAssetArray:\n  - m_RefCount: 1062' in item[1][1] else 1):
    if kind!=1839735485:continue
    go=ref(s,'m_GameObject');tid=int(re.search(r'component: \{fileID: (\d+)',bs[go][1])[1]);m=world(tid)
    arr=s[s.index('  m_TileSpriteArray:'):s.index('  m_TileMatrixArray:')]
    refs=re.findall(r'm_Data: \{fileID: (-?\d+)(?:, guid: (\w+), type: \d+)?\}',arr)
    for t in re.finditer(r'first: \{x: (-?\d+), y: (-?\d+), z: -?\d+\}.*?m_TileSpriteIndex: (\d+)',s,re.S):
        sid,sg=refs[int(t[3])]
        im,ppu,pivot=sprite(int(sid),sg);w,h=im.size
        local=np.array([[1/ppu,0,int(t[1])+.5-pivot[0]*w/ppu],[0,-1/ppu,int(t[2])+.5+(1-pivot[1])*h/ppu],[0,0,1.]])
        paste(im,m@local)
for order,y,im,m,name in sorted(items,key=lambda a:(a[0],-a[1])):paste(im,m)
d=ImageDraw.Draw(canvas);font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22)
d.text((40,15),'Floor 3 · 原素材位置预览（离线投影，未含 Unity 灯光）',font=font,fill='white')
canvas.save(ROOT/'tmp/floor-layout/floor3-sprites.png')
print('Rendered',len(items),'sprites,',len(colliders),'box colliders')
import json
(ROOT/'tmp/floor-layout/furniture-bounds.json').write_text(json.dumps([{'name':name,'points':(pts-np.array([237.88,0])).tolist()} for name,pts in colliders],indent=2))
