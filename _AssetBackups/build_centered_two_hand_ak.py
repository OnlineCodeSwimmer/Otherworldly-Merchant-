from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
OUT = ROOT / "_AssetBackups"
SRC_CELL, CELL, COUNT = 48, 64, 12
OFFSET = (8, 20)

T = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)
INK = (24, 23, 23, 255)
STEEL_DARK = (42, 42, 48, 255)
STEEL = (72, 73, 78, 255)
STEEL_LIGHT = (132, 136, 137, 255)
WOOD_DARK = (91, 36, 22, 255)
WOOD = (155, 59, 27, 255)
WOOD_LIGHT = (208, 88, 34, 255)


def put(im, x, y, c):
    if 0 <= x < im.width and 0 <= y < im.height:
        im.putpixel((x, y), c)


def row(im, x, y, half, fill, highlight=False):
    for dx in range(-half, half + 1):
        put(im, x + dx, y, INK if abs(dx) == half else fill)
    if highlight and half >= 2:
        put(im, x - 1, y, WOOD_LIGHT)
        put(im, x + 1, y, WOOD_DARK)


def gun(center=35, short=False):
    im = Image.new("RGBA", (CELL, CELL), T)
    top = 4 if short else 2

    # Front sight and muzzle.
    for dx, dy in ((-1, 0), (0, 0), (1, 0), (-2, 1), (0, 1), (2, 1),
                   (-1, 2), (0, 2), (1, 2)):
        put(im, center + dx, top + dy, INK)
    put(im, center, top + 1, STEEL_LIGHT)

    # Long slim barrel, gas block and gas tube.
    for y in range(top + 3, 11):
        put(im, center - 1, y, INK)
        put(im, center, y, STEEL_LIGHT if y % 2 else STEEL)
        put(im, center + 1, y, INK)
    for dx in range(-2, 3):
        put(im, center + dx, 10, INK)
    for dx in range(-1, 2):
        put(im, center + dx, 11, STEEL)

    # Wooden upper/lower handguard: narrow, stepped, and unmistakably separate.
    for y, half in ((12, 1), (13, 2), (14, 2), (15, 2), (16, 2),
                    (17, 2), (18, 1)):
        row(im, center, y, half, WOOD, True)

    # Steel receiver/top cover, kept compact.
    for y, half in ((19, 1), (20, 2), (21, 2), (22, 2),
                    (23, 2), (24, 2), (25, 1)):
        row(im, center, y, half, STEEL)
        put(im, center, y, STEEL_LIGHT if y in (20, 21) else STEEL_DARK)

    # Curved magazine: a hook-shaped silhouette sweeping to the left/rear.
    mag = [(center - 2, 22), (center - 3, 23), (center - 3, 24),
           (center - 4, 25), (center - 4, 26), (center - 4, 27),
           (center - 3, 28), (center - 2, 29)]
    d = ImageDraw.Draw(im)
    d.line(mag, fill=INK, width=2)
    for x, y in mag[2:-2]:
        put(im, x + 1, y, STEEL_DARK)

    # Pistol grip: complete, angled right/rear, later covered by firing hand.
    grip = [(center + 2, 24), (center + 3, 25), (center + 3, 26),
            (center + 4, 27), (center + 4, 28), (center + 3, 29)]
    d.line(grip, fill=INK, width=2)
    put(im, center + 3, 26, WOOD_DARK)
    put(im, center + 4, 27, WOOD)

    # Full tapered wooden buttstock. It will be layered under head/torso.
    stock = {
        26: (-1, 1), 27: (-1, 1), 28: (-1, 2), 29: (-1, 2),
        30: (-2, 2), 31: (-2, 2), 32: (-2, 2), 33: (-2, 2),
        34: (-2, 2), 35: (-1, 2), 36: (-1, 2), 37: (-1, 1),
    }
    for y, (left, right) in stock.items():
        for dx in range(left, right + 1):
            put(im, center + dx, y, INK if dx in (left, right) else WOOD)
        if right - left >= 3:
            put(im, center - 1, y, WOOD_LIGHT)
    # Lower the complete rifle toward the shoulder. This keeps the muzzle long
    # enough to read as a rifle without forcing the arms to reach 20 pixels.
    shifted = Image.new("RGBA", (CELL, CELL), T)
    shifted.alpha_composite(im, (0, 4))
    return shifted


