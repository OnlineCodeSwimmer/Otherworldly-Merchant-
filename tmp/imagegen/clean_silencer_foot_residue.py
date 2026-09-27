from pathlib import Path
import shutil
import hashlib
import sys
import json
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

ROOT=Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
OUT=Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
TARGET=ROOT/'Assets/AIGC Source/Enemy/Silencer/Silencer.png'
BACKUP=OUT/'Silencer_before_foot_residue_cleanup.png'
if not BACKUP.exists():
    shutil.copy2(TARGET,BACKUP)
src=Image.open(BACKUP).convert('RGBA')
a=np.array(src)
b=a.copy()
counts=[]
for i in range(4):
    cell=a[:,i*518:(i+1)*518]
    alpha=Image.fromarray(cell[:,:,3])
    # Source logical pixel blocks are ~10px. Discard thin sub-pixel spurs only.
    opened=np.array(alpha.filter(ImageFilter.MinFilter(9)).filter(ImageFilter.MaxFilter(9)))
    narrow=(cell[:,:,3]>0)&(opened==0)
    region=np.zeros((518,518),bool)
    region[218:282,175:242]=True
    region[218:282,275:342]=True
    removal=narrow&region&(cell[:,:,:3].max(axis=2)<100)
    b[:,i*518:(i+1)*518,3][removal]=0
    counts.append(int(removal.sum()))
assert np.array_equal(a[:,:,:3],b[:,:,:3]),'RGB colors changed'
assert not np.any(b[:,:,3]>a[:,:,3]),'New pixels added'
fixed=Image.fromarray(b)
fixed.save(OUT/'silencer_walk_feet_clean.png')
preview=Image.new('RGBA',(2004,520),(190,190,190,255))
for row,im in enumerate((src,fixed)):
    for i in range(4):
        crop=im.crop((i*518+175,212,i*518+342,290)).resize((501,234),Image.Resampling.NEAREST)
        preview.alpha_composite(crop,(i*501,row*260+24))
ImageDraw.Draw(preview).text((8,5),'BEFORE',(20,20,20,255))
ImageDraw.Draw(preview).text((8,265),'AFTER',(20,20,20,255))
preview.convert('RGB').save(OUT/'silencer_foot_residue_comparison.png')
print(json.dumps({'removed_dark_edge_pixels_per_frame':counts,'all_colors_unchanged':True,'only_foot_edge_alpha_changed':True}))
if '--install' in sys.argv:
    mh=hashlib.sha256(TARGET.with_suffix('.png.meta').read_bytes()).hexdigest()
    shutil.copyfile(OUT/'silencer_walk_feet_clean.png',TARGET)
    assert hashlib.sha256(TARGET.with_suffix('.png.meta').read_bytes()).hexdigest()==mh
    print('Installed only Walk PNG; Run, metadata and animations untouched.')
