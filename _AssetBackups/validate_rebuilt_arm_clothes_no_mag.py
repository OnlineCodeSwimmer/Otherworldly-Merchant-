from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
META = Path(str(PATH) + ".meta").read_text(encoding="utf-8")
im = Image.open(PATH).convert("RGBA")
assert im.size == (768,64)
assert set(im.getchannel("A").getdata()) <= {0,255}

weapon_greys = {(43,43,49,255),(72,74,79,255),(130,135,136,255)}
skin = {(223,185,149,255),(196,153,119,255)}
cloth = {(255,255,255,255),(201,199,199,255)}

# No side magazine survives to the right of the receiver.
for frame in range(12):
    ox = frame*64
    for y in range(19,26):
        for x in range(38,45):
            assert im.getpixel((ox+x,y)) not in weapon_greys, (frame,x,y)

# The rebuilt right arm is a continuous skin path and identical in every frame.
arm_path = [(39,37),(39,36),(39,35),(39,34),(39,33),(38,32),(38,31),(38,30),(38,29)]
ref = [im.getpixel(p) for p in arm_path]
assert all(p in skin for p in ref)
for frame in range(1,12):
    assert [im.getpixel((frame*64+x,y)) for x,y in arm_path] == ref

# Expanded left shoulder is present with its grey outline.
for frame in range(12):
    ox=frame*64
    assert im.getpixel((ox+21,38)) in cloth
    assert im.getpixel((ox+20,38)) == (201,199,199,255)

assert "guid: f78d5d1e1f6949f08d2279686afc0d32" in META
assert META.count("name: Personnage_vue_dessous_AK47_64x64_") == 12
print("validated: right arm rebuilt consistently; left clothing enlarged; side magazine fully hidden; Unity metadata unchanged")
