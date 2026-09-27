from pathlib import Path
import json
import shutil
import hashlib
import sys
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
OUT=Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
ART=ROOT/'Assets/AIGC Source/Enemy/Silencer'
walk=Image.open(ART/'Silencer.png').convert('RGBA')
backup=OUT/'Silencer_Run_before_brightness_match.png'
if not backup.exists():
    shutil.copy2(ART/'Silencer_Run.png',backup)
run=Image.open(backup).convert('RGBA')
wa=np.array(walk)
ra=np.array(run)

def neutral_mask(a):
    rgb=a[:,:,:3].astype(np.int16)
    lum=np.rint(rgb.mean(axis=2)).astype(np.uint8)
    mask=(a[:,:,3]>192)&((rgb.max(axis=2)-rgb.min(axis=2))<=24)&(lum>=50)
    return lum,mask

wl,wm=neutral_mask(wa)
rl,rm=neutral_mask(ra)
wh=np.bincount(wl[wm],minlength=256).astype(float)
rh=np.bincount(rl[rm],minlength=256).astype(float)
wc=(np.cumsum(wh)-wh/2)/wh.sum()
rc=(np.cumsum(rh)-rh/2)/rh.sum()
valid=np.flatnonzero(wh)
lut=np.arange(256,dtype=np.uint8)
for v in np.flatnonzero(rh):
    # One monotone tonal mapping shared across ALL four frames, no local exposure shifts.
    lut[v]=round(np.interp(rc[v],wc[valid],valid))
result=ra.copy()
delta=lut[rl].astype(np.int16)-rl.astype(np.int16)
rgb=np.clip(ra[:,:,:3].astype(np.int16)+delta[:,:,None],0,255).astype(np.uint8)
result[:,:,:3][rm]=rgb[rm]
assert np.array_equal(result[:,:,3],ra[:,:,3]),'Alpha changed'
assert np.array_equal(result[~rm],ra[~rm]),'Outline or blood changed'
corrected=Image.fromarray(result)
output=OUT/'silencer_run_brightness_matched.png'
corrected.save(output)
al,am=neutral_mask(result)

comparison=Image.new('RGB',(1554,570),(227,230,232))
d=ImageDraw.Draw(comparison)
for i,(label,sheet) in enumerate((('WALK reference',walk),('RUN before',run),('RUN brightness matched',corrected))):
    d.text((i*518+16,14),label,fill=(25,30,35))
    bg=Image.new('RGBA',(518,518),(227,230,232,255))
    bg.alpha_composite(sheet.crop((0,0,518,518)))
    comparison.paste(bg.convert('RGB'),(i*518,40))
comparison.save(OUT/'silencer_brightness_comparison.png')

seq=[('walk',i) for _ in range(2) for i in range(4)]+[('run',i) for _ in range(3) for i in range(4)]+[('walk',i) for i in range(4)]
frames=[]; durations=[]
for name,i in seq:
    source=walk if name=='walk' else corrected
    bg=Image.new('RGBA',(518,550),(227,230,232,255))
    bg.alpha_composite(source.crop((i*518,0,(i+1)*518,518)),(0,28))
    ImageDraw.Draw(bg).text((16,10),name.upper(),fill=(30,35,40,255))
    frames.append(bg.convert('RGB'))
    durations.append(250 if name=='walk' else 120)
palette=Image.fromarray(np.concatenate([np.array(f).reshape(-1,3) for f in frames]).reshape(1,-1,3)).quantize(colors=256,dither=Image.Dither.NONE)
frames=[f.quantize(palette=palette,dither=Image.Dither.NONE) for f in frames]
frames[0].save(OUT/'silencer_walk_run_brightness_preview.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2,optimize=False)
stats={'walk_neutral_mean':float(wl[wm].mean()),'run_before_mean':float(rl[rm].mean()),'run_after_mean':float(al[am].mean()),'alpha_identical':True,'outline_blood_unchanged':True,'mapping':{int(v):int(lut[v]) for v in np.flatnonzero(rh)}}
print(json.dumps(stats))
if '--install' in sys.argv:
    meta=ART/'Silencer_Run.png.meta'
    before=hashlib.sha256(meta.read_bytes()).hexdigest()
    shutil.copyfile(output,ART/'Silencer_Run.png')
    assert hashlib.sha256(meta.read_bytes()).hexdigest()==before
    print('Installed brightness correction; metadata and animations untouched.')
