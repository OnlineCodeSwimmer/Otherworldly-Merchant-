from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = Image.open(ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png").convert("RGBA")
HOLD = Image.open(ROOT / "_AssetBackups/AK47_frozen_gun_arms_hold_layer.png").convert("RGBA")
OUT = ROOT / "_AssetBackups"

SRC_CELL, CELL, COUNT = 48, 64, 12
OFFSET = (8, 20)
T = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)


def neutral(p):
    r, g, b, a = p
    return a and max(r, g, b) - min(r, g, b) <= 12


def split_source(frame):
    original = SRC.crop((frame * SRC_CELL, 0, (frame + 1) * SRC_CELL, SRC_CELL))
    feet = Image.new("RGBA", original.size, T)
    upper = original.copy()
    for y in range(original.height):
        for x in range(original.width):
            p = original.getpixel((x, y))
            old_gun = 33 <= x <= 38 and y < 15 and neutral(p)
            if p == SKIN or old_gun:
                upper.putpixel((x, y), T)
                continue
            # The walking feet use only black and near-black pixels. Move them
            # below the fixed AK/arms layer so the weapon and forearms can
            # correctly occlude them where their silhouettes cross.
            r, g, b, a = p
            walking_foot = a and max(r, g, b) <= 24 and not old_gun
            if walking_foot:
                # Side/upward stepping pixels (source y < 20) pass beneath the
                # fixed shoulders and arms in a strict top-down hold. Hide them
                # completely; keep only the lower feet that extend below the
                # coat so the walk cycle remains readable.
                if y >= 20:
                    feet.putpixel((x, y), p)
                upper.putpixel((x, y), T)
    return feet, upper


sheet = Image.new("RGBA", (CELL * COUNT, CELL), T)
for frame in range(COUNT):
    feet, upper = split_source(frame)
    cell = Image.new("RGBA", (CELL, CELL), T)
    cell.alpha_composite(feet, OFFSET)   # walking feet at the bottom
    cell.alpha_composite(HOLD)           # fixed AK + arms can cover feet
    cell.alpha_composite(upper, OFFSET)  # hair, clothing and torso at the top
    sheet.alpha_composite(cell, (frame * CELL, 0))

path = OUT / "Personnage_AK47_fixed_hold_feet_under.png"
sheet.save(path, optimize=True)

preview = Image.new("RGBA", sheet.size, (255, 255, 255, 255))
preview.alpha_composite(sheet)
preview.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).convert("RGB").save(
    OUT / "Personnage_AK47_fixed_hold_feet_under_white_2x.png"
)
print(path)
