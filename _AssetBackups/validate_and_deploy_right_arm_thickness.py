from pathlib import Path
from shutil import copy2
from hashlib import sha256
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_AK47_64x64.png"
CANDIDATE = ROOT / "_AssetBackups/Personnage_AK47_right_arm_rebuilt_left_clothes_larger_no_mag.png"
ORIGINAL = ROOT / "Assets/Download Source/Personnage/Personnage_vue_dessous_revolver.png"
BACKUP = ROOT / "_AssetBackups/Personnage_vue_dessous_AK47_64x64_before_right_arm_angle_fix_20260812.png"
META = TARGET.with_suffix(TARGET.suffix + ".meta")
CELL, COUNT = 64, 12

before = Image.open(TARGET).convert("RGBA")
after = Image.open(CANDIDATE).convert("RGBA")
original = Image.open(ORIGINAL).convert("RGBA")
assert before.size == after.size == (CELL * COUNT, CELL)
assert original.size == (48 * COUNT, 48)

# Only the hand/arm, the already-authorized left-clothing edge, and the hidden
# side-magazine region may differ from the current project asset.
allowed = (
    {(x, y) for y in range(19, 26) for x in range(38, 45)}
    | {(x, y) for y in range(22, 39) for x in range(38, 52)}
    | {(24, 34), (23, 35), (22, 36), (21, 37), (20, 38)}
    | {(24, 35), (23, 36), (24, 36), (22, 37), (23, 37), (24, 37),
       (21, 38), (22, 38), (23, 38)}
    | {(42, 39), (43, 39), (44, 39), (45, 39)}
)

for frame in range(COUNT):
    ox = frame * CELL
    for y in range(CELL):
        for x in range(CELL):
            if before.getpixel((ox + x, y)) != after.getpixel((ox + x, y)):
                assert (x, y) in allowed, (frame, x, y)

skin = {(223, 185, 149, 255), (196, 153, 119, 255)}
weapon_greys = {(43, 43, 49, 255), (72, 74, 79, 255), (130, 135, 136, 255)}

reference_patch = None
for frame in range(COUNT):
    ox = frame * CELL
    patch = tuple(
        after.getpixel((ox + x, y))
        for y in range(22, 39)
        for x in range(38, 52)
    )
    if reference_patch is None:
        reference_patch = patch
    assert patch == reference_patch, f"right arm drift in frame {frame}"

    arm_count = sum(
        after.getpixel((ox + x, y)) in skin
        for y in range(22, 39)
        for x in range(38, 52)
    )
    assert arm_count >= 25, (frame, arm_count)
    # The support arm follows the user's sketch: it may bow out to x=47 but no
    # farther; the cuff also remains inside that same compact boundary.
    assert not any(
        after.getpixel((ox + x, y)) in skin
        for y in range(22, 39)
        for x in range(48, 52)
    ), f"right arm too far from gun in frame {frame}"
    assert not any(
        after.getpixel((ox + x, y)) in {
            (255, 255, 255, 255), (201, 199, 199, 255)
        }
        for y in range(22, 39)
        for x in range(48, 52)
    ), f"right sleeve too wide in frame {frame}"

    # The shallow cuff must connect directly into the existing white clothing
    # at y=39/40; it must not float as a detached circle.
    assert all(
        after.getpixel((ox + x, 39)) == (255, 255, 255, 255)
        for x in (42, 43, 44)
    ), f"right cuff does not meet clothing in frame {frame}"
    assert all(
        after.getpixel((ox + x, 40)) == (255, 255, 255, 255)
        for x in (42, 43, 44)
    ), f"clothing below cuff was changed in frame {frame}"

    # The arm's right edge must travel monotonically down-right from the grip
    # to the cuff. Any backward jump would recreate the sharp half-diamond.
    right_edges = []
    for y in range(23, 37):
        xs = [
            x for x in range(38, 48)
            if after.getpixel((ox + x, y)) in skin
        ]
        assert xs, ("missing arm row", frame, y)
        right_edges.append(max(xs))
    assert all(a <= b for a, b in zip(right_edges, right_edges[1:])), (
        "right arm angle reverses", frame, right_edges
    )

    # Hair is immutable: every source hair pixel must remain exactly the same
    # after the 48x48 character is placed at offset (8, 20).
    for sy in range(48):
        for sx in range(48):
            source_pixel = original.getpixel((frame * 48 + sx, sy))
            if source_pixel in {(144, 49, 49, 255), (112, 48, 48, 255)}:
                assert after.getpixel((ox + sx + 8, sy + 20)) == source_pixel, (
                    "hair changed", frame, sx, sy
                )
    assert not any(
        after.getpixel((ox + x, y)) in weapon_greys
        for y in range(19, 26)
        for x in range(38, 45)
    ), f"visible side magazine in frame {frame}"

assert set(after.getchannel("A").getdata()) <= {0, 255}
meta_text = META.read_text(encoding="utf-8")
assert "f78d5d1e1f6949f08d2279686afc0d32" in meta_text
assert meta_text.count("name: Personnage_vue_dessous_AK47_64x64_") == COUNT

if not BACKUP.exists():
    copy2(TARGET, BACKUP)
copy2(CANDIDATE, TARGET)

print(f"deployed={TARGET}")
print(f"backup={BACKUP}")
print(f"sha256={sha256(TARGET.read_bytes()).hexdigest().upper()}")
print("validation=passed")
