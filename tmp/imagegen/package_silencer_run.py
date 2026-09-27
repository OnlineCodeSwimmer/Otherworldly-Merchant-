from pathlib import Path
import json
import sys
import shutil
import numpy as np
from PIL import Image

OUT = Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
SOURCE = Path(r'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-cea3aece-4ce7-4f5b-bb87-4b36980cb113.png')
TARGET = Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant\Assets\AIGC Source\Enemy\Silencer\Silencer_Run.png')
src = Image.open(SOURCE).convert('RGBA')
assert src.size == (2172, 724), src.size
sheet = Image.new('RGBA', (192, 48))
for i in range(4):
    # One shared scale and crop; never normalize individual frame sizes.
    frame = src.crop((i*543+12, 129, i*543+530, 647)).resize((48, 48), Image.Resampling.NEAREST)
    frame.putalpha(frame.getchannel('A').point(lambda p: 255 if p >= 128 else 0))
    sheet.paste(frame, (i*48, 0))
alpha = sheet.getchannel('A')
rgb = np.array(sheet)[:,:,:3][np.array(alpha)>0]
palette = Image.fromarray(rgb.reshape(1,-1,3)).quantize(colors=24, dither=Image.Dither.NONE)
sheet = sheet.convert('RGB').quantize(palette=palette, dither=Image.Dither.NONE).convert('RGBA')
sheet.putalpha(alpha)
sheet.save(OUT / 'silencer_run.png')
frames = [sheet.crop((i*48,0,(i+1)*48,48)) for i in range(4)]
preview = Image.new('RGBA', sheet.size, (150,154,158,255))
preview.alpha_composite(sheet)
preview.resize((1536,384), Image.Resampling.NEAREST).convert('RGB').save(OUT / 'silencer_run_frames.png')
gifpalette = preview.convert('RGB').quantize(colors=32, dither=Image.Dither.NONE)
gifframes = []
for f in frames:
    bg = Image.new('RGBA', (48,48), (150,154,158,255))
    bg.alpha_composite(f)
    gifframes.append(bg.convert('RGB').resize((384,384),Image.Resampling.NEAREST).quantize(palette=gifpalette,dither=Image.Dither.NONE))
gifframes[0].save(OUT / 'silencer_run_preview.gif', save_all=True, append_images=gifframes[1:], duration=120, loop=0, disposal=2, optimize=False)
print(json.dumps({'size':sheet.size,'frames':4,'bounds':[f.getbbox() for f in frames]}))
if '--install' in sys.argv:
    assert not TARGET.exists(), 'Refusing to replace an existing Run sprite.'
    shutil.copyfile(OUT / 'silencer_run.png', TARGET)
    print('Saved new run sprite: '+str(TARGET))
