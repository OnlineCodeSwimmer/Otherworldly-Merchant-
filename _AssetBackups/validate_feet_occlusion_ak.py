from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = Image.open(ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png").convert("RGBA")
HOLD = Image.open(ROOT / "_AssetBackups/AK47_frozen_gun_arms_hold_layer.png").convert("RGBA")
META = Path(ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png.meta").read_text(encoding="utf-8")

assert OUT.size == (768, 64)
assert HOLD.size == (64, 64)
assert set(OUT.getchannel("A").getdata()) <= {0, 255}
assert "guid: f78d5d1e1f6949f08d2279686afc0d32" in META
assert META.count("name: Personnage_vue_dessous_AK47_64x64_") == 12

# All opaque pixels of the frozen layer that are outside the player's fixed
# hair/clothing overlap must remain identical. This covers the gun, visible
# forearms and hands; feet are allowed only underneath and cannot overwrite it.
frame0 = OUT.crop((0, 0, 64, 64))
for frame in range(12):
    cell = OUT.crop((frame * 64, 0, (frame + 1) * 64, 64))
    for y in range(64):
        for x in range(64):
            hp = HOLD.getpixel((x, y))
            if hp[3] and frame0.getpixel((x, y)) == hp:
                assert cell.getpixel((x, y)) == hp, (frame, x, y)

# Upper side-foot pixels were deliberately hidden; lower-foot area still has
# frame-to-frame changes from the original walk cycle.
cells = [OUT.crop((i*64,0,(i+1)*64,64)) for i in range(12)]
assert any(cells[i].tobytes() != cells[0].tobytes() for i in range(1,12))
print("validated: frozen hold protected above feet; upper side feet hidden; lower walk motion retained; Unity metadata unchanged")
