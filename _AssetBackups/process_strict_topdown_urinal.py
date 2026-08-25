from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "_AssetBackups" / "GeneratedChroma" / "restroom_urinal_strict_topdown_chroma.png"
CUTOUT = ROOT / "_AssetBackups" / "GeneratedChroma" / "restroom_urinal_strict_topdown_cutout.png"
OUTPUT = ROOT / "Assets" / "AIGC Source" / "Building" / "Object" / "restroom_urinal_strict_topdown_64x64.png"
PREVIEW = ROOT / "_AssetBackups" / "restroom_urinal_strict_topdown_64x64_preview_8x.png"


def main() -> None:
    image = Image.open(CUTOUT).convert("RGBA")
    pixels = image.load()

    # Pixel-art output uses binary alpha. Remove soft chroma remnants while
    # keeping the ceramic's pale cyan shading intact.
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a < 128 or (g > 145 and g > r * 1.35 and g > b * 1.25):
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (r, g, b, 255)

    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise RuntimeError("No opaque urinal pixels remained after chroma removal")

    subject = image.crop(bbox)
    max_width, max_height = 56, 42
    scale = min(max_width / subject.width, max_height / subject.height)
    new_size = (
        max(1, round(subject.width * scale)),
        max(1, round(subject.height * scale)),
    )
    subject = subject.resize(new_size, Image.Resampling.NEAREST)

    # Keep a compact wall-side footprint: centered horizontally, with slightly
    # more transparent space below for placement against a restroom wall.
    canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    x = (64 - subject.width) // 2
    y = 8
    canvas.alpha_composite(subject, (x, y))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUTPUT, optimize=False)
    canvas.resize((512, 512), Image.Resampling.NEAREST).save(PREVIEW, optimize=False)

    alpha = canvas.getchannel("A")
    opaque = sum(1 for value in alpha.getdata() if value == 255)
    partial = sum(1 for value in alpha.getdata() if value not in (0, 255))
    corners = [canvas.getpixel((0, 0))[3], canvas.getpixel((63, 0))[3],
               canvas.getpixel((0, 63))[3], canvas.getpixel((63, 63))[3]]
    green_subject = sum(
        1 for r, g, b, a in canvas.getdata()
        if a and g > 145 and g > r * 1.35 and g > b * 1.25
    )
    print(f"output={OUTPUT}")
    print(f"size={canvas.size} subject={subject.size} opaque={opaque} partial_alpha={partial}")
    print(f"corner_alpha={corners} green_subject_pixels={green_subject}")


if __name__ == "__main__":
    main()
