from pathlib import Path
from collections import deque
import json
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
OUT = Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
ART = ROOT / 'Assets/AIGC Source/Enemy/Silencer'
WALK_SOURCE = Path(r'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-3b31fdf7-e2cd-4a64-a6cc-993d223e2b02.png')

def head_bounds(im):
    a = np.array(im)
    mask = (a[:,:,3] > 192) & (a[:,:,:3].min(axis=2) > 110)
    region = np.zeros(mask.shape, bool)
    region[15:255,160:355] = True
    mask &= region
    seeds = np.argwhere(mask)
    components=[]
    for tx,ty in ((240,110),(280,110),(259,90),(259,170),(259,130)):
        sy,sx = min(seeds, key=lambda p:(p[0]-ty)**2+(p[1]-tx)**2)
        if any((int(sx),int(sy)) in c for c in components):
            continue
        q = deque([(int(sx),int(sy))])
        seen = set(q)
        while q:
            x,y=q.popleft()
            for xx,yy in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
                if 0 <= xx < 518 and 0 <= yy < 518 and mask[yy,xx] and (xx,yy) not in seen:
                    seen.add((xx,yy)); q.append((xx,yy))
        components.append(seen)
    seen=max(components,key=len)
    xs,ys=zip(*seen)
    return (min(xs),min(ys),max(xs)+1,max(ys)+1)

src = Image.open(WALK_SOURCE).convert('RGBA')
walk = [src.crop((i*543+12,129,i*543+530,647)) for i in range(4)]
run_sheet = Image.open(OUT / 'silencer_run_original_style_unity.png').convert('RGBA')
run = [run_sheet.crop((i*518,0,(i+1)*518,518)) for i in range(4)]
print(json.dumps({'walk_heads':[head_bounds(f) for f in walk], 'run_heads':[head_bounds(f) for f in run]}))

# Reapply the user-approved, precise shadow trim to the full-detail Walk source.
before_trim = Image.open(OUT / 'Silencer_before_precise_perimeter_trim.png').convert('RGBA')
after_trim = Image.open(OUT / 'silencer_idle_precise_foot_shadow.png').convert('RGBA')
for i in range(4):
    aa = np.array(before_trim.crop((i*48,0,(i+1)*48,48)))[:,:,3]
    bb = np.array(after_trim.crop((i*48,0,(i+1)*48,48)))[:,:,3]
    trim = Image.fromarray(np.uint8((aa>0)&(bb==0))*255).resize((518,518),Image.Resampling.NEAREST)
    a = np.array(walk[i])
    # Preserve physical grey toes even if a coarse mask overlaps their edge.
    a[:,:,3][(np.array(trim)>0)&(a[:,:,:3].max(axis=2)<65)] = 0
    walk[i] = Image.fromarray(a)

raw_clips = {'walk':walk,'run':run}
clips = {}
audit = {}
for name,frames in raw_clips.items():
    bounds = [head_bounds(f) for f in frames]
    median_width = float(np.median([b[2]-b[0] for b in bounds]))
    # One scale for an entire clip, never independently scaling its frames.
    scale = 132.0 / median_width
    out_frames = []
    movements = []
    for i,(f,b) in enumerate(zip(frames,bounds)):
        newsize = round(518*scale)
        f = f.resize((newsize,newsize),Image.Resampling.NEAREST)
        cx,cy=(b[0]+b[2])/2,(b[1]+b[3])/2
        target_y = 146-(4 if name=='walk' else 8)*(i%2)
        dx,dy=round(259-cx*scale),round(target_y-cy*scale)
        canvas=Image.new('RGBA',(518,518))
        canvas.paste(f,(dx,dy))
        canvas.putalpha(canvas.getchannel('A').point(lambda v:255 if v>=128 else 0))
        if name=='run' and i%2:
            # Raising the generated shoulders had also stretched the forearms.
            # The area below y=300 contains arms only; retain the same hand reach.
            tail=canvas.crop((0,327,518,518))
            canvas.paste((0,0,0,0),(0,300,518,518))
            canvas.paste(tail,(0,300))
        # Neutralize tiny color casts in skin/shading, retaining red blood.
        pixels=np.array(canvas)
        rgb=pixels[:,:,:3].astype(np.int16)
        neutral=(rgb.max(axis=2)-rgb.min(axis=2))<32
        grey=np.rint(rgb.mean(axis=2)).astype(np.uint8)
        pixels[:,:,:3][neutral]=np.repeat(grey[neutral,None],3,axis=1)
        canvas=Image.fromarray(pixels)
        out_frames.append(canvas)
        movements.append({'offset':[dx,dy],'head_target':[259,target_y]})
    clips[name]=out_frames
    audit[name]={'uniform_scale':scale,'registration':movements}

# Apply one shared, sufficiently detailed palette to both animations.
opaque=np.concatenate([np.array(f)[:,:,:3][np.array(f)[:,:,3]>0] for fs in clips.values() for f in fs])
palette=Image.fromarray(opaque.reshape(1,-1,3)).quantize(colors=64,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE)
for name,frames in clips.items():
    sheet=Image.new('RGBA',(2072,518))
    for i,f in enumerate(frames):
        alpha=f.getchannel('A')
        f=f.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA')
        f.putalpha(alpha)
        frames[i]=f
        sheet.paste(f,(i*518,0))
    sheet.save(OUT / ('silencer_'+name+'_unified.png'))
    audit[name]['heads_after']=[head_bounds(f) for f in frames]
    audit[name]['bounds']=[f.getbbox() for f in frames]
    for b in audit[name]['heads_after']:
        assert 130 <= b[2]-b[0] <= 134, (name,b)
        assert abs((b[0]+b[2])/2-259) <= 1, (name,b)

comparison=Image.new('RGB',(1092,1116),(227,230,232))
draw=ImageDraw.Draw(comparison)
draw.text((25,12),'WALK - RUN / SAME SCALE, SAME PALETTE',(30,35,40))
for row,idx in enumerate((0,1)):
    for col,name in enumerate(('walk','run')):
        bg=Image.new('RGBA',(518,518),(227,230,232,255))
        bg.alpha_composite(clips[name][idx])
        comparison.paste(bg.convert('RGB'),(col*546,38+row*534))
comparison.save(OUT / 'silencer_walk_run_unified_comparison.png')

# Preview a cut between clips at a common pivot, without touching Unity animation files.
sequence=[('walk',i) for _ in range(2) for i in range(4)]+[('run',i) for _ in range(3) for i in range(4)]+[('walk',i) for i in range(4)]
gifframes=[]
durations=[]
for name,i in sequence:
    bg=Image.new('RGBA',(518,550),(227,230,232,255))
    bg.alpha_composite(clips[name][i],(0,28))
    d=ImageDraw.Draw(bg)
    d.text((16,10),name.upper(),fill=(30,35,40,255))
    gifframes.append(bg.convert('RGB'))
    durations.append(250 if name=='walk' else 120)
gifpalette=Image.fromarray(np.concatenate([np.array(f).reshape(-1,3) for f in gifframes]).reshape(1,-1,3)).quantize(colors=128,dither=Image.Dither.NONE)
gifframes=[f.quantize(palette=gifpalette,dither=Image.Dither.NONE) for f in gifframes]
gifframes[0].save(OUT / 'silencer_walk_run_switch_preview.gif',save_all=True,append_images=gifframes[1:],duration=durations,loop=0,disposal=2,optimize=False)
print(json.dumps(audit))
