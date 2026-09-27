from pathlib import Path
import hashlib
import json
import shutil
import sys

import numpy as np
from PIL import Image

ROOT = Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
OUT = Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
SOURCE = Path(r'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-d552239e-11be-4231-ac37-e8d95742ffbd.png')
TARGET = ROOT / 'Assets/AIGC Source/Enemy/Silencer/Silencer.png'
NO_SHADOW = '--no-shadow' in sys.argv
NAME = 'silencer_idle_no_shadow' if NO_SHADOW else 'silencer_idle_v2'
TOP = 150 if NO_SHADOW else 129
if NO_SHADOW:
    SOURCE = SOURCE.with_name('exec-790711e5-faa0-42eb-9661-16de52527e0b.png')
RESTORED = '--restored' in sys.argv
if RESTORED:
    SOURCE = SOURCE.with_name('exec-5848032f-d871-43c9-9267-e34e92515ec0.png')
    NAME = 'silencer_idle_anatomy_restored'
    TOP = 129
FEET_ONLY = '--feet-only' in sys.argv
if FEET_ONLY:
    SOURCE = SOURCE.with_name('exec-3b31fdf7-e2cd-4a64-a6cc-993d223e2b02.png')
    NAME = 'silencer_idle_feet_no_shadow'
    TOP = 129

src = Image.open(SOURCE).convert('RGBA')
frames = []
for i in range(4):
    # All frames use exactly the same crop and scale to retain generated motion.
    cell = src.crop((i * 543 + 12, TOP, i * 543 + 530, TOP + 518))
    frame = cell.resize((48, 48), Image.Resampling.NEAREST)
    cutoff = 128 if RESTORED or FEET_ONLY else 200
    frame.putalpha(frame.getchannel('A').point(lambda p: 255 if p >= cutoff else 0))
    frames.append(frame)

sheet = Image.new('RGBA', (192, 48))
for i, frame in enumerate(frames):
    sheet.paste(frame, (48 * i, 0))
# Shared color quantization prevents palette flicker between frames.
alpha = sheet.getchannel('A')
opaque_colors = np.array(sheet)[:, :, :3][np.array(alpha) > 0]
palette_source = Image.fromarray(opaque_colors.reshape(1, -1, 3)).quantize(
    colors=24 if FEET_ONLY else 16, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
sheet = sheet.convert('RGB').quantize(palette=palette_source,
                                    dither=Image.Dither.NONE).convert('RGBA')
sheet.putalpha(alpha)
frames = [sheet.crop((i * 48, 0, (i + 1) * 48, 48)) for i in range(4)]
sheet.save(OUT / (NAME + '.png'))

preview = Image.new('RGBA', (192, 48), (119, 125, 130, 255))
preview.alpha_composite(sheet)
preview.resize((1536, 384), Image.Resampling.NEAREST).convert('RGB').save(OUT / (NAME + '_frames.png'))
gif_frames = []
for frame in frames:
    bg = Image.new('RGBA', (48, 48), (119, 125, 130, 255))
    bg.alpha_composite(frame)
    gif_frames.append(bg.convert('RGB').resize((384, 384), Image.Resampling.NEAREST))
palette = preview.convert('RGB').quantize(colors=32, dither=Image.Dither.NONE)
gif_frames = [f.quantize(palette=palette, dither=Image.Dither.NONE) for f in gif_frames]
gif_frames[0].save(OUT / (NAME + '_preview.gif'), save_all=True,
                   append_images=gif_frames[1:], duration=250, loop=0, disposal=2,
                   optimize=False)

stats = {'size': sheet.size, 'bboxes': [f.getbbox() for f in frames],
         'changed_pixels_per_transition': [int(np.any(np.array(frames[i]) != np.array(frames[(i+1)%4]), axis=2).sum()) for i in range(4)],
         'source': str(SOURCE)}
print(json.dumps(stats))

if '--install' in __import__('sys').argv:
    backup = OUT / ('Silencer_before_shadow_removal.png' if NO_SHADOW else 'Silencer_before_idle_redraw.png')
    if RESTORED:
        backup = OUT / 'Silencer_before_anatomy_restoration.png'
    if FEET_ONLY:
        backup = OUT / 'Silencer_before_feet_shadow_fix.png'
    if not backup.exists():
        shutil.copy2(TARGET, backup)
    meta = TARGET.with_suffix('.png.meta')
    meta_before = hashlib.sha256(meta.read_bytes()).hexdigest()
    shutil.copyfile(OUT / (NAME + '.png'), TARGET)
    assert hashlib.sha256(meta.read_bytes()).hexdigest() == meta_before
    assert Image.open(TARGET).size == (192, 48)
    print('Installed PNG; existing Unity metadata unchanged.')