def clean_player(frame):
    frame = frame.copy()
    # Arms/hands are the only character pixels allowed to change.
    for y in range(48):
        for x in range(48):
            if frame.getpixel((x, y)) == SKIN:
                frame.putpixel((x, y), T)
    # Remove the original neutral-grey revolver in its known bounding area.
    for y in range(15):
        for x in range(33, 39):
            r, g, b, a = frame.getpixel((x, y))
            if a and max(r, g, b) - min(r, g, b) <= 12:
                frame.putpixel((x, y), T)
    return frame


def outlined_polyline(layer, points, outline_width=4, skin_width=2):
    d = ImageDraw.Draw(layer)
    # The source arms use flat skin pixels without a heavy black contour.
    d.line([(x, y + 1) for x, y in points], fill=SKIN_SHADE, width=3, joint="curve")
    d.line(points, fill=SKIN, width=3, joint="curve")


def arms(layer, center, variant):
    # Arm roots begin inside the torso and are later hidden by the source body.
    # Only short bent forearms remain visible beside the centered rifle.
    if variant == 0:
        left = [(25, 38), (28, 33), (center - 2, 26)]
        right = [(43, 38), (40, 34), (center + 3, 31)]
    elif variant == 1:
        left = [(26, 38), (29, 33), (center - 2, 26)]
        right = [(42, 38), (40, 34), (center + 3, 31)]
    else:
        left = [(25, 37), (29, 32), (center - 2, 26)]
        right = [(43, 37), (40, 33), (center + 3, 30)]
    outlined_polyline(layer, left)
    outlined_polyline(layer, right)


def hand_cluster(layer, x, y, side):
    coords = [(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)]
    if side == "right":
        coords += [(2, 1), (1, 2)]
    for dx, dy in coords:
        put(layer, x + dx, y + dy, SKIN)


def sheet(center, arm_variant, short):
    src = Image.open(SOURCE).convert("RGBA")
    rifle = gun(center, short)
    out = Image.new("RGBA", (CELL * COUNT, CELL), T)
    for i in range(COUNT):
        player = clean_player(src.crop((i * SRC_CELL, 0, (i + 1) * SRC_CELL, SRC_CELL)))
        cell = Image.new("RGBA", (CELL, CELL), T)
        arms(cell, center, arm_variant)
        cell.alpha_composite(rifle)      # whole gun behind body, including stock
        cell.alpha_composite(player, OFFSET)  # exact source hair/clothes/walk
        # Forward rifle section returns to foreground; stock remains under head.
        cell.alpha_composite(rifle.crop((0, 0, CELL, 34)), (0, 0))
        hand_cluster(cell, center - 3, 25, "left")
        hand_cluster(cell, center + 2, 30, "right")
        out.alpha_composite(cell, (i * CELL, 0))
    return out


variants = {"A": (34, 0, False), "B": (35, 1, True), "C": (34, 2, True)}
previews = []
for name, args in variants.items():
    s = sheet(*args)
    s.save(OUT / f"Personnage_AK47_centered_hold_{name}.png", optimize=True)
    f = s.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
    bg = Image.new("RGBA", f.size, (255, 255, 255, 255))
    bg.alpha_composite(f)
    previews.append(bg)

contact = Image.new("RGBA", (CELL * 8 * 3, CELL * 8), (255, 255, 255, 255))
for i, p in enumerate(previews):
    contact.alpha_composite(p, (i * CELL * 8, 0))
contact.convert("RGB").save(OUT / "Personnage_AK47_centered_hold_candidates_ABC.png")
print("generated centered two-hand AK candidates")
