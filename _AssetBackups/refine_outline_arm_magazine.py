from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
OUT = ROOT / "_AssetBackups"
CELL, COUNT = 64, 12

T = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)
CLOTH_LINE = (201, 199, 199, 255)
DARK_STEEL = (43, 43, 49, 255)
STEEL = (72, 74, 79, 255)

sheet = Image.open(SOURCE).convert("RGBA")
assert sheet.size == (CELL * COUNT, CELL)

# The generated side magazine was a long diagonal wedge. Remove only its far
# right pixels, leaving a compact top-down magazine nub close to the receiver.
REMOVE_MAGAZINE = {
    (42, 20), (43, 20), (42, 21), (43, 21),
    (40, 20), (41, 20),
    (39, 21), (40, 21), (41, 21),
    (40, 22), (41, 22), (42, 22), (43, 22), (44, 22),
    (40, 23), (41, 23), (42, 23),
    (39, 24), (40, 24), (41, 24),
}

# Rebuild a much shorter, tighter magazine silhouette. It remains visibly
# separate from the receiver but no longer reads as a side-view long object.
COMPACT_MAGAZINE = {
    (38, 21): DARK_STEEL,
    (39, 21): STEEL,
    (38, 22): DARK_STEEL,
    (39, 22): STEEL,
    (38, 23): DARK_STEEL,
}

# Left shirt/shoulder outline. These pixels sit immediately outside the white
# garment where the support arm meets the body, so the connection remains
# visible even on a white preview background.
LEFT_CLOTH_OUTLINE = {
    (24, 34): CLOTH_LINE,
    (23, 35): CLOTH_LINE,
    (23, 36): CLOTH_LINE,
    (22, 37): CLOTH_LINE,
    (22, 38): CLOTH_LINE,
}

# Complete and slightly widen the right forearm/hand without covering the
# receiver or the compact magazine.
RIGHT_ARM = {
    (41, 29): SKIN,
    (42, 29): SKIN_SHADE,
    (42, 30): SKIN,
    (43, 30): SKIN_SHADE,
    (43, 31): SKIN,
    (44, 31): SKIN_SHADE,
    (43, 32): SKIN,
    (44, 32): SKIN,
    (45, 32): SKIN_SHADE,
    (42, 33): SKIN,
    (43, 33): SKIN,
    (44, 33): SKIN,
    (45, 33): SKIN_SHADE,
    (42, 34): SKIN,
    (43, 34): SKIN,
    (44, 34): SKIN,
    (43, 35): SKIN,
    (44, 35): SKIN_SHADE,
    (44, 36): SKIN,
}

for frame in range(COUNT):
    ox = frame * CELL
    for x, y in REMOVE_MAGAZINE:
        old = sheet.getpixel((ox + x, y))
        if old in (DARK_STEEL, STEEL, (130, 135, 136, 255)):
            sheet.putpixel((ox + x, y), T)
    for mapping in (COMPACT_MAGAZINE, LEFT_CLOTH_OUTLINE, RIGHT_ARM):
        for (x, y), color in mapping.items():
            sheet.putpixel((ox + x, y), color)

out_path = OUT / "Personnage_AK47_refined_outline_arm_compact_magazine.png"
sheet.save(out_path, optimize=True)

preview = Image.new("RGBA", sheet.size, (255,255,255,255))
preview.alpha_composite(sheet)
preview.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).convert("RGB").save(
    OUT / "Personnage_AK47_refined_outline_arm_compact_magazine_white_2x.png"
)

frame = sheet.crop((0,0,CELL,CELL)).resize((CELL*10,CELL*10),Image.Resampling.NEAREST)
gray = Image.new("RGBA",frame.size,(225,225,225,255))
gray.alpha_composite(frame)
gray.convert("RGB").save(OUT / "Personnage_AK47_refined_frame0_gray_10x.png")
print(out_path)
