from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(r'E:\UnityTest\Otherworldly-Merchant-\Otherworldly Merchant')
ART = ROOT / 'Assets/AIGC Source/Enemy/Silencer'
OUT = Path(r'C:\Users\望兴腾\.codex\visualizations\2026\09\27\01a0e2f9-6c16-77e3-93cb-9192d84247fe')
SOURCE = Path(r'C:\Users\望兴腾\.codex\generated_images\01a0e2f9-6c16-77e3-93cb-9192d84247fe\exec-cb15d906-4c56-49ea-a10f-b5cc8bca0c95.png')
target = ART / 'Silencer_Death.png'
assert not target.exists(), 'Do not overwrite an existing asset'
im = Image.open(SOURCE).convert('RGBA')
a = np.array(im)
assert (a[:, :, 3] < 128).mean() > .6
im.putalpha(im.getchannel('A').point(lambda v: 255 if v >= 128 else 0))
# Match the visible skull width to the existing monster, without stretching.
scale = 132 / 173
im = im.crop(im.getbbox())
im = im.resize(tuple(round(d * scale) for d in im.size), Image.Resampling.NEAREST)
a = np.array(im)
walk = np.array(Image.open(ART / 'Silencer.png').convert('RGBA'))
def neutrals(x):
    rgb = x[:, :, :3].astype(np.int16)
    lum = np.rint(rgb.mean(2)).astype(np.uint8)
    return lum, (x[:, :, 3] > 192) & (rgb.max(2)-rgb.min(2) <= 24) & (lum >= 50)
wl, wm = neutrals(walk)
dl, dm = neutrals(a)
wh = np.bincount(wl[wm], minlength=256).astype(float)
dh = np.bincount(dl[dm], minlength=256).astype(float)
wc = (np.cumsum(wh)-wh/2)/wh.sum()
dc = (np.cumsum(dh)-dh/2)/dh.sum()
levels = np.flatnonzero(wh)
lut = np.rint(np.interp(dc, wc[levels], levels)).astype(np.uint8)
a[:, :, :3][dm] = lut[dl[dm], None]
im = Image.fromarray(a)
size = tuple(((d+63)//64+1)*64 for d in im.size)
canvas = Image.new('RGBA', size)
canvas.paste(im, ((size[0]-im.width)//2, (size[1]-im.height)//2))
canvas.save(target)
preview = canvas.copy()
preview.thumbnail((420, 600), Image.Resampling.NEAREST)
preview.save(OUT / 'silencer_death_preview.png')
assert set(np.unique(np.array(canvas)[:, :, 3])) == {0, 255}
print({'file': str(target), 'size': size, 'body_bounds': canvas.getbbox(), 'scale': scale, 'transparent': True})
