from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
OUT = ROOT / "_AssetBackups"
SRC_CELL = 48
CELL = 64
COUNT = 12
OFFSET = (8, 20)

TRANSPARENT = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)
OUTLINE = (24, 23, 23, 255)
METAL_DARK = (43, 43, 49, 255)
METAL = (72, 74, 79, 255)
METAL_LIGHT = (130, 135, 136, 255)
WOOD_DARK = (99, 43, 23, 255)
WOOD = (160, 68, 29, 255)
WOOD_LIGHT = (210, 96, 38, 255)


def px(im, x, y, color):
    if 0 <= x < im.width and 0 <= y < im.height:
        im.putpixel((x, y), color)


def line_pixels(im, points, color):
    ImageDraw.Draw(im).line(points, fill=color, width=1)


def build_gun(center_x=45, compact=False):
    im = Image.new("RGBA", (CELL, CELL), TRANSPARENT)
    x = center_x
    muzzle_y = 3 if not compact else 5

    # Front sight and muzzle crown.
    for dx, dy in ((-1, 0), (0, 0), (1, 0), (-2, 1), (0, 1), (2, 1),
                   (-1, 2), (0, 2), (1, 2)):
        px(im, x + dx, muzzle_y + dy, OUTLINE)
    px(im, x, muzzle_y + 1, METAL_LIGHT)

    # Thin barrel plus gas block: different widths, never a single rectangle.
    for y in range(muzzle_y + 3, 12):
        px(im, x - 1, y, OUTLINE)
        px(im, x, y, METAL_LIGHT if y % 3 else METAL)
        px(im, x + 1, y, OUTLINE)
    for dx in range(-2, 3):
        px(im, x + dx, 10, OUTLINE)
    for dx in range(-1, 2):
        px(im, x + dx, 11, METAL)

    # Orange-brown wooden handguard around the barrel/gas system.
    widths = {12: 1, 13: 2, 14: 2, 15: 2, 16: 2, 17: 2, 18: 1}
    for y, half in widths.items():
        for dx in range(-half, half + 1):
            color = OUTLINE if abs(dx) == half else WOOD
            px(im, x + dx, y, color)
        px(im, x - 1, y, WOOD_LIGHT)
        px(im, x + 1, y, WOOD_DARK)

    # Compact steel receiver with a visible top cover/rib.
    receiver_rows = {19: 1, 20: 2, 21: 2, 22: 2, 23: 2, 24: 2, 25: 1}
    for y, half in receiver_rows.items():
        for dx in range(-half, half + 1):
            color = OUTLINE if abs(dx) == half else METAL
            px(im, x + dx, y, color)
        px(im, x, y, METAL_LIGHT if y in (20, 21) else METAL_DARK)

    # Curved AK magazine sweeps left and rear; this is the key silhouette cue.
    magazine = [
        (x - 2, 22), (x - 3, 23), (x - 3, 24), (x - 4, 25),
        (x - 4, 26), (x - 4, 27), (x - 3, 28), (x - 2, 29),
    ]
    line_pixels(im, magazine, OUTLINE)
    for qx, qy in magazine[2:-2]:
        px(im, qx + 1, qy, METAL_DARK)

    # Full pistol grip angled back-right, partly covered later by the firing hand.
    grip = [(x + 2, 24), (x + 3, 25), (x + 3, 26), (x + 4, 27),
            (x + 4, 28), (x + 3, 29), (x + 2, 28)]
    for qx, qy in grip:
        px(im, qx, qy, OUTLINE)
    px(im, x + 3, 26, WOOD_DARK)
    px(im, x + 4, 28, WOOD)

    # Tapered wooden buttstock, aligned to the shoulder rather than floating.
    stock_rows = {
        26: (-1, 1), 27: (-1, 1), 28: (-1, 2), 29: (-1, 2),
        30: (-1, 2), 31: (-1, 2), 32: (-1, 2), 33: (0, 2),
        34: (0, 1),
    }
    if compact:
        stock_rows.pop(34)
    for y, (left, right) in stock_rows.items():
        for dx in range(left, right + 1):
            color = OUTLINE if dx in (left, right) else WOOD
            px(im, x + dx, y, color)
        if right - left >= 3:
            px(im, x + left + 1, y, WOOD_LIGHT)
    shifted = Image.new("RGBA", im.size, TRANSPARENT)
    shifted.alpha_composite(im, (0, 5))
    return shifted


