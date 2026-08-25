from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
# Start from the version immediately before the over-wide exact mirror, so no
# distant mirrored sleeve pixels can survive this correction.
SOURCE = ROOT / "_AssetBackups/Personnage_vue_dessous_AK47_64x64_before_mirrored_right_arm_fix_20260812.png"
OUT = ROOT / "_AssetBackups"
CELL, COUNT = 64, 12

T = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)
WHITE = (255, 255, 255, 255)
CLOTH_LINE = (201, 199, 199, 255)
OUTLINE = (24, 23, 23, 255)
WOOD_LIGHT = (208, 88, 34, 255)
WEAPON_GREYS = {
    (43, 43, 49, 255),
    (72, 74, 79, 255),
    (130, 135, 136, 255),
}

sheet = Image.open(SOURCE).convert("RGBA")
assert sheet.size == (CELL * COUNT, CELL)

# Remove every visible side-magazine pixel to the right of the receiver.
MAGAZINE_REGION = [(x, y) for y in range(19, 26) for x in range(38, 45)]

# Clear the previous bulky/fragmented right arm and hand. Weapon pixels and
# hair are preserved; only skin, its shade, and two known repair artifacts are
# removed from this local area.
RIGHT_OLD_REGION = [(x, y) for y in range(22, 39) for x in range(38, 49)]

# Pixels occupied by the previous compact sleeve. Clear them before drawing
# the new diagonal sleeve, otherwise the two silhouettes combine into a hook.
PREVIOUS_RIGHT_SLEEVE = {
    (39, 38), (40, 38), (41, 38), (42, 38),
    (39, 37), (40, 37), (41, 37), (42, 37),
    (40, 36), (41, 36), (42, 36),
    (40, 35), (41, 35), (42, 35),
}

# Slightly enlarge the left white shoulder toward the support arm. The grey
# border remains visible on both white and transparent backgrounds.
LEFT_CLOTHING = {
    (24, 35): WHITE,
    (23, 36): WHITE, (24, 36): WHITE,
    (22, 37): WHITE, (23, 37): WHITE, (24, 37): WHITE,
    (21, 38): WHITE, (22, 38): WHITE, (23, 38): WHITE,
}
LEFT_BORDER = {
    (24, 34): CLOTH_LINE,
    (23, 35): CLOTH_LINE,
    (22, 36): CLOTH_LINE,
    (21, 37): CLOTH_LINE,
    (20, 38): CLOTH_LINE,
}

# Follow the user's sketch with one continuous angle: the support hand begins
# at the receiver and travels steadily down-right into the shoulder. Do not
# reverse direction at the elbow; that made the previous half-diamond shape.
RIGHT_ARM_ROWS = {
    23: (38, 39),
    24: (38, 40),
    25: (38, 40),
    26: (39, 41),
    27: (39, 42),
    28: (40, 43),
    29: (40, 43),
    30: (41, 44),
    31: (41, 44),
    32: (42, 45),
    33: (42, 45),
    34: (43, 46),
    35: (44, 47),
    36: (44, 47),
}

# A shallow, open sleeve taper joins the bent arm to the existing garment. It
# is only two rows high, so it cannot close into the former white circle.
RIGHT_SLEEVE = {
    (43, 37): WHITE, (44, 37): WHITE, (45, 37): WHITE, (46, 37): WHITE,
    (42, 38): WHITE, (43, 38): WHITE, (44, 38): WHITE, (45, 38): WHITE,
    (41, 39): WHITE, (42, 39): WHITE, (43, 39): WHITE, (44, 39): WHITE,
}
RIGHT_SLEEVE_BORDER = {
    (47, 37): CLOTH_LINE,
    (46, 38): CLOTH_LINE,
}

for frame in range(COUNT):
    ox = frame * CELL

    for x, y in MAGAZINE_REGION:
        if sheet.getpixel((ox + x, y)) in WEAPON_GREYS:
            sheet.putpixel((ox + x, y), T)

    for x, y in RIGHT_OLD_REGION:
        old = sheet.getpixel((ox + x, y))
        if old in (SKIN, SKIN_SHADE) or (x, y) in {(41, 31), (42, 34)} and old in (WOOD_LIGHT, OUTLINE):
            sheet.putpixel((ox + x, y), T)

    for x, y in PREVIOUS_RIGHT_SLEEVE:
        if sheet.getpixel((ox + x, y)) in (WHITE, CLOTH_LINE):
            sheet.putpixel((ox + x, y), T)

    for (x, y), color in LEFT_CLOTHING.items():
        sheet.putpixel((ox + x, y), color)
    for (x, y), color in LEFT_BORDER.items():
        sheet.putpixel((ox + x, y), color)

    for y, (x0, x1) in RIGHT_ARM_ROWS.items():
        for x in range(x0, x1 + 1):
            sheet.putpixel((ox + x, y), SKIN_SHADE if x == x1 else SKIN)
    for (x, y), color in RIGHT_SLEEVE.items():
        sheet.putpixel((ox + x, y), color)
    for (x, y), color in RIGHT_SLEEVE_BORDER.items():
        sheet.putpixel((ox + x, y), color)

out_path = OUT / "Personnage_AK47_right_arm_rebuilt_left_clothes_larger_no_mag.png"
sheet.save(out_path, optimize=True)

preview = Image.new("RGBA", sheet.size, (255, 255, 255, 255))
preview.alpha_composite(sheet)
preview.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).convert("RGB").save(
    OUT / "Personnage_AK47_right_arm_rebuilt_left_clothes_larger_no_mag_white_2x.png"
)
frame0 = sheet.crop((0, 0, CELL, CELL)).resize((CELL * 10, CELL * 10), Image.Resampling.NEAREST)
gray = Image.new("RGBA", frame0.size, (225, 225, 225, 255))
gray.alpha_composite(frame0)
gray.convert("RGB").save(OUT / "Personnage_AK47_right_arm_rebuilt_frame0_gray_10x.png")
print(out_path)
