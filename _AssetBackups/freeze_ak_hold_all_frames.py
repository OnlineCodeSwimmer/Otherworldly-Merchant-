from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "_AssetBackups"))

# Import the already-validated extraction helpers. This import also refreshes
# the candidate previews, but does not touch the project asset.
from compose_reference_hold_on_original import (  # noqa: E402
    CELL,
    COUNT,
    OFFSET,
    OUT,
    SRC,
    SRC_CELL,
    T,
    generated_subject,
    hair_center_source,
    source_player,
)


SCALE = .215
REFERENCE_FRAME = 0

# Extract the AK + both arms/hands exactly once. Its pixels and cell-space
# position are then reused unchanged in every animation frame.
frozen_hold, generated_hair_center = generated_subject(REFERENCE_FRAME, SCALE)
source_hair_center = hair_center_source(REFERENCE_FRAME)
frozen_position = (
    round(source_hair_center[0] - generated_hair_center[0]),
    round(source_hair_center[1] - generated_hair_center[1]),
)

frozen_canvas = Image.new("RGBA", (CELL, CELL), T)
frozen_canvas.alpha_composite(frozen_hold, frozen_position)
frozen_canvas.save(OUT / "AK47_frozen_gun_arms_hold_layer.png", optimize=True)

sheet = Image.new("RGBA", (CELL * COUNT, CELL), T)
for frame in range(COUNT):
    cell = frozen_canvas.copy()
    # Only the source player's per-frame walking layer changes. Hair, clothes,
    # body and feet all come from the original revolver sheet; old arms/gun are
    # removed by source_player before compositing.
    cell.alpha_composite(source_player(frame), OFFSET)
    sheet.alpha_composite(cell, (frame * CELL, 0))

out_path = OUT / "Personnage_AK47_fixed_hold_all_12_frames.png"
sheet.save(out_path, optimize=True)

# White-background previews, nearest-neighbour only.
preview = Image.new("RGBA", sheet.size, (255, 255, 255, 255))
preview.alpha_composite(sheet)
preview.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).convert("RGB").save(
    OUT / "Personnage_AK47_fixed_hold_all_12_frames_white_2x.png"
)
frame0 = sheet.crop((0, 0, CELL, CELL)).resize((CELL * 8, CELL * 8), Image.Resampling.NEAREST)
frame0_bg = Image.new("RGBA", frame0.size, (255, 255, 255, 255))
frame0_bg.alpha_composite(frame0)
frame0_bg.convert("RGB").save(OUT / "Personnage_AK47_fixed_hold_frame0_white_8x.png")

print(f"frozen layer reused 12 times at {frozen_position}; wrote {out_path}")