def strip_old_weapon_and_arms(frame):
    frame = frame.copy()
    # Remove all original exposed skin (both old hands/arms); the new arms are
    # reconstructed, while hair, clothes, outlines and walking feet remain.
    for y in range(frame.height):
        for x in range(frame.width):
            if frame.getpixel((x, y)) == SKIN:
                frame.putpixel((x, y), TRANSPARENT)
    # Remove only the neutral grey revolver pixels in its known source region.
    for y in range(0, 15):
        for x in range(33, 39):
            r, g, b, a = frame.getpixel((x, y))
            if a and max(r, g, b) - min(r, g, b) <= 12:
                frame.putpixel((x, y), TRANSPARENT)
    return frame


def draw_arms(cell, center_x=45, pose=0):
    d = ImageDraw.Draw(cell)
    # Support arm: shoulder -> elbow -> front handguard. Draw shade as a one-px
    # lower rim, then skin core. The original body later hides both shoulder roots.
    if pose == 0:
        support = [(29, 42), (35, 33), (center_x - 1, 23)]
        firing = [(45, 42), (46, 37), (center_x + 3, 31)]
    elif pose == 1:
        support = [(30, 42), (36, 33), (center_x - 1, 24)]
        firing = [(45, 42), (46, 37), (center_x + 3, 31)]
    else:
        support = [(29, 41), (35, 32), (center_x - 2, 23)]
        firing = [(44, 42), (45, 37), (center_x + 3, 30)]
    d.line([(x, y + 1) for x, y in support], fill=SKIN_SHADE, width=3, joint="curve")
    d.line(support, fill=SKIN, width=2, joint="curve")
    d.line([(x, y + 1) for x, y in firing], fill=SKIN_SHADE, width=3, joint="curve")
    d.line(firing, fill=SKIN, width=2, joint="curve")


def draw_hands(cell, center_x=45, pose=0):
    # Skin clusters overlap the weapon at the actual AK grip points.
    sx = center_x - 2 if pose < 2 else center_x - 3
    sy = 23 if pose != 1 else 24
    for dx, dy in ((-1, 0), (0, 0), (1, 0), (-1, 1), (0, 1), (1, 1), (0, 2)):
        px(cell, sx + dx, sy + dy, SKIN)
    fx = center_x + 2
    fy = 31 if pose != 2 else 30
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (2, 1), (1, 2)):
        px(cell, fx + dx, fy + dy, SKIN)


def make_sheet(center_x, pose, compact):
    src = Image.open(SOURCE).convert("RGBA")
    gun = build_gun(center_x, compact)
    sheet = Image.new("RGBA", (CELL * COUNT, CELL), TRANSPARENT)
    for i in range(COUNT):
        original = src.crop((i * SRC_CELL, 0, (i + 1) * SRC_CELL, SRC_CELL))
        base = strip_old_weapon_and_arms(original)
        cell = Image.new("RGBA", (CELL, CELL), TRANSPARENT)
        draw_arms(cell, center_x, pose)
        # Gun and arm roots are behind the source body. Hair and clothing hide
        # the stock/shoulder junction, while the two hands remain in front.
        cell.alpha_composite(gun)
        cell.alpha_composite(base, OFFSET)
        # Re-show only the forward weapon section above the torso; the stock
        # stays below hair/clothing at the shoulder.
        cell.alpha_composite(gun.crop((0, 0, CELL, 31)), (0, 0))
        draw_hands(cell, center_x, pose)
        sheet.alpha_composite(cell, (i * CELL, 0))
    return sheet


variants = {
    "A": (42, 0, False),
    "B": (43, 1, True),
    "C": (42, 2, True),
}
previews = []
for name, args in variants.items():
    sheet = make_sheet(*args)
    sheet.save(OUT / f"Personnage_AK47_correct_hold_{name}.png", optimize=True)
    frame = sheet.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
    bg = Image.new("RGBA", frame.size, (255, 255, 255, 255))
    bg.alpha_composite(frame)
    previews.append(bg)

comparison = Image.new("RGBA", (CELL * 8 * len(previews), CELL * 8), (255, 255, 255, 255))
for i, preview in enumerate(previews):
    comparison.alpha_composite(preview, (i * CELL * 8, 0))
comparison.convert("RGB").save(OUT / "Personnage_AK47_correct_hold_candidates_ABC.png")
print("generated correct two-hand AK hold candidates")
