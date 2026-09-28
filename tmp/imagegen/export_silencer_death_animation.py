from pathlib import Path
import sys, json
from collections import deque
import numpy as np
from PIL import Image

ROOT=Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
ART=ROOT/'Assets/AIGC Source/Enemy/Silencer'
OUT=Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
src=Image.open(sys.argv[1]).convert('RGBA')
assert src.size==(1536,1024),src.size
assert (np.array(src)[:,:,3]<128).mean()>.5,'Background is not transparent'
src.putalpha(src.getchannel('A').point(lambda v:255 if v>=128 else 0))
raw=[src.crop(((i%3)*512,(i//3)*512,(i%3+1)*512,(i//3+1)*512)) for i in range(6)]
a=np.array(raw[0])
head=(a[:,:,3]>192)&(a[:,:,:3].min(2)>110)
todo=deque([(255,230)]);seen={(255,230)}
while todo:
    x,y=todo.popleft()
    for nx,ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
        if 0<=nx<512 and 0<=ny<512 and head[ny,nx] and (nx,ny) not in seen:
            seen.add((nx,ny));todo.append((nx,ny))
xx,yy=map(np.array,zip(*seen))
scale=132/(xx.max()-xx.min()+1)
cx=(xx.min()+xx.max()+1)/2;cy=(yy.min()+yy.max()+1)/2
offset=(round(320-cx*scale),round(207-cy*scale))
frames=[]
for f in raw:
    f=f.resize((round(512*scale),round(512*scale)),Image.Resampling.NEAREST)
    frame=Image.new('RGBA',(640,640));frame.paste(f,offset)
    frames.append(frame)
walk=Image.open(ART/'Silencer.png').convert('RGBA')
def graymask(a):
    rgb=a[:,:,:3].astype(np.int16);l=np.rint(rgb.mean(2)).astype(np.uint8)
    return l,(a[:,:,3]>192)&(rgb.max(2)-rgb.min(2)<=24)&(l>=50)
wa=np.array(walk);wl,wm=graymask(wa)
stack=np.concatenate([np.array(f) for f in frames])
sl,sm=graymask(stack)
wh=np.bincount(wl[wm],minlength=256).astype(float)
sh=np.bincount(sl[sm],minlength=256).astype(float)
wc=(np.cumsum(wh)-wh/2)/wh.sum();sc=(np.cumsum(sh)-sh/2)/sh.sum()
v=np.flatnonzero(wh);lut=np.rint(np.interp(sc,wc[v],v)).astype(np.uint8)
stack[:,:,:3][sm]=lut[sl[sm],None]
palette=Image.fromarray(wa[:,:,:3][wa[:,:,3]>192].reshape(1,-1,3)).quantize(colors=128,dither=Image.Dither.NONE)
for i in range(6):
    f=Image.fromarray(stack[i*640:(i+1)*640]);alpha=f.getchannel('A')
    f=f.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA');f.putalpha(alpha)
    frames[i]=f
# Exact first frame from current standing sprite to avoid an entry pop.
frames[0]=Image.new('RGBA',(640,640));frames[0].paste(walk.crop((0,0,518,518)),(61,61))
sheet=Image.new('RGBA',(1920,1280))
for i,f in enumerate(frames):
    box=f.getbbox();assert box and min(box[:2])>=8 and max(box[2:])<=632,box
    sheet.paste(f,((i%3)*640,(i//3)*640))
sheet.save(OUT/'silencer_death_animation.png')
preview=[]
for f in frames:
    bg=Image.new('RGBA',(640,640),(218,222,224,255));bg.alpha_composite(f)
    preview.append(bg.convert('RGB').resize((384,384),Image.Resampling.NEAREST))
gp=Image.fromarray(np.concatenate([np.array(f).reshape(-1,3) for f in preview]).reshape(1,-1,3)).quantize(colors=256,dither=Image.Dither.NONE)
preview=[f.quantize(palette=gp,dither=Image.Dither.NONE) for f in preview]
preview[0].save(OUT/'silencer_death_animation_preview.gif',save_all=True,append_images=preview[1:],duration=[180,110,100,90,100,1200],loop=0,disposal=2,optimize=False)
bg=Image.new('RGBA',sheet.size,(218,222,224,255));bg.alpha_composite(sheet)
bg.resize((960,640),Image.Resampling.NEAREST).save(OUT/'silencer_death_animation_frames.png')
if '--install' in sys.argv:
    target=ART/'Silencer_Death_Sheet.png';assert not target.exists()
    sheet.save(target)
print(json.dumps({'scale':scale,'offset':offset,'frames':6,'cell':[640,640],'sheet':sheet.size,'bounds':[f.getbbox() for f in frames]}))
