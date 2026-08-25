from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
META = Path(str(PATH) + ".meta").read_text(encoding="utf-8")
im = Image.open(PATH).convert("RGBA")
assert im.size == (768,64)
assert set(im.getchannel("A").getdata()) <= {0,255}

patch_coords = [(25,34),(26,34),(26,35),(27,35),(27,36),(28,36),(28,37),(29,37),(29,38),(30,38),
                (39,29),(40,29),(40,30),(41,30),(40,31),(41,31),(42,31),(42,32),(43,32)]
reference = [im.getpixel(p) for p in patch_coords]
for frame in range(1,12):
    values = [im.getpixel((frame*64+x,y)) for x,y in patch_coords]
    assert values == reference, frame

assert "guid: f78d5d1e1f6949f08d2279686afc0d32" in META
assert META.count("name: Personnage_vue_dessous_AK47_64x64_") == 12
print("validated: identical left-shoulder bridge and completed right hand in all 12 frames; metadata unchanged")
