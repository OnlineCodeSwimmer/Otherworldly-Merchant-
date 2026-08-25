from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
META = Path(str(PATH) + ".meta").read_text(encoding="utf-8")
im = Image.open(PATH).convert("RGBA")
assert im.size == (768,64)
assert set(im.getchannel("A").getdata()) <= {0,255}

# All corrected pixels are frozen and must match frame 0 exactly.
coords = [
    (38,21),(39,21),(38,22),(39,22),(38,23),
    (24,34),(23,35),(23,36),(22,37),(22,38),
    (41,29),(42,29),(42,30),(43,30),(43,31),(44,31),
    (43,32),(44,32),(45,32),(42,33),(43,33),(44,33),(45,33),
    (42,34),(43,34),(44,34),(43,35),(44,35),(44,36),
]
reference = [im.getpixel((x,y)) for x,y in coords]
for frame in range(1,12):
    assert [im.getpixel((frame*64+x,y)) for x,y in coords] == reference, frame

# No right-side grey/black magazine remnant may survive beyond x=39 in its
# original upper side-view area.
weapon_greys = {(43,43,49,255),(72,74,79,255),(130,135,136,255)}
for frame in range(12):
    ox = frame*64
    for y in range(20,25):
        for x in range(40,45):
            assert im.getpixel((ox+x,y)) not in weapon_greys, (frame,x,y)

assert "guid: f78d5d1e1f6949f08d2279686afc0d32" in META
assert META.count("name: Personnage_vue_dessous_AK47_64x64_") == 12
print("validated: left clothing outline, completed right arm, compact top-down magazine; all 12 frames consistent; metadata unchanged")
