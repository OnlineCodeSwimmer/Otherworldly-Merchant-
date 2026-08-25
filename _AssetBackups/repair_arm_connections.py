from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "_AssetBackups/Personnage_AK47_fixed_hold_feet_under.png"
OUT = ROOT / "_AssetBackups"
CELL, COUNT = 64, 12

SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)

# Deterministic local repair, copied identically to all 12 cells.
# Left: bridge the forearm root into the shoulder/hair edge without touching
# the rifle. Right: complete the missing wrist/hand pixels around the grip.
PATCH = {
    # left arm-to-body bridge
    (25, 34): SKIN_SHADE,
    (26, 34): SKIN,
    (26, 35): SKIN_SHADE,
    (27, 35): SKIN,
    (27, 36): SKIN_SHADE,
    (28, 36): SKIN,
    (28, 37): SKIN_SHADE,
    (29, 37): SKIN,
    (29, 38): SKIN_SHADE,
    (30, 38): SKIN,
    # right grip hand/wrist completion
    (39, 29): SKIN_SHADE,
    (40, 29): SKIN,
    (40, 30): SKIN,
    (41, 30): SKIN,
    (40, 31): SKIN_SHADE,
    (41, 31): SKIN,
    (42, 31): SKIN,
    (42, 32): SKIN,
    (43, 32): SKIN_SHADE,
}

sheet = Image.open(SOURCE_PATH).convert("RGBA")
assert sheet.size == (CELL * COUNT, CELL)
for frame in range(COUNT):
    ox = frame * CELL
    for (x, y), color in PATCH.items():
        # Do not erase any existing opaque weapon pixel; only fill transparent
        # gaps or extend existing skin-colored arm edges.
        old = sheet.getpixel((ox + x, y))
        if old[3] == 0 or old in (SKIN, SKIN_SHADE):
            sheet.putpixel((ox + x, y), color)

out_path = OUT / "Personnage_AK47_connected_complete_arms.png"
sheet.save(out_path, optimize=True)

preview = Image.new("RGBA", sheet.size, (255,255,255,255))
preview.alpha_composite(sheet)
preview.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).convert("RGB").save(
    OUT / "Personnage_AK47_connected_complete_arms_white_2x.png"
)
frame0 = sheet.crop((0,0,CELL,CELL)).resize((CELL*8,CELL*8),Image.Resampling.NEAREST)
frame0_bg = Image.new("RGBA",frame0.size,(255,255,255,255))
frame0_bg.alpha_composite(frame0)
frame0_bg.convert("RGB").save(OUT / "Personnage_AK47_connected_complete_arms_frame0_white_8x.png")
print(out_path)
