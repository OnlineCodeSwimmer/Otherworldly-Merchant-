from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PLAYER_PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
OUT_DIR = ROOT / "_AssetBackups"

SOURCE_CELL = 48
CELL = 64
COUNT = 12
PLAYER_POS = (8, 20)
WEAPON_POS = (42, 1)

OUTLINE = (24, 21, 28, 255)
METAL_DARK = (47, 43, 55, 255)
METAL = (72, 68, 84, 255)
METAL_LIGHT = (111, 105, 119, 255)
WOOD_DARK = (96, 37, 22, 255)
WOOD = (163, 64, 28, 255)
WOOD_LIGHT = (209, 88, 36, 255)


def neutral(pixel):
    r, g, b, a = pixel
    return a and max(r, g, b) - min(r, g, b) <= 8


def put(im, x, y, color):
    im.putpixel((x, y), color)


def rect(im, x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            im.putpixel((x, y), color)


def draw_common(body_shift=0, stock_wide=False):
    # Irregular transparent canvas; the weapon is not scaled into a prescribed
    # rectangle. Max width is only 8 pixels while each section has its own
    # silhouette.
    weapon = Image.new("RGBA", (8, 46), (0, 0, 0, 0))

    # Muzzle brake/front sight.
    for x, y in ((2, 0), (3, 0), (4, 0), (1, 1), (3, 1), (5, 1), (2, 2), (3, 2), (4, 2)):
        put(weapon, x, y, OUTLINE)
    put(weapon, 3, 1, METAL_LIGHT)
    put(weapon, 3, 2, METAL)

    # Long thin barrel/gas tube.
    rect(weapon, 2, 3, 4, 12 + body_shift, OUTLINE)
    rect(weapon, 3, 3, 3, 12 + body_shift, METAL_LIGHT)
    rect(weapon, 1, 10 + body_shift, 5, 11 + body_shift, OUTLINE)
    rect(weapon, 2, 10 + body_shift, 4, 10 + body_shift, METAL)

    handguard_y0 = 13 + body_shift
    handguard_y1 = handguard_y0 + 6
    receiver_y0 = handguard_y1 + 1
    receiver_y1 = receiver_y0 + 7

    # Thin reddish-brown wooden handguard, max width 5.
    rect(weapon, 1, handguard_y0, 5, handguard_y1, OUTLINE)
    rect(weapon, 2, handguard_y0 + 1, 4, handguard_y1 - 1, WOOD)
    rect(weapon, 2, handguard_y0 + 1, 2, handguard_y1 - 1, WOOD_LIGHT)
    rect(weapon, 4, handguard_y0 + 1, 4, handguard_y1 - 1, WOOD_DARK)

    # Compact metal receiver, also max width 5.
    rect(weapon, 1, receiver_y0, 5, receiver_y1, OUTLINE)
    rect(weapon, 2, receiver_y0 + 1, 4, receiver_y1 - 1, METAL)
    rect(weapon, 2, receiver_y0 + 1, 2, receiver_y1 - 1, METAL_LIGHT)
    rect(weapon, 4, receiver_y0 + 1, 4, receiver_y1 - 1, METAL_DARK)
    rect(weapon, 2, receiver_y1 - 1, 4, receiver_y1 - 1, METAL_DARK)

    # Pistol grip deliberately EXISTS. It projects slightly right from the
    # trigger area, then is partly covered by the original hand foreground.
    grip_y0 = receiver_y1 - 1
    for x, y in ((5, grip_y0), (6, grip_y0 + 1), (6, grip_y0 + 2),
                 (7, grip_y0 + 3), (7, grip_y0 + 4), (6, grip_y0 + 5)):
        put(weapon, x, y, WOOD_DARK if x >= 6 else OUTLINE)
    put(weapon, 6, grip_y0 + 3, WOOD)

    # Full wooden buttstock also EXISTS. It is offset slightly left of the
    # palm so part of its top surface remains visible behind the hand/forearm.
    stock_y0 = receiver_y1 + 1
    if stock_wide:
        rect(weapon, 1, stock_y0, 5, 44, OUTLINE)
        rect(weapon, 2, stock_y0 + 1, 4, 43, WOOD)
        rect(weapon, 2, stock_y0 + 1, 2, 43, WOOD_LIGHT)
        # taper the shoulder end
        put(weapon, 1, 44, (0, 0, 0, 0))
        put(weapon, 5, 44, (0, 0, 0, 0))
    else:
        rect(weapon, 2, stock_y0, 5, 44, OUTLINE)
        rect(weapon, 3, stock_y0 + 1, 4, 43, WOOD)
        rect(weapon, 3, stock_y0 + 1, 3, 43, WOOD_LIGHT)
    return weapon


def clean_player(sheet, frame):
    player = sheet.crop((frame * SOURCE_CELL, 0, (frame + 1) * SOURCE_CELL, SOURCE_CELL))
    # Remove only the old neutral revolver. Original arm/hand stays as the
    # foreground layer and naturally wraps over the new grip and stock.
    for y in range(1, 14):
        for x in range(34, 38):
            if neutral(player.getpixel((x, y))):
                player.putpixel((x, y), (0, 0, 0, 0))
    return player


variants = {
    "A": draw_common(body_shift=0, stock_wide=False),
    "B": draw_common(body_shift=1, stock_wide=False),
    "C": draw_common(body_shift=0, stock_wide=True),
}

player_sheet = Image.open(PLAYER_PATH).convert("RGBA")
previews = []
for name, weapon in variants.items():
    weapon.save(OUT_DIR / f"AK47_freeform_full_candidate_{name}.png", optimize=True)
    sheet = Image.new("RGBA", (CELL * COUNT, CELL), (0, 0, 0, 0))
    for frame in range(COUNT):
        player = clean_player(player_sheet, frame)
        cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        cell.alpha_composite(weapon, WEAPON_POS)
        cell.alpha_composite(player, PLAYER_POS)
        sheet.alpha_composite(cell, (frame * CELL, 0))
    sheet.save(OUT_DIR / f"Personnage_AK47_freeform_full_candidate_{name}.png", optimize=True)
    frame = sheet.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
    white = Image.new("RGBA", frame.size, (255, 255, 255, 255))
    white.alpha_composite(frame)
    white.convert("RGB").save(OUT_DIR / f"Personnage_AK47_freeform_full_candidate_{name}_white_8x.png")
    previews.append(white)

comparison = Image.new("RGBA", (CELL * 8 * len(previews), CELL * 8), (255, 255, 255, 255))
for index, preview in enumerate(previews):
    comparison.alpha_composite(preview, (index * CELL * 8, 0))
comparison.convert("RGB").save(OUT_DIR / "Personnage_AK47_freeform_full_candidates_ABC.png")
print("generated freeform full AK candidates; grip and buttstock retained")
