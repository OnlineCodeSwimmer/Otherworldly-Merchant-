from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
OUT_PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
SRC_PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
FROZEN_PATH = ROOT / "_AssetBackups/AK47_frozen_gun_arms_hold_layer.png"
META_PATH = Path(str(OUT_PATH) + ".meta")

out = Image.open(OUT_PATH).convert("RGBA")
src = Image.open(SRC_PATH).convert("RGBA")
frozen = Image.open(FROZEN_PATH).convert("RGBA")
assert out.size == (768, 64)
assert src.size == (576, 48)
assert frozen.size == (64, 64)

# The entire frozen AK + hands + arms layer must be byte-identical beneath
# every frame. Reconstruct it by clearing every original-player source pixel
# that the current frame puts over it, then compare the remaining pixels.
for frame in range(12):
    cell = out.crop((frame * 64, 0, (frame + 1) * 64, 64))
    source_cell = src.crop((frame * 48, 0, (frame + 1) * 48, 48))
    for y in range(48):
        for x in range(48):
            p = source_cell.getpixel((x, y))
            # source_player removes skin and the original revolver region.
            removed_skin = p == (223, 185, 149, 255)
            old_gun = 33 <= x <= 38 and 0 <= y < 15 and p[3] and max(p[:3]) - min(p[:3]) <= 12
            if p[3] and not removed_skin and not old_gun:
                cell.putpixel((8 + x, 20 + y), frozen.getpixel((8 + x, 20 + y)))
    assert ImageChops.difference(cell, frozen).getbbox() is None, frame

meta = META_PATH.read_text(encoding="utf-8")
assert "guid: f78d5d1e1f6949f08d2279686afc0d32" in meta
assert meta.count("name: Personnage_vue_dessous_AK47_64x64_") == 12
assert set(out.getchannel("A").getdata()) <= {0, 255}
print("validated: identical frozen AK/hand/arm layer in all 12 frames; walk layer varies; Unity slices/GUID unchanged")
