from pathlib import Path
from collections import deque
import sys
import json
import shutil
import numpy as np
from PIL import Image,ImageDraw

ROOT=Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
OUT=Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
ART=ROOT/'Assets/AIGC Source/Enemy/Silencer'
SOURCE=Path(r'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-b3d7b7a6-bc26-427d-b399-c9c8a6d6b0cb.png')

def head_bounds(im):
    a=np.array(im)
    mask=(a[:,:,3]>192)&(a[:,:,:3].min(2)>110)
    region=np.zeros(mask.shape,bool); region[15:255,160:355]=True; mask &=region
    seeds=np.argwhere(mask); components=[]
    for tx,ty in ((240,110),(280,110),(259,90),(259,170),(259,130)):
        sy,sx=min(seeds,key=lambda p:(p[0]-ty)**2+(p[1]-tx)**2)
        if any((int(sx),int(sy)) in c for c in components): continue
        q=deque([(int(sx),int(sy))]); seen=set(q)
        while q:
            x,y=q.popleft()
            for xx,yy in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
                if 0<=xx<518 and 0<=yy<518 and mask[yy,xx] and (xx,yy) not in seen:
                    seen.add((xx,yy));q.append((xx,yy))
        components.append(seen)
    xs,ys=zip(*max(components,key=len))
    return (min(xs),min(ys),max(xs)+1,max(ys)+1)

def gray_mask(a):
    rgb=a[:,:,:3].astype(np.int16)
    lum=np.rint(rgb.mean(2)).astype(np.uint8)
    return lum,(a[:,:,3]>192)&(rgb.max(2)-rgb.min(2)<=24)&(lum>=50)

src=Image.open(SOURCE).convert('RGBA')
assert src.size==(2172,724)
assert (np.array(src)[:,:,3]<128).mean()>0.5,'Generation has an opaque background'
raw=[src.crop((i*543+12,129,i*543+530,647)) for i in range(4)]
bounds=[head_bounds(f) for f in raw]
scale=132/np.median([b[2]-b[0] for b in bounds])
frames=[]
for i,(f,b) in enumerate(zip(raw,bounds)):
    dim=round(518*scale)
    f=f.resize((dim,dim),Image.Resampling.NEAREST)
    cx,cy=(b[0]+b[2])/2,(b[1]+b[3])/2
    target_y=(142,154,150,146)[i]
    frame=Image.new('RGBA',(518,518))
    frame.paste(f,(round(259-cx*scale),round(target_y-cy*scale)))
    frame.putalpha(frame.getchannel('A').point(lambda v:255 if v>=128 else 0))
    a=np.array(frame);rgb=a[:,:,:3].astype(np.int16)
    neutral=(rgb.max(2)-rgb.min(2))<32
    gray=np.rint(rgb.mean(2)).astype(np.uint8)
    a[:,:,:3][neutral]=np.repeat(gray[neutral,None],3,axis=1)
    frames.append(Image.fromarray(a))
sheet=Image.new('RGBA',(2072,518))
for i,f in enumerate(frames):sheet.paste(f,(i*518,0))

walk=np.array(Image.open(ART/'Silencer.png').convert('RGBA'))
run=np.array(Image.open(ART/'Silencer_Run.png').convert('RGBA'))
a=np.array(sheet)
wl,wm=gray_mask(walk);al,am=gray_mask(a)
wh=np.bincount(wl[wm],minlength=256).astype(float)
ah=np.bincount(al[am],minlength=256).astype(float)
wc=(np.cumsum(wh)-wh/2)/wh.sum();ac=(np.cumsum(ah)-ah/2)/ah.sum()
valid=np.flatnonzero(wh);lut=np.arange(256,dtype=np.uint8)
for v in np.flatnonzero(ah):lut[v]=round(np.interp(ac[v],wc[valid],valid))
delta=lut[al].astype(np.int16)-al.astype(np.int16)
rgb=np.clip(a[:,:,:3].astype(np.int16)+delta[:,:,None],0,255).astype(np.uint8)
a[:,:,:3][am]=rgb[am]
sheet=Image.fromarray(a)
reference_colors=np.concatenate([r[:,:,:3][r[:,:,3]>192] for r in (walk,run)])
palette=Image.fromarray(reference_colors.reshape(1,-1,3)).quantize(colors=128,dither=Image.Dither.NONE)
alpha=sheet.getchannel('A')
sheet=sheet.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA')
sheet.putalpha(alpha)
frames=[sheet.crop((i*518,0,(i+1)*518,518)) for i in range(4)]
sheet.save(OUT/'silencer_attack.png')

preview=Image.new('RGBA',sheet.size,(227,230,232,255));preview.alpha_composite(sheet)
preview.convert('RGB').save(OUT/'silencer_attack_frames.png')
gif_frames=[]
for i,f in enumerate(frames):
    bg=Image.new('RGBA',(518,550),(227,230,232,255));bg.alpha_composite(f,(0,28))
    ImageDraw.Draw(bg).text((15,10),('WIND-UP','STRIKE','GRAB','RECOVER')[i],fill=(30,35,40,255))
    gif_frames.append(bg.convert('RGB'))
gif_palette=Image.fromarray(np.concatenate([np.array(f).reshape(-1,3) for f in gif_frames]).reshape(1,-1,3)).quantize(colors=256,dither=Image.Dither.NONE)
gif_frames=[f.quantize(palette=gif_palette,dither=Image.Dither.NONE) for f in gif_frames]
gif_frames[0].save(OUT/'silencer_attack_preview.gif',save_all=True,append_images=gif_frames[1:],duration=[180,80,100,200],loop=0,disposal=2,optimize=False)
head_after=[head_bounds(f) for f in frames]
for f in frames:
    box=f.getbbox()
    assert box and min(box[:2])>=8 and max(box[2:])<=510, ('clipped sprite or matte',box)
for b in head_after:
    assert 128<=b[2]-b[0]<=136,(b,'head scale drift')
    assert abs((b[0]+b[2])/2-259)<=1.5,(b,'head anchor drift')
out_a=np.array(sheet);ol,om=gray_mask(out_a)
print(json.dumps({'frame_count':4,'cell':[518,518],'uniform_scale':float(scale),'head_bounds':head_after,'alpha_bounds':[f.getbbox() for f in frames],'walk_neutral_mean':float(wl[wm].mean()),'attack_neutral_mean':float(ol[om].mean())}))
if '--install' in sys.argv:
    target=ART/'Silencer_Attack.png'
    assert not target.exists(),'Refusing to overwrite an existing attack asset'
    shutil.copyfile(OUT/'silencer_attack.png',target)
    print('Installed new attack sprite sheet only: '+str(target))
