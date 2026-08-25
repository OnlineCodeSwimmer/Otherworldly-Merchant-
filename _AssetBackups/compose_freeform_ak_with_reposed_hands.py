from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PLAYER_PATH = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
WEAPON_PATH = ROOT / "_AssetBackups/AK47_freeform_full_candidate_A.png"
OUT_DIR = ROOT / "_AssetBackups"

SOURCE_CELL = 48
CELL = 64
COUNT = 12
PLAYER_POS = (8, 20)
WEAPON_POS = (42, 1)
SKIN = (223, 185, 149, 255)
SKIN_SHADE = (196, 153, 119, 255)

# Protected colors belong to hair, clothing, outline/shadows and walking feet.
# Only exact skin pixels may be cleared/reposed.
PROTECTED = {
    (255, 255, 255, 255),
    (144, 49, 49, 255),
    (112, 48, 48, 255),
    (201, 199, 199, 255),
    (212, 210, 210, 255),
    (24, 23, 23, 255),
}

# Candidate A uses a natural two-hand rifle posture. Candidate B uses a tighter
# support arm. All coordinates are in the final 64x64 cell.
POSES = {
    "A": {
        "skin": [
            # Rear/trigger hand wraps over the pistol grip.
            (47, 31), (48, 31), (47, 32), (48, 32), (49, 32),
            (47, 33), (48, 33), (49, 33), (48, 34), (49, 34),
            (49, 35), (50, 35), (49, 36), (50, 36), (49, 37),
            (48, 38), (49, 38), (48, 39),
            # Front/support hand grips the wooden handguard.
            (43, 15), (44, 15), (43, 16), (44, 16), (45, 16),
            (43, 17), (44, 17), (45, 17), (43, 18), (44, 18),
            # Narrow support arm back toward the right shoulder.
            (42, 19), (43, 19), (42, 20), (43, 20), (42, 21),
            (42, 22), (42, 23), (42, 24), (42, 25), (42, 26),
            (42, 27), (42, 28), (42, 29), (42, 30), (42, 31),
            (42, 32), (42, 33),
        ],
        "shade": [(50, 36), (49, 38), (45, 17), (42, 24), (42, 30)],
    },
    "B": {
        "skin": [
            # Trigger hand.
            (47, 31), (48, 31), (47, 32), (48, 32), (49, 32),
            (47, 33), (48, 33), (49, 33), (48, 34), (49, 34),
            (49, 35), (50, 35), (49, 36), (50, 36), (49, 37),
            (48, 38), (49, 38),
            # Support hand closer to the receiver/handguard junction.
            (43, 19), (44, 19), (45, 19), (43, 20), (44, 20),
            (45, 20), (43, 21), (44, 21),
            # Bent support arm.
            (42, 22), (43, 22), (42, 23), (43, 23), (42, 24),
            (42, 25), (42, 26), (42, 27), (42, 28), (42, 29),
            (42, 30), (42, 31), (42, 32), (42, 33),
        ],
        "shade": [(50, 36), (49, 38), (45, 20), (42, 25), (42, 30)],
    },
}


def neutral(pixel):
    r, g, b, a = pixel
    return a and max(r, g, b) - min(r, g, b) <= 8


def prepare_player(source_sheet, frame):
    player = source_sheet.crop((frame * SOURCE_CELL, 0, (frame + 1) * SOURCE_CELL, SOURCE_CELL))
    # Remove old revolver neutrals.
    for y in range(1, 14):
        for x in range(34, 38):
            if neutral(player.getpixel((x, y))):
                player.putpixel((x, y), (0, 0, 0, 0))
    # Repose only exact skin pixels in the original right arm zone.
    for y in range(11, 24):
        for x in range(33, 42):
            if player.getpixel((x, y)) == SKIN:
                player.putpixel((x, y), (0, 0, 0, 0))
    return player


def protected(original, gx, gy):
    x = gx - PLAYER_POS[0]
    y = gy - PLAYER_POS[1]
    if not (0 <= x < SOURCE_CELL and 0 <= y < SOURCE_CELL):
        return False
    return original.getpixel((x, y)) in PROTECTED


source_sheet = Image.open(PLAYER_PATH).convert("RGBA")
weapon = Image.open(WEAPON_PATH).convert("RGBA")
previews = []

for name, pose in POSES.items():
    sheet = Image.new("RGBA", (CELL * COUNT, CELL), (0, 0, 0, 0))
    for frame in range(COUNT):
        original = source_sheet.crop((frame * SOURCE_CELL, 0, (frame + 1) * SOURCE_CELL, SOURCE_CELL))
        player = prepare_player(source_sheet, frame)
        cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        cell.alpha_composite(weapon, WEAPON_POS)
        cell.alpha_composite(player, PLAYER_POS)

        for point in pose["skin"]:
            if not protected(original, *point):
                cell.putpixel(point, SKIN)
        for point in pose["shade"]:
            if not protected(original, *point):
                cell.putpixel(point, SKIN_SHADE)
        sheet.alpha_composite(cell, (frame * CELL, 0))

    sheet.save(OUT_DIR / f"Personnage_AK47_freeform_reposed_{name}.png", optimize=True)
    frame = sheet.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
    white = Image.new("RGBA", frame.size, (255, 255, 255, 255))
    white.alpha_composite(frame)
    white.convert("RGB").save(OUT_DIR / f"Personnage_AK47_freeform_reposed_{name}_white_8x.png")
    previews.append(white)

comparison = Image.new("RGBA", (CELL * 8 * len(previews), CELL * 8), (255, 255, 255, 255))
for index, preview in enumerate(previews):
    comparison.alpha_composite(preview, (index * CELL * 8, 0))
comparison.convert("RGB").save(OUT_DIR / "Personnage_AK47_freeform_reposed_AB.png")
print("generated reposed hands A/B; protected hair/clothes/walk pixels")
