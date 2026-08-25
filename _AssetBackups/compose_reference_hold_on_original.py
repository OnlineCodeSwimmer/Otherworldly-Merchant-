from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
GEN = Image.open(ROOT / "_AssetBackups/imagegen_correct_ak_hold_reference.png").convert("RGB")
SRC = Image.open(ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png").convert("RGBA")
OUT = ROOT / "_AssetBackups"

SRC_CELL, CELL, COUNT = 48, 64, 12
OFFSET = (8, 20)
T = (0, 0, 0, 0)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)
INK = (24, 23, 23, 255)
STEEL_DARK = (43, 43, 49, 255)
STEEL = (72, 74, 79, 255)
STEEL_LIGHT = (130, 135, 136, 255)
WOOD_DARK = (91, 36, 22, 255)
WOOD = (155, 59, 27, 255)
WOOD_LIGHT = (208, 88, 34, 255)
HAIR = {(144, 49, 49, 255), (112, 48, 48, 255)}


def neutral(p):
    r, g, b, a = p
    return a and max(r, g, b) - min(r, g, b) <= 12


def source_player(frame):
    im = SRC.crop((frame * SRC_CELL, 0, (frame + 1) * SRC_CELL, SRC_CELL))
    # Arms/hands may change; all hair, clothes and walking pixels remain source.
    for y in range(im.height):
        for x in range(im.width):
            if im.getpixel((x, y)) == SKIN:
                im.putpixel((x, y), T)
    for y in range(15):
        for x in range(33, 39):
            if neutral(im.getpixel((x, y))):
                im.putpixel((x, y), T)
    return im


def hair_center_source(frame):
    im = SRC.crop((frame * SRC_CELL, 0, (frame + 1) * SRC_CELL, SRC_CELL))
    pts = [(x + OFFSET[0], y + OFFSET[1]) for y in range(48) for x in range(48)
           if im.getpixel((x, y)) in HAIR]
    return (sum(x for x, _ in pts) / len(pts), sum(y for _, y in pts) / len(pts))


def generated_subject(frame, scale):
    sw = GEN.width / COUNT
    x0, x1 = round(frame * sw), round((frame + 1) * sw)
    crop = GEN.crop((x0, 0, x1, GEN.height))
    rgba = Image.new("RGBA", crop.size, T)
    for y in range(crop.height):
        for x in range(crop.width):
            r, g, b = crop.getpixel((x, y))
            if max(r, g, b) > 18:
                rgba.putpixel((x, y), (r, g, b, 255))
    rgba = rgba.crop(rgba.getbbox())
    size = (max(1, round(rgba.width * scale)), max(1, round(rgba.height * scale)))
    rgba = rgba.resize(size, Image.Resampling.NEAREST)

    # Build a generated body mask from red hair and pale clothing, dilated two
    # pixels to remove their generated outlines. Arms and AK remain.
    body = Image.new("L", rgba.size, 0)
    body_px = body.load()
    hair_pts = []
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = rgba.getpixel((x, y))
            if not a:
                continue
            lower = y > rgba.height * .42
            red_hair = lower and r > 70 and r > g * 1.8 and abs(g - b) < 35
            # Generated skin is also pale; only near-neutral pixels belong to
            # the white/grey clothing. The previous 55-point range erased the
            # firing arm and caused a disconnected hand.
            pale_cloth = lower and min(r, g, b) > 145 and max(r, g, b) - min(r, g, b) < 18
            if red_hair:
                hair_pts.append((x, y))
            if red_hair or pale_cloth:
                body_px[x, y] = 255
    body = body.filter(ImageFilter.MaxFilter(3))

    layer = Image.new("RGBA", rgba.size, T)
    for y in range(rgba.height):
        for x in range(rgba.width):
            p = rgba.getpixel((x, y))
            if p[3] and body.getpixel((x, y)) == 0:
                r, g, b, _ = p
                # Collapse the generated reference back into the source game's
                # small hard-edged palette. This does not alter geometry.
                if r > 130 and r > g * 1.08 and r < g * 1.55 and g > b * 1.05:
                    mapped = SKIN if (r + g + b) > 500 else SKIN_SHADE
                elif r > 70 and r > g * 1.35 and g >= b * .75:
                    mapped = WOOD_LIGHT if r > 180 else (WOOD if r > 115 else WOOD_DARK)
                elif max(r, g, b) - min(r, g, b) < 45:
                    value = (r + g + b) // 3
                    mapped = STEEL_LIGHT if value > 115 else (STEEL if value > 58 else (STEEL_DARK if value > 32 else INK))
                else:
                    mapped = INK if max(r, g, b) < 80 else STEEL_DARK
                layer.putpixel((x, y), mapped)

    hx = sum(x for x, _ in hair_pts) / len(hair_pts)
    hy = sum(y for _, y in hair_pts) / len(hair_pts)
    return layer, (hx, hy)


def make(scale):
    sheet = Image.new("RGBA", (CELL * COUNT, CELL), T)
    for i in range(COUNT):
        generated, gh = generated_subject(i, scale)
        sh = hair_center_source(i)
        pos = (round(sh[0] - gh[0]), round(sh[1] - gh[1]))
        cell = Image.new("RGBA", (CELL, CELL), T)
        cell.alpha_composite(generated, pos)
        cell.alpha_composite(source_player(i), OFFSET)
        sheet.alpha_composite(cell, (i * CELL, 0))
    return sheet


variants = {"A": .215, "B": .225, "C": .235}
zooms = []
for name, scale in variants.items():
    s = make(scale)
    s.save(OUT / f"Personnage_AK47_reference_hold_{name}.png", optimize=True)
    f = s.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
    bg = Image.new("RGBA", f.size, (255, 255, 255, 255))
    bg.alpha_composite(f)
    zooms.append(bg)

contact = Image.new("RGBA", (CELL * 8 * 3, CELL * 8), (255,255,255,255))
for i, z in enumerate(zooms):
    contact.alpha_composite(z, (i * CELL * 8, 0))
contact.convert("RGB").save(OUT / "Personnage_AK47_reference_hold_candidates_ABC.png")
print("composited reference hold on exact source player")
